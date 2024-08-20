#' Sample Movebank dataset with GPS tracking data
#'
#' A sample Movebank dataset with GPS tracking data, formatted as a
#' [Frictionless Data Package](
#' https://specs.frictionlessdata.io/data-package/) and read by
#' `read_package()`.
#'
#' This sample is derived from the Zenodo-deposited dataset
#' [Dijkstra et al. (2022)](https://doi.org/10.5281/zenodo.10053903), but
#' excludes the acceleration data.
#' @source https://doi.org/10.5281/zenodo.10053903
#' @family sample data
#' @examples
#' \dontrun{
#' # The data in o_assen was created with the code below
#' o_assen <-
#'   read_package("https://zenodo.org/records/10053903/files/datapackage.json") %>%
#'   remove_resource("acceleration")
#' usethis::use_data(o_assen)
#' }
"o_assen"
