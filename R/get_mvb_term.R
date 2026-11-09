#' Get term from the Movebank Attribute Dictionary
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function is deprecated in favour of [move2::movebank_get_vocabulary()],
#' which offers the same functionality and more.
#'
#' @keywords internal
#' @export
get_mvb_term <- function(label) {
  lifecycle::deprecate_stop(
    when = "0.5.0",
    what = "get_mvb_term()",
    with = "move2::movebank_get_vocabulary()"
  )
}
