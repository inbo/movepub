#' Write Movebank Darwin Core files
#'
#' Converts a Frictionless Data Package of Movebank data to Darwin Core
#' formatted CSV files that can be uploaded to a
#' [GBIF IPT](https://www.gbif.org/ipt).
#' The conversion is expressed in SQL:
#' - [dwc_occurrence](https://github.com/inbo/movepub/blob/main/inst/sql/movebank_dwc_occurrence.sql)
#'
#' @param package A Frictionless Data Package of Movebank data, as read by
#'   [frictionless::read_package()].
#' @param directory Path to local directory to write files to.
#' @param doi DOI of the source dataset, used to populate record-level terms.
#' @param rightsholder Acronym of the organization owning or managing rights
#'   over the data.
#' @return Darwin Core formatted CSV file(s) written to disk.
#' @export
write_movebank_dwca <- function(package, directory = ".", doi = package$id,
                                rightsholder = NULL) {
  # Read metadata
  eml <- datacite_to_eml(doi)
  dwc_doi <- eml$dataset$alternateIdentifier
  dwc_title <- paste(eml$dataset$title, "[subsampled representation]")
  dwc_license <- eml$dataset$intellectualRights
  dwc_rightsholder <- rightsholder

  # Read data
  assertthat::assert_that(
    c("reference-data") %in% frictionless::resources(package),
    msg = "`package` must contain resource `reference-data`."
  )
  assertthat::assert_that(
    c("gps") %in% frictionless::resources(package),
    msg = "`package` must contain resource `gps`."
  )
  message("Reading data from `package`.")
  ref <- frictionless::read_resource(package, "reference-data")
  gps <- frictionless::read_resource(package, "gps")

  # Create database
  message("Creating database.")
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  DBI::dbWriteTable(con, "reference_data", ref)
  DBI::dbWriteTable(con, "gps", gps)

  # Query database
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
  readr::write_csv(
    dwc_occurrence,
    file.path(directory, "dwc_occurrence.csv"),
    na = ""
  )
}
