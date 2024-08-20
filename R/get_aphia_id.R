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
  result <- purrr::discard(result, is.list) # Remove x$message: "Not found" for e.g. "?"

  # Create taxa df with name and aphia_id
  if (length(result) == 0) {
    taxa <- dplyr::tibble(name = x, aphia_id = NA)
  } else {
    taxa <- result %>%
      dplyr::as_tibble() %>%
      tidyr::pivot_longer(cols = dplyr::everything()) %>%
      dplyr::rename("aphia_id" = "value")
  }

  # Join taxa df with input names + add fields
  url_prefix <- "https://www.marinespecies.org/aphia.php?p=taxdetails&id="
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
        paste0(url_prefix, .data$aphia_id),
        NA_character_
      ),
      aphia_url_cli = ifelse(
        !is.na(.data$aphia_id),
        paste0("{.href [", .data$aphia_id, "](", url_prefix, .data$aphia_id, ")}"),
        NA_character_
      )
    )
}
