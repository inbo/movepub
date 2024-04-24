#' Transform Movebank data to Darwin Core
#'
#' Transforms data from a Movebank dataset (formatted as a [Frictionless Data
#' Package](https://specs.frictionlessdata.io/data-package/)) to [Darwin Core](
#' https://dwc.tdwg.org/).
#' The resulting CSV file can be uploaded to an [IPT](https://www.gbif.org/ipt)
#' for publication to GBIF and/or OBIS, together with an EML (metadata) file
#' created with `write_eml()`.
#' A `meta.xml` file is not created.
#'
#' See [Get started](https://inbo.github.io/movepub/articles/movepub.html#dwc)
#' for examples.
#'
#' @param package A Frictionless Data Package of Movebank data, as read by
#'   [frictionless::read_package()].
#' @param directory Path to local directory to write file to.
#' @param doi DOI of the original dataset, used to get dataset-level terms.
#' @param rights_holder Acronym of the organization owning or managing the
#'   rights over the data.
#' @return CSV (data) file written to disk.
#' @family dwc functions
#' @export
#' @section Data:
#' `package` is expected to contain a `reference-data` and `gps` resource.
#' Data are transformed into an [Occurrence Core](https://rs.gbif.org/core/dwc_occurrence_2022-02-02.xml).
#' This **follows recommendations** discussed and created by Peter Desmet,
#' Sarah Davidson, John Wieczorek and others.
#'
#' Key features of the Darwin Core transformation:
#' - Deployments (animal+tag associations) are parent events, with tag
#'   attachment (a human observation) and GPS positions (machine observations)
#'   as child events.
#'   No information about the parent event is provided other than its ID,
#'   meaning that data can be expressed in an Occurrence Core with one row per
#'   observation and `parentEventID` shared by all occurrences in a deployment.
#' - The tag attachment event often contains metadata about the animal (sex,
#'   lifestage, comments) and deployment as a whole.
#' - No event/occurrence is created for the deployment end, since the end date
#'   is often undefined, unreliable and/or does not represent an animal
#'   occurrence.
#' - Only `visible` (nonoutlier) GPS records that fall within a deployment are
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

  # Retrieve metadata from DataCite and build EML
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

  # Expand data with all columns used in DwC mapping
  ref_cols <- c(
    "animal-id", "animal-life-stage", "animal-nickname",
    "animal-reproductive-condition", "animal-sex", "animal-taxon",
    "attachment-type", "deploy-on-date", "deploy-on-latitude",
    "deploy-on-longitude", "deployment-comments", "manipulation-type", "tag-id",
    "tag-manufacturer-name", "tag-model"
  )
  ref <- expand_cols(ref, ref_cols)
  gps_cols <- c(
    "comments", "event-id", "height-above-ellipsoid", "height-above-msl",
    "individual-local-identifier", "individual-taxon-canonical-name",
    "location-error-numerical", "location-lat", "location-long", "sensor-type",
    "tag-local-identifier", "timestamp", "visible"
  )
  gps <- expand_cols(gps, gps_cols)

  # Lookup AphiaIDs for taxa
  names <- dplyr::pull(dplyr::distinct(ref, .data$`animal-taxon`))
  taxa <- get_aphia_id(names)
  cli::cli_alert_info("Taxa found in reference data and their WoRMS AphiaID:")
  cli::cli_dl(dplyr::pull(taxa, .data$aphia_id, .data$name))

  # Data transformation to Darwin Core
  dwc_occurrence_ref <-
    ref %>%
    dplyr::filter(!is.na(.data$`deploy-on-date`)) %>%
    dplyr::left_join(taxa, by = dplyr::join_by("animal-taxon" == "name")) %>%
    dplyr::mutate(
      # RECORD-LEVEL
      basisOfRecord = "HumanObservation",
      dataGeneralizations = NA_character_,
      # OCCURRENCE
      occurrenceID = paste(.data$`animal-id`, .data$`tag-id`, "start", sep = "_"), # Same as eventID
      sex = dplyr::recode(
        .data$`animal-sex`,
        "m" = "male",
        "f" = "female",
        "u" = "unknown"
      ),
      lifeStage = .data$`animal-life-stage`,
      reproductiveCondition = .data$`animal-reproductive-condition`,
      occurrenceStatus = "present",
      # ORGANISM
      organismID = .data$`animal-id`,
      organismName = .data$`animal-nickname`,
      # EVENT
      eventID = paste(.data$`animal-id`, .data$`tag-id`, "start", sep = "_"),
      parentEventID = paste(.data$`animal-id`, .data$`tag-id`, sep = "_"),
      eventType = "tag attachment",
      eventDate = format(.data$`deploy-on-date`, format = "%Y-%m-%dT%H:%M:%SZ"),
      samplingProtocol = "tag attachment",
      eventRemarks = paste0(
        dplyr::if_else(
          is.na(.data$`tag-manufacturer-name`),
          "tag ",
          dplyr::if_else(
            is.na(.data$`tag-model`),
            paste(.data$`tag-manufacturer-name`, "tag "),
            paste(.data$`tag-manufacturer-name`, .data$`tag-model`, "tag ")
          )
        ),
        dplyr::if_else(
          !is.na(.data$`attachment-type`),
          paste("attached by", .data$`attachment-type`, "to "),
          "attached to "
        ),
        dplyr::recode(
          .data$`manipulation-type`,
          "none" = "free-ranging animal",
          "confined" = "confined animal",
          "recolated" = "relocated animal",
          "manipulated other" = "manipulated animal",
          .default = "likely free-ranging animal",
          .missing = "likely free-ranging animal"
        ),
        dplyr::if_else(
          !is.na(.data$`deployment-comments`),
          paste0(" | ", .data$`deployment-comments`),
          ""
        )
      ),
      # LOCATION
      minimumElevationInMeters = NA_real_,
      maximumElevationInMeters = NA_real_,
      locationRemarks = NA_character_,
      decimalLatitude = as.numeric(.data$`deploy-on-latitude`),
      decimalLongitude = as.numeric(.data$`deploy-on-longitude`),
      geodeticDatum = dplyr::if_else(
        !is.na(.data$`deploy-on-latitude`),
        "EPSG:4326",
        NA_character_
      ),
      coordinateUncertaintyInMeters = dplyr::if_else(
        !is.na(.data$`deploy-on-latitude`),
        187, # Assume coordinate precision of 0.001 degree (157m) and recording by GPS (30m)
        NA_real_
      ),
      # TAXON
      scientificNameID = .data$aphia_lsid,
      scientificName = .data$`animal-taxon`,
      kingdom = "Animalia",
      .keep = "none"
    )

    # GPS POSITIONS
    dwc_occurrence_gps <-
      gps %>%
      # Exclude outliers & (rare) empty coordinates
      dplyr::filter(.data$visible & !is.na(.data$`location-lat`)) %>%
      dplyr::mutate(
        time_per_hour = strftime(.data$timestamp, "%y-%m-%d %H %Z", tz = "UTC")
      ) %>%
      # Group by animal+tag+date+hour combination
      dplyr::group_by(
        .data$`individual-local-identifier`,
        .data$`tag-local-identifier`,
        .data$time_per_hour
      ) %>%
      dplyr::arrange(.data$timestamp) %>%
      dplyr::mutate(subsample_count = dplyr::n()) %>%
      # Take first record/timestamp within group
      dplyr::filter(dplyr::row_number() == 1) %>%
      dplyr::ungroup() %>%
      # Join with reference data
      dplyr::left_join(
        ref,
        by = dplyr::join_by(
          "individual-local-identifier" == "animal-id",
          "tag-local-identifier" == "tag-id"
        )
      ) %>%
      # Exclude (rare) records outside a deployment
      dplyr::filter(!is.na(.data$`animal-taxon`)) %>%
      dplyr::left_join(taxa, by = dplyr::join_by("animal-taxon" == "name")) %>%
      dplyr::mutate(
        # RECORD-LEVEL
        basisOfRecord = "MachineObservation",
        dataGeneralizations = paste(
          "subsampled by hour: first of", .data$subsample_count, "record(s)"
        ),
        # OCCURRENCE
        occurrenceID = as.character(.data$`event-id`),
        sex = dplyr::recode(
          .data$`animal-sex`,
          "m" = "male",
          "f" = "female",
          "u" = "unknown"
        ),
        lifeStage = NA_character_, # Value at start of deployment might not apply to all records
        reproductiveCondition = NA_character_, # Value at start of deployment might not apply to all records
        occurrenceStatus = "present",
        # ORGANISM
        organismID = .data$`individual-local-identifier`,
        organismName = .data$`animal-nickname`,
        # EVENT
        eventID = as.character(.data$`event-id`),
        parentEventID = paste(
          .data$`individual-local-identifier`,
          .data$`tag-local-identifier`,
          sep = "_"
        ),
        eventType = "gps",
        eventDate = format(.data$timestamp, format = "%Y-%m-%dT%H:%M:%SZ"),
        samplingProtocol = .data$`sensor-type`,
        eventRemarks = dplyr::coalesce(.data$`comments`, ""),
        # LOCATION
        minimumElevationInMeters = dplyr::coalesce(
          .data$`height-above-msl`,
          as.numeric(.data$`height-above-ellipsoid`),
          NA_real_
        ),
        maximumElevationInMeters = dplyr::coalesce(
          .data$`height-above-msl`,
          as.numeric(.data$`height-above-ellipsoid`),
          NA_real_
        ),
        locationRemarks = dplyr::case_when(
          !is.na(.data$`height-above-msl`) ~
            "elevations are altitude above mean sea level",
          !is.na(.data$`height-above-ellipsoid`) ~
            "elevations are altitude above ellipsoid"
        ),
        decimalLatitude = as.numeric(.data$`location-lat`),
        decimalLongitude = as.numeric(.data$`location-long`),
        geodeticDatum = "EPSG:4326",
        coordinateUncertaintyInMeters =
          as.numeric(.data$`location-error-numerical`),
        # TAXON
        scientificNameID = .data$aphia_lsid,
        scientificName = .data$`animal-taxon`,
        kingdom = "Animalia",
        .keep = "none"
      )

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
      dplyr::arrange(
        .data$parentEventID,
        .data$eventDate
      )

  # Informing message
  cli::cli_h2("Transforming data to Darwin Core")

  # Write file
  dwc_occurrence_path <- file.path(directory, "dwc_occurrence.csv")
  cli::cli_h2("Writing file")
  cli::cli_ul(c(
    "{.file {dwc_occurrence_path}}"
  ))
  if (!dir.exists(directory)) {
    dir.create(directory, recursive = TRUE)
  }
  readr::write_csv(dwc_occurrence, dwc_occurrence_path, na = "")
}
