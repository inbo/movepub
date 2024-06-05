#' Transform Movebank data to a Darwin Core Archive
#'
#' Transforms a Movebank dataset (formatted as a [Frictionless Data Package](
#' https://specs.frictionlessdata.io/data-package/)) to a [Darwin Core
#' Archive](https://dwc.tdwg.org/text/).
#'
#' The resulting files can be uploaded to an [IPT](https://www.gbif.org/ipt)
#' for publication to GBIF and/or OBIS.
#' A corresponding `eml.xml` metadata file can be created with [write_eml()].
#' See [Get started](https://inbo.github.io/movepub/articles/movepub.html#dwc)
#' for examples.
#'
#' @param package A Frictionless Data Package of Movebank data, as read by
#'   [frictionless::read_package()].
#'   It is expected to contain a `reference-data` and `gps` resource.
#' @param directory Path to local directory to write file to.
#' @param doi DOI of the original dataset, used to get dataset-level terms.
#' @param rights_holder Acronym of the organization owning or managing the
#'   rights over the data.
#' @return CSV and `meta.xml` files written to disk.
#'   And invisibly, a list of data frames with the transformed data.
#' @family dwc functions
#' @export
#' @section Transformation details:
#' This function **follows recommendations** suggested by Peter Desmet,
#' Sarah Davidson, John Wieczorek and others and transforms data to:
#' - An [Occurrence core](
#'   https://rs.gbif.org/core/dwc_occurrence_2022-02-02.xml).
#' - A `meta.xml` file.
#'
#' Key features of the Darwin Core transformation:
#' - Deployments (animal+tag associations) are parent events, with tag
#'   attachment (a human observation) and GPS positions (machine observations)
#'   as child events.
#'   No information about the parent event is provided other than its ID,
#'   meaning that data can be expressed in an Occurrence core with one row per
#'   observation and `parentEventID` shared by all occurrences in a deployment.
#' - The tag attachment event often contains metadata about the animal (sex,
#'   life stage, comments) and deployment as a whole.
#' - No event/occurrence is created for the deployment end, since the end date
#'   is often undefined, unreliable and/or does not represent an animal
#'   occurrence.
#' - Only `visible` (non-outlier) GPS records that fall within a deployment are
#'   included.
#' - GPS positions are downsampled to the **first GPS position per hour**, to
#'   reduce the size of high-frequency data.
#'   It is possible for a deployment to contain no GPS positions, e.g. if the
#'   tag malfunctioned right after deployment.
#' @examples
#' \dontrun{
#' write_dwc(o_assen)
#' }
write_dwc <- function(package, directory = ".", doi = package$id,
                      rights_holder = NULL) {
  if (is.null(doi)) {
    cli::cli_abort(
      c(
        "Can't find a DOI in {.field package$id}.",
        "i" = "Provide one in {.arg doi}."
      ),
      class = "movepub_error_doi_missing"
    )
  }
  if (!is.character(doi) || length(doi) != 1) {
    cli::cli_abort(
      c(
        "{.arg doi} must be a character (vector of length one).",
        "x" = "{.val {doi}} is {.type {doi}}."
      ),
      class = "movepub_error_doi_invalid"
    )
  }
  eml <- datacite_to_eml(doi)

  # Update title
  dataset_name <- paste(eml$dataset$title, "[subsampled representation]")

  # Update license
  license <- eml$dataset$intellectualRights$rightsUri # Used in DwC

  # Get DOI URL
  doi_url <- eml$dataset$alternateIdentifier[[1]]
  dataset_id <- doi_url # Used in DwC

  # Set rights_holder
  if (is.null(rights_holder)) {
    rights_holder <- NA_character_
  }

  # Read data from package
  cli::cli_h2("Reading data")
  if (!"reference-data" %in% frictionless::resources(package)) {
    cli::cli_abort(
      "{.arg package} must contain resource {.val reference-data}.",
      class = "movepub_error_reference_data_missing"
    )
  }
  if (!"gps" %in% frictionless::resources(package)) {
    cli::cli_abort(
      "{.arg package} must contain resource {.val gps}.",
      class = "movepub_error_gps_data_missing"
    )
  }
  ref <- frictionless::read_resource(package, "reference-data")
  gps <- frictionless::read_resource(package, "gps")

  # Lookup AphiaIDs for taxa
  names <- dplyr::pull(dplyr::distinct(ref, .data$`animal-taxon`))
  taxa <- get_aphia_id(names)
  cli::cli_alert_info("Taxa found in reference data and their WoRMS AphiaID:")
  cli::cli_dl(dplyr::pull(taxa, .data$aphia_id, .data$name))

  # Start transformation
  cli::cli_h2("Transforming data to Darwin Core")
  dwc_occurrence_ref <- dwc_occurrence_ref(ref, taxa)
  dwc_occurrence_gps <- dwc_occurrence_gps(gps, ref, taxa)

  # Bind the occurrence df from the helper functions
  dwc_occurrence <-
    dwc_occurrence_ref %>%
    dplyr::bind_rows(dwc_occurrence_gps) %>%
    dplyr::mutate(
      # DATASET-LEVEL
      type = "Event",
      license = license,
      rightsHolder = rights_holder,
      datasetID = dataset_id,
      institutionCode = "MPIAB", # Max Planck Institute of Animal Behavior
      collectionCode = "Movebank",
      datasetName = dataset_name,
      .before = "basisOfRecord"
    ) %>%
    dplyr::arrange(.data$parentEventID, .data$eventDate)

  # Write files
  dwc_occurrence_path <- file.path(directory, "dwc_occurrence.csv")
  cli::cli_h2("Writing files")
  cli::cli_ul(c(
    "{.file {dwc_occurrence_path}}"
  ))
  if (!dir.exists(directory)) {
    dir.create(directory, recursive = TRUE)
  }
  readr::write_csv(dwc_occurrence, dwc_occurrence_path, na = "")
}
