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
#'   "    /tmp/RtmpxEkUiz/movepub/eml.xml",
#'   sep = "\n"
#' )
#' remove_temp_path(to_clean)
remove_temp_path <- function(string, replacement = "<temporary_path>") {
  # compare against the output of tempdir() to be able to remove paths on any os
  stringr::str_replace_all(string,
                           pattern = stringr::str_escape(tempdir()),
                           replacement = replacement)
}

#' Remove a UUID from a character
#'
#' Helper for test-write_dwc.R.
#' This helper is convenient for file snapshots where a UUID is included in the file, yet different every run.
#' This is a common artefact of how frictionless data packages are created using frictionless-r.
#' If this behaviour in frictionless-r is changed in the future, this helper becomes unneccesairy.
#'
#' @param string Character vector. Of which UUIDs need to be removed.
#' @param replacement Character (Optional). A replacement for the matched UUID.
#' By default \code{"RANDOM_UUID"}
#'
#' @return A Character vector with the UUIDs removed.
#' @family helper functions
#'
#' @examples
#' to_clean <- paste(
#'   'encoding=\"UTF-8\"?>",',
#'   '"<eml:eml xmlns:eml=\"https://eml.ecoinformatics.org/eml-2.2.0\"',
#'   'packageId=\"39272b1c-4174-4a86-a2d2-f48c4f29e6de\"',
#'   'system=\"uuid\"',
#'   collapse = " "
#' )
#' remove_UUID(to_clean)
remove_UUID <- function(string, replacement = "RANDOM_UUID") {
  gsub(
    "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}",
    replacement,
    string
  )
}


#' Get snapshot for write_dwc()
#'
#' Wrapper of `write_dwc()` that returns path of selected output file.
#' Needed for `testthat::expect_snapshot_file()` which expects the path of a
#' single file to compare against snapshot.
#' @inheritParams write_dwc
#' @param file Either `occurrence` or `eml` to select which output file of
#'   `write_dwc()` to return.
#' @param ... forwarded to [write_dwc()]
#' @return Path of selected output file.
#' @noRd
#' @examples write_dwc_snapshot(mica, tempdir(), "occurrence")
write_dwc_snapshot <- function(package, directory, file, ...) {
  suppressMessages(write_dwc(package, directory, ...))
  switch(file,
    occurrence = file.path(directory, "dwc_occurrence.csv"),
    eml = file.path(directory, "eml.xml")
  )
}
