#' Sample of a frictionless data package containing a bird tracking dataset
#'
#' A sample [frictionless data package](
#' https://specs.frictionlessdata.io/data-package/) of Movebank data, as read
#' by [frictionless::read_package()].
#'
#' It is derived from a dataset on [Zenodo](https://zenodo.org/record/5653311),
#' but excludes the acceleration data.
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
