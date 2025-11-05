#' Check GPS data
#'
#' @param gps A data frame derived from a `gps` resource.
#' @return The provided data frame or an error if required fields are missing.
#' @family dwc functions
#' @noRd
check_gps <- function(gps) {
  required_cols <- c(
    "individual-local-identifier",
    "tag-local-identifier",
    "timestamp"
  )
  gps_cols <- names(gps)
  missing_cols <- setdiff(required_cols, gps_cols)
  if (length(missing_cols) > 0) {
    cli::cli_abort(
      c(
        "Resource {.val gps} in {.arg package} is missing required fields.",
        "x" = "{.val {missing_cols}} {?is/are} missing."
      ),
      class = "movepub_error_gps_cols_missing"
    )
  }

  return(gps)
}
