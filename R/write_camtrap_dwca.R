#' Write camera trap Darwin Core Archive
#'
#' Converts a [Camtrap DP](https://tdwg.github.io/camtrap-dp) dataset to Darwin
#' Core formatted CSV files that can be uploaded to the IPT.
#' Conversion is based on two SQL files:
#' - [dwc_occurrence](https://github.com/inbo/movepub/blob/main/inst/sql/camtrap-dp/dwc_occurrence.sql):
#' A Darwin Core Occurrence core file.
#' - [dwc_multimedia](https://github.com/inbo/movepub/blob/main/inst/sql/camtrap-dp/dwc_multimedia.sql):
#' Audubon Media Description extension file.
#'
#' @param package A Camera Trap Data Package, as read by
#'   [frictionless::read_package()].
#' @param directory Path to local directory to write files to.
#' @return Darwin Core formatted CSV files written to disk.
#' @noRd
write_camtrap_dwca <- function(package, directory) {
  # Read data from Data Package
  deployments <- frictionless::read_resource(package, "deployments")
  observations <- frictionless::read_resource(package, "observations")
  media <- frictionless::read_resource(package, "media")

  # Get metadata
  metadata <- list(
    id = package$id,
    rightsHolder = package$rightsHolder,
    dataLicense = purrr::keep(package$licenses, ~ .$scope == "data")[[1]]$path,
    mediaLicense = purrr::keep(package$licenses, ~ .$scope == "media")[[1]]$path,
    organization = purrr::pluck(package$organizations, 1)$title,
    source = purrr::pluck(package$sources, 1)$title,
    projectTitle = package$project$title
  )

  # Create database
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  DBI::dbWriteTable(con, "deployments", deployments)
  DBI::dbWriteTable(con, "observations", observations)
  DBI::dbWriteTable(con, "media", media)

  # Query DB
  dwc_occurrence_sql <- glue::glue_sql(
    readr::read_file(
      system.file("sql/camtrap-dp/dwc_occurrence.sql", package = "movepub")
    ), .con = con
  )
  dwc_multimedia_sql <- glue::glue_sql(
    readr::read_file(
      system.file("sql/camtrap-dp/dwc_multimedia.sql", package = "movepub")
    ), .con = con
  )
  dwc_occurrence <- DBI::dbGetQuery(con, dwc_occurrence_sql)
  dwc_multimedia <- DBI::dbGetQuery(con, dwc_multimedia_sql)
  DBI::dbDisconnect(con)

  # Create directory if it doesn't exists yet
  if (!dir.exists(directory)) {
    dir.create(directory, recursive = TRUE)
  }

  # Write files
  readr::write_csv(dwc_occurrence, file.path(directory, "dwc_occurrence.csv"), na = "")
  readr::write_csv(dwc_multimedia, file.path(directory, "dwc_multimedia.csv"), na = "")
}
