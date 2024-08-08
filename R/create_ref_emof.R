#' Create extended measurements or facts (eMoF)
#'
#' @param ref_occurrence Data frame with Darwin Core occurrences derived from
#' tag attachments, as returned by `create_ref_occurrence()`.
#' @return Data frame with
#' [eMoF](https://rs.gbif.org/extension/obis/extended_measurement_or_fact_2023-08-28.xml),
#' more specifically `life stage` and `sex`.
#' @family dwc functions
#' @noRd
create_ref_emof <- function(ref_occurrence) {
  lifestage <-
    ref_occurrence %>%
    dplyr::mutate(
      .keep = "none",
      occurrenceID = .data$occurrenceID,
      measurementType = "life stage",
      measurementTypeID =
        "http://vocab.nerc.ac.uk/collection/P01/current/LSTAGE01/",
      measurementValue = dplyr::case_when(
        .data$lifeStage == "adult" ~ "adult",
        .data$lifeStage == "juvenile" ~ "juvenile",
        .data$lifeStage == "unknown" ~ "indeterminate",
        is.na(.data$lifeStage) ~ "not speficifed",
        .default = "indeterminate"
      ),
      measurementValueID = dplyr::case_when(
        measurementValue == "adult" ~
          "http://vocab.nerc.ac.uk/collection/S11/current/S1116/",
        measurementValue == "juvenile" ~
          "https://vocab.nerc.ac.uk/collection/S11/current/S1127/",
        measurementValue == "indeterminate" ~
          "http://vocab.nerc.ac.uk/collection/S11/current/S1152/",
        measurementValue == "not speficied" ~
          "http://vocab.nerc.ac.uk/collection/S11/current/S1131/"
      ),
      measurementUnit = NA,
      measurementUnitID = "http://vocab.nerc.ac.uk/collection/P06/current/XXXX/"
    )

  sex <-
    ref_occurrence %>%
    dplyr::mutate(
      .keep = "none",
      occurrenceID = .data$occurrenceID,
      measurementType = "sex",
      measurementTypeID =
        "http://vocab.nerc.ac.uk/collection/P01/current/ENTSEX01/",
      measurementValue = dplyr::case_when(
        .data$sex == "female" ~ "female",
        .data$sex == "male" ~ "male",
        .data$sex == "unknown" ~ "indeterminate",
        is.na(.data$sex) ~ "not spefified",
        .default = "indeterminate"
      ),
      measurementValueID = dplyr::case_when(
        measurementValue == "female" ~
          "http://vocab.nerc.ac.uk/collection/S10/current/S102/",
        measurementValue == "male" ~
          "https://vocab.nerc.ac.uk/collection/S10/current/S103/",
        measurementValue == "hermaphrodite" ~
          "https://vocab.nerc.ac.uk/collection/S10/current/S105/",
        measurementValue == "indeterminate" ~
          "https://vocab.nerc.ac.uk/collection/S10/current/S105/",
        measurementValue == "not specified" ~
          "https://vocab.nerc.ac.uk/collection/S10/current/S104/"
      ),
      measurementUnit = NA,
      measurementUnitID = "http://vocab.nerc.ac.uk/collection/P06/current/XXXX/"
    )

  emof <- dplyr::bind_rows(lifestage, sex) %>%
    dplyr::arrange(.data$occurrenceID)

  # only keep measurementTypes that have at least 1 non-NA value in
  # `ref_occurrence`
  if (all(is.na(ref_occurrence$sex))) {
    emof <- emof %>%
      dplyr::filter(.data$measurementType != "sex")
  }
  if (all(is.na(ref_occurrence$lifeStage))) {
    emof <- emof %>%
      dplyr::filter(.data$measurementType != "life stage")
  }

  return(emof)
}
