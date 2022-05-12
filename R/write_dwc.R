#' Transform Movebank data to Darwin Core
#'
#' Transforms a published Movebank dataset (formatted as a Frictionless Data
#' Package) to Darwin Core and EML.
#' The resulting CSV and `eml.xml` files can be uploaded to a
#' [GBIF IPT](https://www.gbif.org/ipt) for publication.
#' A `meta.xml` file is not created.
#'
#' The transformation to Darwin Core is expressed in SQL:
#' - [dwc_occurrence](https://github.com/inbo/movepub/blob/main/inst/sql/movebank_dwc_occurrence.sql)
#'
#' @param package A Frictionless Data Package of Movebank data, as read by
#'   [frictionless::read_package()].
#' @param directory Path to local directory to write files to.
#' @param doi DOI of the source dataset, used to populate record-level terms.
#' @param contact Person to be set as resource contact and metadata provider,
#'   e.g. `person("Peter", "Desmet", , "fakeaddress@email.com", ,
#'   c(ORCID = "0000-0002-8442-8025"))`.
#' @param rights_holder Acronym of the organization owning or managing the
#'   rights over the data.
#' @return CSV (data) and EML (metadata) files written to disk.
#' @export
#' @examples
#' package <- frictionless::read_package(
#'   "https://zenodo.org/record/5879096/files/datapackage.json"
#' )
#' write_dwc(
#'   package,
#'   contact = person("Peter", "Desmet", , "fakeaddress@email.com", , c(ORCID = "0000-0002-8442-8025"))
#' )
write_dwc <- function(package, directory = ".", doi = package$id,
                      contact = NULL, rights_holder = NULL) {
  # Retrieve metadata from DataCite and build EML
  message("Creating EML metadata.")
  eml <- datacite_to_eml(doi)

  # Get license
  license_url <- eml$dataset$intellectualRights$rightsUri # Used in DwC

  # Update contact and set metadata provider
  if (!is.null(contact)) {
    eml$dataset$contact <- EML::set_responsibleParty(
      givenName = contact$given,
      surName = contact$family,
      userId = if (!is.null(contact$comment[["ORCID"]])) {
        list(directory = "http://orcid.org/", contact$comment[["ORCID"]])
      } else {
        NULL
      }
    )
  }
  eml$dataset$metadataProvider <- eml$dataset$contact

  # Update title
  title <- paste(eml$dataset$title, "[subsampled representation]")
  eml$dataset$title <- title # Used in DwC

  # Add extra paragraph
  first_author <- eml$dataset$creator[[1]]$individualName$surName
  pub_year <- substr(eml$dataset$pubDate, 1, 4)
  doi_url <- eml$dataset$alternateIdentifier[[1]] # Used in DwC
  study_url <- eml$dataset$alternateIdentifier[[2]]
  study_id <- if (!is.null(study_url)) {
    sub("https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study", "", study_url)
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

  # Set external link to Movebank study ID
  if (!is.null(study_url)) {
    eml$dataset$distribution = list(
      scope = "document", online = list(
        url = list("function" = "information", study_url)
      )
    )
  }

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
    "tag-manufacturer-name"
  )
  ref <- expand_cols(ref, ref_cols)

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
