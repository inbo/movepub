#' Write Movebank Darwin Core Archive
#'
#' Converts a Frictionless Data Package of Movebank data to Darwin Core Archive
#' formatted CSV files that can be uploaded to a
#' [GBIF IPT](https://www.gbif.org/ipt).
#' The conversion is expressed in SQL:
#' - [dwc_occurrence](https://github.com/inbo/movepub/blob/main/inst/sql/movebank_dwc_occurrence.sql)
#'
#' @param package A Frictionless Data Package of Movebank data, as read by
#'   [frictionless::read_package()].
#' @param directory Path to local directory to write files to.
#' @return Darwin Core Archive formatted CSV files written to disk.
#' @export
write_movebank_dwca <- function(package, directory = ".") {
  # Check for necessary resources
  assertthat::assert_that(
    c("reference-data") %in% frictionless::resources(package),
    msg = "`package` must contain resource `reference-data`."
  )
  assertthat::assert_that(
    c("gps") %in% frictionless::resources(package),
    msg = "`package` must contain resource `gps`."
  )

  # Read data
  message("Reading data from `package`.")
  ref <- frictionless::read_resource(package, "reference-data")
  gps <- frictionless::read_resource(package, "gps")

  # Create database
  message("Transforming data to Darwin Core.")
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
  readr::write_csv(
    dwc_occurrence,
    file.path(directory, "dwc_occurrence.csv"),
    na = ""
  )
}
