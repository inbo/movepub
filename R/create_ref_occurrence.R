#' Create Darwin Core Occurrence from reference data
#'
#' @param ref A data frame derived from a `reference-data` resource.
#' @param taxa A data frame with taxa and their Aphia ID.
#' @return A data frame with Darwin Core occurrences derived from tag
#'   attachments.
#' @family dwc functions
#' @noRd
create_ref_occurrence <- function(ref, taxa) {
  # Expand data with all columns used in Darwin Core transformation
  ref_cols <- c(
    "animal-id", "animal-life-stage", "animal-nickname",
    "animal-reproductive-condition", "animal-sex", "animal-taxon",
    "attachment-type", "deploy-on-date", "deploy-on-latitude",
    "deploy-on-longitude", "deployment-comments", "manipulation-type", "tag-id",
    "tag-manufacturer-name", "tag-model"
  )
  ref <- expand_cols(ref, ref_cols)

  # Transform data
  occurrence <-
    ref |>
    dplyr::filter(!is.na(.data$`deploy-on-date`)) |>
    dplyr::left_join(taxa, by = dplyr::join_by("animal-taxon" == "name")) |>
    dplyr::mutate(
      .keep = "none",
      # RECORD-LEVEL
      basisOfRecord = "HumanObservation",
      dataGeneralizations = NA_character_,
      # OCCURRENCE
      occurrenceID = paste(
        .data$`animal-id`, .data$`tag-id`, "start", sep = "_" # Same as eventID
      ),
      sex = dplyr::recode(
        .data$`animal-sex`,
        "m" = "male",
        "f" = "female",
        "u" = "unknown"
      ),
      lifeStage = .data$`animal-life-stage`,
      reproductiveCondition = .data$`animal-reproductive-condition`,
      occurrenceStatus = "present",
      # ORGANISM
      organismID = .data$`animal-id`,
      organismName = .data$`animal-nickname`,
      # EVENT
      eventID = paste(.data$`animal-id`, .data$`tag-id`, "start", sep = "_"),
      parentEventID = paste(.data$`animal-id`, .data$`tag-id`, sep = "_"),
      eventType = "tag attachment",
      eventDate = format(.data$`deploy-on-date`, format = "%Y-%m-%dT%H:%M:%SZ"),
      samplingProtocol = "tag attachment",
      eventRemarks = paste0(
        dplyr::if_else(
          is.na(.data$`tag-manufacturer-name`),
          "tag ",
          dplyr::if_else(
            is.na(.data$`tag-model`),
            paste(.data$`tag-manufacturer-name`, "tag "),
            paste(.data$`tag-manufacturer-name`, .data$`tag-model`, "tag ")
          )
        ),
        dplyr::if_else(
          !is.na(.data$`attachment-type`),
          paste("attached by", .data$`attachment-type`, "to "),
          "attached to "
        ),
        dplyr::recode(
          .data$`manipulation-type`,
          "none" = "free-ranging animal",
          "confined" = "confined animal",
          "recolated" = "relocated animal",
          "manipulated other" = "manipulated animal",
          .default = "likely free-ranging animal",
          .missing = "likely free-ranging animal"
        ),
        dplyr::if_else(
          !is.na(.data$`deployment-comments`),
          paste0(" | ", .data$`deployment-comments`),
          ""
        )
      ),
      # LOCATION
      minimumElevationInMeters = NA_real_,
      maximumElevationInMeters = NA_real_,
      locationRemarks = NA_character_,
      decimalLatitude = as.numeric(.data$`deploy-on-latitude`),
      decimalLongitude = as.numeric(.data$`deploy-on-longitude`),
      geodeticDatum = dplyr::if_else(
        !is.na(.data$`deploy-on-latitude`),
        "EPSG:4326",
        NA_character_
      ),
      coordinateUncertaintyInMeters = dplyr::if_else(
        !is.na(.data$`deploy-on-latitude`),
        # Assume coordinate precision of 0.001 degree (157m) and recording
        # by GPS (30m)
        187,
        NA_real_
      ),
      # TAXON
      scientificNameID = .data$aphia_lsid,
      scientificName = .data$`animal-taxon`,
      kingdom = "Animalia"
    ) |>
    dplyr::arrange(.data$occurrenceID)

 return(occurrence)
}
