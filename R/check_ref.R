#' Check reference data
#'
#' @param ref A data frame derived from a `ref` resource.
#' @return The provided data frame or an error if required fields are missing.
#' @family dwc functions
#' @noRd
check_ref <- function(ref) {
  required_cols <- c(
    "animal-id",
    "animal-taxon",
    "tag-id"
  )
  ref_cols <- names(ref)
  missing_cols <- setdiff(required_cols, ref_cols)
  if (length(missing_cols) > 0) {
    cli::cli_abort(
      c(
        "Resource {.val reference-data} in {.arg package} is missing required
         fields.",
        "x" = "{.val {missing_cols}} {?is/are} missing."
      ),
      class = "movepub_error_ref_cols_missing"
    )
  }

  return(ref)
}
