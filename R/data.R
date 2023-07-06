#' Sample of a frictionless data package containing a bird tracking dataset
#'
#' A sample [frictionless data package](https://specs.frictionlessdata.io/data-package/) of Movebank data, as read by [frictionless::read_package()].
#'
#' It is derived from a dataset on [Zenodo](https://zenodo.org/record/5653311),
#' but excludes `O_ASSEN-acceleration-2018.csv.gz` and `O_ASSEN-acceleration-2019.csv.gz`.
#'
#'
#' @source https://zenodo.org/record/5653311
#' @family sample data
#'
#' @examples
#' \dontrun{
#' # the data in o_assen was created with the code below
#' o_assen <- frictionless::remove_resource(
#'   frictionless::read_package("https://zenodo.org/record/5653311/files/datapackage.json"),
#'   "acceleration"
#' )
#' usethis::use_data(o_assen)
#' }
"o_assen"
