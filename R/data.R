#' Sample Movebank dataset with GPS tracking data
#'
#' A sample Movebank dataset with GPS tracking data, formatted as a
#' [Frictionless Data Package](
#' https://specs.frictionlessdata.io/data-package/) and read by
#' [frictionless::read_package()].
#'
#' This sample is derived from the Zenodo-deposited dataset
#' [Dijkstra et al. (2022)](https://doi.org/10.5281/zenodo.5653311), but
#' excludes the acceleration data.
#' @source https://zenodo.org/record/5653311
#' @family sample data
#' @examples
#' \dontrun{
#' # The data in o_assen was created with the code below
#' o_assen <-
#'   frictionless::read_package("https://zenodo.org/record/5653311/files/datapackage.json") %>%
#'   frictionless::remove_resource("acceleration")
#' usethis::use_data(o_assen)
#' }
"o_assen"
