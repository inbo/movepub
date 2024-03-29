#' Get WoRMS AphiaID from a taxonomic name
#'
#' This function wraps [worrms::wm_name2id_()] so that it returns a data frame
#' rather than a list.
#' It also silences "not found" warnings, returning `NA` instead.
#'
#' @param x A (vector with) taxonomic name(s).
#' @return Data frame with `name`, `aphia_id`, `aphia_lsid` and `aphia_url`.
#' @family support functions
#' @export
#' @importFrom dplyr %>%
#' @examples
#' get_aphia_id("Mola mola")
#' get_aphia_id(c("Mola mola", "not_a_name"))
get_aphia_id <- function(x) {
  result <- suppressWarnings(worrms::wm_name2id_(x))
  taxa <- result %>%
    purrr::discard(is.list) %>% # Remove x$message: "Not found" for e.g. "?"
    dplyr::as_tibble() %>%
    tidyr::pivot_longer(cols = dplyr::everything()) %>%
    dplyr::rename("aphia_id" = "value")
  # Join resulting taxa (with aphia_id) and input names to get df with all names
  taxa %>%
    dplyr::full_join(dplyr::as_tibble(x), by = c("name" = "value")) %>%
    dplyr::mutate(
      aphia_lsid = ifelse(
        !is.na(.data$aphia_id),
        paste0("urn:lsid:marinespecies.org:taxname:", .data$aphia_id),
        NA_character_
      ),
      aphia_url = ifelse(
        !is.na(.data$aphia_id),
        paste0("https://www.marinespecies.org/aphia.php?p=taxdetails&id=", .data$aphia_id),
        NA_character_
      )
    )
}
