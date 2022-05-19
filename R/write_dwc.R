#' Transform Movebank data to Darwin Core
#'
#' Transforms a published Movebank dataset (formatted as a
#' [Frictionless Data Package](https://specs.frictionlessdata.io/data-package/))
#' to Darwin Core CSV and EML files that can be uploaded to a
#' [GBIF IPT](https://www.gbif.org/ipt) for publication.
#' A `meta.xml` file is not created.
#'
#' @param package A Frictionless Data Package of Movebank data, as read by
#'   [frictionless::read_package()].
#' @param directory Path to local directory to write files to.
#' @param doi DOI of the original dataset, used to get metadata.
#' @param contact Person to be set as resource contact and metadata provider.
#'   To be provided as a `person()`.
#' @param rights_holder Acronym of the organization owning or managing the
#'   rights over the data.
#' @return CSV (data) and EML (metadata) files written to disk.
#' @export
#' @section Metadata:
#'
#' Metadata are derived from the original dataset by looking up its `doi` in
#' DataCite ([example](https://api.datacite.org/dois/10.5281/zenodo.5879096))
#' and transforming these to EML.
#' Uses `datacite_to_eml()` under the hood.
#' The following properties are set:
#'
#' - **title**: Original title + `[subsampled representation]`.
#' - **description**: Automatically created first paragraph describing this is
#'   a derived dataset, followed by the original dataset description.
#' - **creators**: Creators of the original dataset.
#' - **contact**: `contact` or first creator of the original dataset.
#' - **metadata provider**: `contact` or first creator of the original dataset.
#' - **keywords**: Keywords of the original dataset.
#' - **alternative identifier**: DOI of original dataset. This way, no new DOI
#'   will be created when publishing to GBIF.
#' - **external link** (and alternative identifier): URL of the Movebank study.
#'
#' To be set manually in the GBIF IPT: **license** (currently not recognized by
#' the IPT), **type**, **subtype**, **update frequency**, and **publishing
#' organization**.
#'
#' Not set: geographic, taxonomic, temporal coverage, associated parties,
#' project data, sampling methods, and citations. Not applicable: collection
#' data.
#'
#' @section Data:
#'
#' A `reference-data` and `gps` resource are expected to be found in `package`.
#' Their CSV data are loaded in to a SQLite database,
#' [transformed to Darwin Core using SQL](https://github.com/inbo/movepub/blob/main/inst/sql/movebank_dwc_occurrence.sql)
#' and written to disk as CSV file(s).
#'
#' Key features of the Darwin Core transformation:
#' - Animal+tag deployments are parent events, with deployment start (a human
#' observation), GPS positions (machine observations), and optional deployment
#' end (a human observation) as child events. The parent event itself does not
#' contain any information other than an ID.
#' - The deployment start event often metadata about the animal (sex, lifestage,
#'   comments) and deployment as a whole.
#' - Only `visible` (nonoutlier) GPS records that fall within a deployment are
#'   included.
#' - GPS positions are downsampled to the first GPS position per hour, to reduce
#'   the size of high-frequency data. It is possible for a deployment to contain
#'   no GPS positions, e.g. if the tag malfunctioned right after deployment.
#' - The exact deployment end is often unknown and thus not included.
#' @examples
#' # See vignette("movepub")
write_dwc <- function(package, directory = ".", doi = package$id,
                      contact = NULL, rights_holder = NULL) {
  # Retrieve metadata from DataCite and build EML
  message("Creating EML metadata.")
  eml <- datacite_to_eml(doi)

  # Update title
  title <- paste(eml$dataset$title, "[subsampled representation]")
  eml$dataset$title <- title # Used in DwC

  # Add extra paragraph
  first_author <- eml$dataset$creator[[1]]$individualName$surName
  pub_year <- substr(eml$dataset$pubDate, 1, 4)
  doi_url <- eml$dataset$alternateIdentifier[[1]] # Used in DwC
  study_url <- eml$dataset$alternateIdentifier[[2]]
  study_id <- if (!is.null(study_url)) {
    gsub("https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study", "", study_url, fixed = TRUE)
  } else {
    NULL
  }
  first_para <- glue::glue(
    # Add span to circumvent https://github.com/ropensci/EML/issues/342
    "<span></span>This animal tracking dataset is derived from ",
    first_author, " et al. (", pub_year, ", <a href\"", doi_url, "\">", doi_url, "</a>) ",
    "a deposit of Movebank study <a href=\"", study_url, "\">", study_id, "</a>. ",
    "Data have been standardized to Darwin Core using the ",
    "<a href=\"https://inbo.github.io/movepub/\">movepub</a> R package ",
    "and are downsampled to the first GPS position per hour. ",
    "The original dataset description follows.",
    .null = ""
  )
  eml$dataset$abstract$para <- purrr::prepend(
    eml$dataset$abstract$para,
    paste0("<![CDATA[", first_para, "]]>")
  )

  # Update contact and set metadata provider
  if (!is.null(contact)) {
    eml$dataset$contact <- EML::set_responsibleParty(
      givenName = contact$given,
      surName = contact$family,
      electronicMailAddress = contact$email,
      userId = if (!is.null(contact$comment[["ORCID"]])) {
        list(directory = "http://orcid.org/", contact$comment[["ORCID"]])
      } else {
        NULL
      }
    )
  }
  eml$dataset$metadataProvider <- eml$dataset$contact

  # Set external link to Movebank study ID
  if (!is.null(study_url)) {
    eml$dataset$distribution = list(
      scope = "document", online = list(
        url = list("function" = "information", study_url)
      )
    )
  }

  # Get license
  license_url <- eml$dataset$intellectualRights$rightsUri # Used in DwC

  # Read data from package
  message("Reading data from `package`.")
  assertthat::assert_that(
    c("reference-data") %in% frictionless::resources(package),
    msg = "`package` must contain resource `reference-data`."
  )
  assertthat::assert_that(
    c("gps") %in% frictionless::resources(package),
    msg = "`package` must contain resource `gps`."
  )
  ref <- frictionless::read_resource(package, "reference-data")
  gps <- frictionless::read_resource(package, "gps")

  # Expand data with all columns used in DwC mapping
  ref_cols <- c(
    "animal-id", "animal-life-stage","animal-nickname",
    "animal-reproductive-condition", "animal-sex", "animal-taxon",
    "attachment-type", "deploy-off-date", "deploy-off-latitude",
    "deploy-off-longitude", "deploy-on-date", "deploy-on-latitude",
    "deploy-on-longitude", "deployment-comments", "deployment-end-comments",
    "deployment-end-type", "manipulation-type", "tag-id",
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

  # Create database
  message("Creating database and transforming to Darwin Core.")
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  DBI::dbWriteTable(con, "reference_data", ref)
  DBI::dbWriteTable(con, "gps", gps)

  # Query database
  dwc_occurrence_sql <- glue::glue_sql(
    readr::read_file(
      system.file("sql/movebank_dwc_occurrence.sql", package = "movepub")
    ),
    .con = con
  )
  dwc_occurrence <- DBI::dbGetQuery(con, dwc_occurrence_sql)
  DBI::dbDisconnect(con)

  # Write files
  if (!dir.exists(directory)) {
    dir.create(directory, recursive = TRUE)
  }
  EML::write_eml(eml, file.path(directory, "eml.xml"))
  readr::write_csv(
    dwc_occurrence,
    file.path(directory, "dwc_occurrence.csv"),
    na = ""
  )
}
