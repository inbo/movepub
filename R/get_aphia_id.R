#' Get AphiaID from a taxonomic name
#'
#' This function wraps [worrms::wm_name2id_()] so that it returns a data frame
#' rather than a list.
#' It also silences "not found" warnings, returning `NA` instead
#'
#' @param x A (vector with) taxonomic name(s).
#' @return Data frame with `name` and `aphia_id`.
#' @family support functions
#' @importFrom dplyr %>%
#' @export
#' @examples
#' get_aphia_id("Mola mola")
#' get_aphia_id(c("Mola mola", "not_a_name"))
get_aphia_id <- function(x) {
  result <- suppressWarnings(worrms::wm_name2id_(x))
  taxa <- result %>%
    purrr::discard(is.list) %>% # Remove x$message: "Not found" for e.g. "?"
    dplyr::as_tibble() %>%
    tidyr::pivot_longer(cols = dplyr::everything()) %>%
    dplyr::rename(aphia_id = value)
  # Join resulting taxa (with aphia_id) and input names to get df with all names
  taxa %>%
    dplyr::full_join(dplyr::as_tibble(x), by = c("name" = "value"))
}
