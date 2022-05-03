#' Convert Movebank data to Darwin Core
#'
#' Converts a published Movebank dataset (formatted as a Frictionless Data
#' Package) to Darwin Core (CSV files) and EML (`eml.xml`).
#' The resulting files can be uploaded to a [GBIF IPT](https://www.gbif.org/ipt)
#' for publication.
#' A `meta.xml` file is not created.
#'
#' The conversion to Darwin Core is expressed in SQL:
#' - [dwc_occurrence](https://github.com/inbo/movepub/blob/main/inst/sql/movebank_dwc_occurrence.sql)
#'
#' @param package A Frictionless Data Package of Movebank data, as read by
#'   [frictionless::read_package()].
#' @param directory Path to local directory to write files to.
#' @param doi DOI of the source dataset, used to populate record-level terms.
#' @param study_id Movebank study ID of the source dataset, used for reference.
#' @param inheritParams datacite_to_eml
#' @param rights_holder Acronym of the organization owning or managing the
#'   rights over the data.
#' @return CSV (data) and EML (metadata) files written to disk.
#' @export
write_movebank_dwca <- function(package, directory = ".", doi = package$id,
                                study_id, contact = NULL, metadata_provider =
                                NULL, rights_holder = NULL) {
  # METADATA
  message("Retrieving metadata from DataCite.")

  # Create EML from DataCite metadata
  eml <- datacite_to_eml(doi)

  # Create attributes
  new_title <- paste(eml$dataset$title, "[subsampled representation]")
  first_author <- eml$dataset$creator[[1]]$individualName$surName
  pub_year <- substr(eml$dataset$pubDate, 1, 4)
  doi_url <- eml$dataset$alternateIdentifier[[1]]
  study_url <- paste0(
    "https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study",
    study_id
  )
  license_code <- eml$dataset$intellectualRights
  new_para <- glue::glue(
    "This animal tracking dataset is derived from ",
    first_author, " et al. (", pub_year, ", ",
    "<a href\"", doi_url, "\">", doi_url, "</a>) ",
    "a deposit of Movebank study <a href\"", study_url, "\">", study_id, "</a>. ",
    "Data have been standardized to Darwin Core using the ",
    "<a href=\"https://inbo.github.io/movepub/\">movepub</a> R package ",
    "and are downsampled to the first GPS position per hour. ",
    "The original dataset description follows."
  )

  # Set attributes for GBIF IPT
  eml$dataset$title <- new_title
  eml$dataset$abstract$para <- purrr::prepend(
    eml$dataset$abstract$para,
    paste0("<![CDATA[", new_para, "]]>")
  )
  eml$dataset$distribution = list(
    scope = "document", online = list(
      url = list("function" = "information", study_url)
    )
  )
  eml$dataset$intellectualRights <- switch(license_code,
    "cc0-1.0" = "To the extent possible under law, the publisher has waived all rights to these data and has dedicated them to the <ulink url=\"http://creativecommons.org/publicdomain/zero/1.0/legalcode\"><citetitle>Public Domain (CC0 1.0)</citetitle></ulink>. Users may copy, modify, distribute and use the work, including for commercial purposes, without restriction."
  )

  dwc_license <- switch(license_code,
    "cc0-1.0" = "http://creativecommons.org/publicdomain/zero/1.0/"
  )

  # READ DATA
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

  # CREATE DATABASE
  message("Creating database.")
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  DBI::dbWriteTable(con, "reference_data", ref)
  DBI::dbWriteTable(con, "gps", gps)

  # QUERY DATABASE
  message("Transforming data to Darwin Core.")
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
  write_eml(eml, file.path(directory, "eml.xml"))
  readr::write_csv(
    dwc_occurrence,
    file.path(directory, "dwc_occurrence.csv"),
    na = ""
  )
}
