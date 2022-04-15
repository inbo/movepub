#' Write Movebank Darwin Core Archive
#'
#' Converts a Frictionless Data Package of Movebank data to Darwin Core Archive
#' formatted CSV files that can be uploaded to a
#' [GBIF IPT](https://www.gbif.org/ipt).
#' The conversion is expressed in SQL:
#' - [dwc_occurrence_deployment](https://github.com/inbo/movepub/blob/main/inst/sql/movebank_dwc_occurrence_deployment.sql)
#' - [dwc_occurrence_positions](https://github.com/inbo/movepub/blob/main/inst/sql/movebank_dwc_occurrence_positions.sql)
#'
#' @param package A Frictionless Data Package of Movebank data, as read by
#'   [frictionless::read_package()].
#' @param directory Path to local directory to write files to.
#' @return Darwin Core Archive formatted CSV files written to disk.
#' @export
write_movebank_dwca <- function(package, directory = ".") {
  assertthat::assert_that(
    c("reference-data") %in% frictionless::resources(package),
    msg = "`package` must contain resource `reference-data`."
  )
  assertthat::assert_that(
    c("gps") %in% frictionless::resources(package),
    msg = "`package` must contain resource `gps`."
  )

  # Read data from Data Package
  message("Reading data from `package`.")
  reference_data <- frictionless::read_resource(package, "reference-data")
  gps <- frictionless::read_resource(package, "gps")

  # Convert date and dttm columns to string for easier handling in SQLite:
  # https://stackoverflow.com/a/13462536/2463806
  date_to_chr <- function(x) {
    dplyr::mutate(x,
      dplyr::across(where(~ inherits(., c("Date", "POSIXt"))), as.character)
    )
  }
  reference_data <- date_to_chr(reference_data)
  gps <- date_to_chr(gps)

  # Create database
  message("Transforming data to Darwin Core.")
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  DBI::dbWriteTable(con, "reference_data", reference_data)
  DBI::dbWriteTable(con, "gps", gps)

  # Query database
  dwc_occurrence_deployment_sql <- glue::glue_sql(
    readr::read_file(
      system.file("sql/movebank_dwc_occurrence_deployment.sql", package = "movepub")
    ), .con = con
  )
  dwc_occurrence_deployment <- DBI::dbGetQuery(con, dwc_occurrence_deployment_sql)
  DBI::dbDisconnect(con)

  # Create directory if it doesn't exists yet + write files
  if (!dir.exists(directory)) {
    dir.create(directory, recursive = TRUE)
  }
  readr::write_csv(
    dwc_occurrence_deployment,
    file.path(directory, "dwc_occurrence_deployment.csv"),
    na = ""
  )
}
