#' Write camera trap Darwin Core Archive
#'
#' @param A Camera Trap Data Package.
#' @return A Darwin Core Archive written to disk.
#' @export
  # Read data from Data Package
  deployments <- frictionless::read_resource(package, "deployments")
  observations <- frictionless::read_resource(package, "observations")

  # Get metadata
  metadata <- list(
    id = package$id,
    rightsHolder = package$rightsHolder,
    bibliographicCitation = package$bibliographicCitation,
    dataLicense = purrr::keep(package$licenses, ~ .$scope == "data"),
    mediaLicense = purrr::keep(package$licenses, ~ .$scope == "media"),
    organization = purrr::pluck(package$organizations, 1)$title,
    source = purrr::pluck(package$sources, 1)$title,
    projectTitle = package$project$title
  )

  # Create database
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  DBI::dbWriteTable(con, "deployments", deployments)
  DBI::dbWriteTable(con, "observations", observations)

  # Query DB
  dwc_occurrence_sql <- glue::glue_sql(
    readr::read_file("inst/sql/camtrap/dwc_occurrence.sql"), .con = con
  )
  dwc_occurrence <- DBI::dbGetQuery(con, dwc_occurrence_sql)
  DBI::dbDisconnect(con)

  dwc_occurrence
}
