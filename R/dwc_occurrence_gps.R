#' Transform gps data to Darwin Core
#'
#' Transforms gps data from a package (formatted as a [Frictionless Data
#' Package](https://specs.frictionlessdata.io/data-package/)) to [Darwin Core](
#' https://dwc.tdwg.org/).
#'
#' @param gps GPS data of a package, as tibble data frame
#' @param ref ref data of a package, as tibble data frame
#' @param taxa Taxa and aphia_id, as tibble data frame
#' @return Darwin core data, as tibble data frame
#' @family dwc functions
#' @noRd
dwc_occurrence_gps <- function(gps, ref, taxa) {
  # Expand data with all columns used in DwC mapping
  gps_cols <- c(
    "comments", "event-id", "height-above-ellipsoid", "height-above-msl",
    "individual-local-identifier", "individual-taxon-canonical-name",
    "location-error-numerical", "location-lat", "location-long", "sensor-type",
    "tag-local-identifier", "timestamp", "visible"
  )
  gps <- expand_cols(gps, gps_cols)

  # GPS POSITIONS
  dwc_occurrence_gps <-
    gps %>%
    # Exclude outliers & (rare) empty coordinates
    dplyr::filter(.data$visible & !is.na(.data$`location-lat`)) %>%
    dplyr::mutate(
      time_per_hour = strftime(.data$timestamp, "%y-%m-%d %H %Z", tz = "UTC")
    ) %>%
    # Group by animal+tag+date+hour combination
    dplyr::group_by(
      .data$`individual-local-identifier`,
      .data$`tag-local-identifier`,
      .data$time_per_hour
    ) %>%
    dplyr::arrange(.data$timestamp) %>%
    dplyr::mutate(subsample_count = dplyr::n()) %>%
    # Take first record/timestamp within group
    dplyr::filter(dplyr::row_number() == 1) %>%
    dplyr::ungroup() %>%
    # Join with reference data
    dplyr::left_join(
      ref,
      by = dplyr::join_by(
        "individual-local-identifier" == "animal-id",
        "tag-local-identifier" == "tag-id"
      )
    ) %>%
    # Exclude (rare) records outside a deployment
    dplyr::filter(!is.na(.data$`animal-taxon`)) %>%
    dplyr::left_join(taxa, by = dplyr::join_by("animal-taxon" == "name")) %>%
    dplyr::mutate(
      .keep = "none",
      # RECORD-LEVEL
      basisOfRecord = "MachineObservation",
      dataGeneralizations = paste(
        "subsampled by hour: first of", .data$subsample_count, "record(s)"
      ),
      # OCCURRENCE
      occurrenceID = as.character(.data$`event-id`),
      sex = dplyr::recode(
        .data$`animal-sex`,
        "m" = "male",
        "f" = "female",
        "u" = "unknown"
      ),
      # Value at start of deployment might not apply to all records
      lifeStage = NA_character_,
      reproductiveCondition = NA_character_,
      occurrenceStatus = "present",
      # ORGANISM
      organismID = .data$`individual-local-identifier`,
      organismName = .data$`animal-nickname`,
      # EVENT
      eventID = as.character(.data$`event-id`),
      parentEventID = paste(
        .data$`individual-local-identifier`,
        .data$`tag-local-identifier`,
        sep = "_"
      ),
      eventType = "gps",
      eventDate = format(.data$timestamp, format = "%Y-%m-%dT%H:%M:%SZ"),
      samplingProtocol = .data$`sensor-type`,
      eventRemarks = dplyr::coalesce(.data$`comments`, ""),
      # LOCATION
      minimumElevationInMeters = dplyr::coalesce(
        .data$`height-above-msl`,
        as.numeric(.data$`height-above-ellipsoid`),
        NA_real_
      ),
      maximumElevationInMeters = dplyr::coalesce(
        .data$`height-above-msl`,
        as.numeric(.data$`height-above-ellipsoid`),
        NA_real_
      ),
      locationRemarks = dplyr::case_when(
        !is.na(.data$`height-above-msl`) ~
          "elevations are altitude above mean sea level",
        !is.na(.data$`height-above-ellipsoid`) ~
          "elevations are altitude above ellipsoid"
      ),
      decimalLatitude = as.numeric(.data$`location-lat`),
      decimalLongitude = as.numeric(.data$`location-long`),
      geodeticDatum = "EPSG:4326",
      coordinateUncertaintyInMeters =
        as.numeric(.data$`location-error-numerical`),
      # TAXON
      scientificNameID = .data$aphia_lsid,
      scientificName = .data$`animal-taxon`,
      kingdom = "Animalia"
    )

  return(dwc_occurrence_gps)
}
