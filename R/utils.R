# HELPER FUNCTIONS

#' Clean list
#'
#' Removes all elements from a list that meet a criterion function, e.g.
#' `is.null(x)` for empty elements.
#' Removal can be recursive to guarantee elements are removed at any level.
#' Function is copied and adapted from [rlist::list.clean()] (MIT licensed), to
#' avoid requiring full `rlist` dependency.
#'
#' @param x A list or vector.
#' @param fun Function returning `TRUE` for elements that should be removed.
#' @param recursive Whether list should be cleaned recursively.
#' @return Cleaned list.
#' @family helper functions
#' @noRd
clean_list <- function(x, fun = is.null, recursive = FALSE) {
  if (recursive) {
    x <- lapply(x, function(item) {
      if (is.list(item)) {
        clean_list(item, fun, recursive = TRUE)
      } else {
        item
      }
    })
  }
  "[<-"(x, vapply(x, fun, logical(1L)), NULL)
}

#' Expand columns
#'
#' Expands a data frame with columns. Added columns will have `NA_character_`
#' values, existing columns of the same name will not be overwritten.
#'
#' @param df A data frame.
#' @param colnames A character vector of column names.
#' @return Data frame expanded with columns that were not yet present.
#' @family helper functions
#' @noRd
expand_cols <- function(df, colnames) {
  cols_to_add <- setdiff(colnames, colnames(df))
  df[, cols_to_add] <- NA_character_
  return(df)
}

#' Clean abstract
#'
#' Cleans and formats abstracts. If the abstract contains HTML tags, it wraps
#' the content appropriately in CDATA or paragraph tags.
#' Empty lines are discarded, and line breaks are preserved.
#'
#' @param abstract Abstract list, where each element may contain HTML tags,
#' line breaks, or plain text.
#' @return A list of cleaned and formatted abstracts, each wrapped in a list
#' with a `para` element.
#'
#'
#' @noRd
#' @examples
#' abstract <- c(
#' "No HTML",
#' "HTML at <b>end</b>",
#' "<b>HTML</b> at beginning",
#' "No HTML\n\nwith linebreak",
#' "<b>HTML</b> with \n\nlinebreak"
#' )
#' clean_abstract(abstract)
clean_abstract <- function(abstract) {
  abstract %>%
    # If HTML, split at linebreak
    purrr::map(~ ifelse(grepl("<", ., fixed = TRUE), strsplit(., "\n"), .)) %>%
    # Remove empty elements
    purrr::discard(~ . == "") %>%
    # If HTML, wrap in CDATA or paragraph tags
    purrr::map(~ if (grepl("<", ., fixed = TRUE)) {
      # CDATA only works if the string starts with an html tag
      # (see https://github.com/ropensci/EML/issues/342)
      if (grepl("^<", ., fixed = TRUE)) paste0("<![CDATA[", ., "]]>")
      else paste0("<p>", ., "</p>")
    } else {
      .
    }) %>%
    # Wrap everything in paragrapgs
    purrr::map(~ list(para = .))
}
