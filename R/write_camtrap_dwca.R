#' Write camera trap Darwin Core Archive
#'
#' @param A Camera Trap Data Package.
#' @return A Darwin Core Archive written to disk.
#' @export
write_camtrap_dwca <- function(package) {
  # Read data from Data Package
  deployments <- frictionless::read_resource(package, "deployments")
  observations <- frictionless::read_resource(package, "observations")

  # Create database
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  DBI::dbWriteTable(con, "deployments", deployments)
  DBI::dbWriteTable(con, "observations", observations)

  # Query DB
  dwc_occurrence_sql <- glue::glue_sql(
    readr::read_file("inst/sql/camtrap/dwc_occurrence.sql"), .con = con
  )
  dwc_occurrence <- DBI::dbGetQuery(con, dwc_occurrence_sql)

  dwc_occurrence
}
