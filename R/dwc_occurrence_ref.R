#' Transform reference data to Darwin Core
#'
#' Transforms reference data from a package (formatted as a [Frictionless Data
#' Package](https://specs.frictionlessdata.io/data-package/)) to [Darwin Core](
#' https://dwc.tdwg.org/).
#'
#' @param ref Reference data of a package, as tibble data frame
#' @param taxa Taxa and aphia_id, as tibble data frame
#' @return Darwin core data, as tibble data frame
#' @family dwc functions
#' @noRd
dwc_occurrence_ref <- function(ref, taxa) {

  # Expand data with all columns used in DwC mapping
  ref_cols <- c(
    "animal-id", "animal-life-stage", "animal-nickname",
    "animal-reproductive-condition", "animal-sex", "animal-taxon",
    "attachment-type", "deploy-on-date", "deploy-on-latitude",
    "deploy-on-longitude", "deployment-comments", "manipulation-type", "tag-id",
    "tag-manufacturer-name", "tag-model"
  )
  ref <- expand_cols(ref, ref_cols)

  # Data transformation to Darwin Core
  dwc_occurrence_ref <-
    ref %>%
    dplyr::filter(!is.na(.data$`deploy-on-date`)) %>%
    dplyr::left_join(taxa, by = dplyr::join_by("animal-taxon" == "name")) %>%
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
    )

 return(dwc_occurrence_ref)
}
