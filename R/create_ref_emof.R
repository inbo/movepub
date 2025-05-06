#' Create Extended Measurements Or Facts from Darwin Core Occurrence data
#'
#' Pulls the **sex** and **life stage** information from the Darwin Core
#' Occurrence data created with `create_ref_occurrence()` and maps these values
#' to a controlled vocabulary recommended by [OBIS](https://obis.org/).
#'
#' @param ref_occurrence A data frame with Darwin Core occurrences derived from
#'   tag attachments, as returned by [create_ref_occurrence()].
#' @return A data frame with [Extended Measurement Or Facts](
#'   https://rs.gbif.org/extension/obis/extended_measurement_or_fact_2023-08-28.xml).
#' @family dwc functions
#' @noRd
create_ref_emof <- function(ref_occurrence) {
  sex <-
    ref_occurrence |>
    dplyr::mutate(
      .keep = "none",
      occurrenceID = .data$occurrenceID,
      measurementType = "sex",
      measurementTypeID =
        "http://vocab.nerc.ac.uk/collection/P01/current/ENTSEX01/",
      measurementValue = .data$sex, # Value as is
      measurementValueID = dplyr::recode(
        .data$sex,
        "female" = "http://vocab.nerc.ac.uk/collection/S10/current/S102/",
        "male" = "https://vocab.nerc.ac.uk/collection/S10/current/S103/",
        "unknown" = "https://vocab.nerc.ac.uk/collection/S10/current/S105/", # indeterminate
        .default = NA_character_, # Don't map other values
        .missing = "https://vocab.nerc.ac.uk/collection/S10/current/S104/" # not specified
      ),
      measurementUnit = NA_character_,
      measurementUnitID = "http://vocab.nerc.ac.uk/collection/P06/current/XXXX/"
    )

  lifestage <-
    ref_occurrence |>
    dplyr::mutate(
      .keep = "none",
      occurrenceID = .data$occurrenceID,
      measurementType = "life stage",
      measurementTypeID =
        "http://vocab.nerc.ac.uk/collection/P01/current/LSTAGE01/",
      measurementValue = .data$lifeStage, # Value as is
      measurementValueID = dplyr::recode(
        .data$lifeStage,
        "adult" = "http://vocab.nerc.ac.uk/collection/S11/current/S1116/",
        "subadult" = "https://vocab.nerc.ac.uk/collection/S11/current/S120/", # sub-adult
        "juvenile" = "https://vocab.nerc.ac.uk/collection/S11/current/S1127/",
        "unknown" = "http://vocab.nerc.ac.uk/collection/S11/current/S1152/", # indeterminate
        .default = NA_character_, # Don't map other values
        .missing = "http://vocab.nerc.ac.uk/collection/S11/current/S1131/" # not specified
      ),
      measurementUnit = NA_character_,
      measurementUnitID = "http://vocab.nerc.ac.uk/collection/P06/current/XXXX/"
    )

  emof <-
    dplyr::bind_rows(sex, lifestage) |>
    dplyr::arrange(.data$occurrenceID)

  # Remove the measurementType if all values of that type are NA in ref_occurrence
  if (all(is.na(ref_occurrence$sex))) {
    emof <- dplyr::filter(emof, .data$measurementType != "sex")
  }
  if (all(is.na(ref_occurrence$lifeStage))) {
    emof <- dplyr::filter(emof, .data$measurementType != "life stage")
  }

  return(emof)
}
