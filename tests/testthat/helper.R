#' Remove a temp path from a string
#'
#' Helper for test-write_dwc.R.
#' This helper is convenient for snapshots where the file is written to a temporary directory.
#' The helper assumes all temporary files are placed in a movepub sub-directory of the temporary path.
#' As to avoid matching with any none changing paths that fit the pattern for a temporary path.
#'
#' @param string Character vector of which paths need to be removed.
#' @param replacement A replacement for the matched temporary path.
#'
#' @return Character vector with all instances of a temporary path replaced
#' @family helper functions
#' @examples
#' to_clean <- paste("Writing (meta)data to:",
#'                   "    /tmp/RtmpxEkUiz/movepub/eml.xml",
#'                   sep = "\n")
#' remove_temp_path(to_clean)
remove_temp_path <- function(string, replacement = "temporary_path") {
  gsub("\\/tmp\\/[a-zA-Z]+\\/movepub",replacement,string)
}

