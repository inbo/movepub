#' Create Darwin Core Occurrence from GPS data
#'
#' @param gps A data frame derived from a `gps` resource.
#' @param ref A data frame derived from a `reference-data` resource.
#' @param taxa A data frame with taxa and their Aphia ID.
#' @return A data frame with Darwin Core occurrences derived from GPS positions.
#' @family dwc functions
#' @noRd
create_gps_occurrence <- function(gps, ref, taxa) {
  # Expand data with non-required columns used in Darwin Core transformation
  ref_cols <- c(
    "animal-nickname", "animal-sex"
  )
  ref <- expand_cols(ref, ref_cols)
  gps_cols <- c(
    "comments", "event-id", "height-above-ellipsoid", "height-above-msl",
    "location-error-numerical", "location-lat", "location-long", "sensor-type",
    "visible"
  )
  gps <- expand_cols(gps, gps_cols)

  # Transform data
  occurrence <-
    gps |>
    # Exclude outliers & (rare) empty coordinates
    dplyr::filter(as.logical(.data$visible) & !is.na(.data$`location-lat`)) |>
    dplyr::mutate(
      time_per_hour = strftime(.data$timestamp, "%y-%m-%d %H %Z", tz = "UTC")
    ) |>
    # Group by animal+tag+date+hour combination
    dplyr::group_by(
      .data$`individual-local-identifier`,
      .data$`tag-local-identifier`,
      .data$time_per_hour
    ) |>
    dplyr::arrange(.data$timestamp) |>
    dplyr::mutate(subsample_count = dplyr::n()) |>
    # Take first record/timestamp within group
    dplyr::filter(dplyr::row_number() == 1) |>
    dplyr::ungroup() |>
    # Join with reference data
    dplyr::left_join(
      ref,
      by = dplyr::join_by(
        "individual-local-identifier" == "animal-id",
        "tag-local-identifier" == "tag-id"
      )
    ) |>
    # Exclude (rare) records outside a deployment
    dplyr::filter(!is.na(.data$`animal-taxon`)) |>
    dplyr::left_join(taxa, by = dplyr::join_by("animal-taxon" == "name")) |>
    dplyr::mutate(
      .keep = "none",
      # RECORD-LEVEL
      basisOfRecord = "MachineObservation",
      dataGeneralizations = paste(
        "subsampled by hour: first of", .data$subsample_count, "record(s)"
      ),
      # OCCURRENCE
      occurrenceID = as.character(.data$`event-id`),
      sex = dplyr::case_match(
        .data$`animal-sex`,
        "m" ~ "male",
        "f" ~ "female",
        "u" ~ "unknown"
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
        as.numeric(.data$`height-above-msl`),
        as.numeric(.data$`height-above-ellipsoid`),
        NA_real_
      ),
      maximumElevationInMeters = dplyr::coalesce(
        as.numeric(.data$`height-above-msl`),
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
      georeferenceSources =
        dplyr::if_else(.data$`sensor-type` == "gps", "GPS", NA_character_),
      # IDENTIFICATION
      identificationVerificationStatus = "verified by expert",
      # TAXON
      scientificNameID = .data$aphia_lsid,
      scientificName = .data$`animal-taxon`,
      kingdom = "Animalia"
    )

  return(occurrence)
}
