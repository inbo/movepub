# HELPER FUNCTIONS

#' Clean list
#'
#' Removes all elements from a list that meet a criterion function, e.g.
#' `is.null(x)` for empty elements.
#' Removal can be recursive to guarantee elements are removed at any level.
#' Function is copied and adapted from [rlist::list.clean()] (MIT licensed), to
#' avoid requiring full `rlist` dependency.
#'
#' @param x List or vector.
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
