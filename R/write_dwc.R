#' Transform Movebank data to Darwin Core
#'
#' Transforms data from a Movebank dataset (formatted as a [Frictionless Data
#' Package](https://specs.frictionlessdata.io/data-package/)) to [Darwin Core](
#' https://dwc.tdwg.org/).
#' The resulting CSV and EML files can be uploaded to an [IPT](
#' https://www.gbif.org/ipt) for publication to GBIF and/or OBIS.
#' A `meta.xml` file is not created.
#'
#' See [Get started](https://inbo.github.io/movepub/articles/movepub.html#dwc)
#' for examples.
#'
#' @param package A Frictionless Data Package of Movebank data, as read by
#'   [frictionless::read_package()].
#' @param directory Path to local directory to write file(s) to.
#' @param doi DOI of the original dataset, used to get metadata.
#' @param contact Person to be set as resource contact and metadata provider.
#'   To be provided as a [person()].
#' @param rights_holder Acronym of the organization owning or managing the
#'   rights over the data.
#' @param study_id Identifier of the Movebank study from which the dataset was
#'   derived (e.g. `1605797471` for
#'   [this study](https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study160579747)).
#' @return CSV (data) and EML (metadata) files written to disk.
#' @family dwc functions
#' @export
#' @importFrom dplyr .data
#' @section Metadata:
#' Metadata are derived from the original dataset by looking up its `doi` in
#' DataCite ([example](https://api.datacite.org/dois/10.5281/zenodo.5879096))
#' and transforming these to EML.
#' Uses `datacite_to_eml()` under the hood.
#' The following properties are set:
#'
#' - **title**: Original title + `[subsampled representation]`.
#' - **description**: Automatically created first paragraph describing this is
#'   a derived dataset, followed by the original dataset description.
#' - **license**: License of the original dataset.
#' - **creators**: Creators of the original dataset.
#' - **contact**: `contact` or first creator of the original dataset.
#' - **metadata provider**: `contact` or first creator of the original dataset.
#' - **keywords**: Keywords of the original dataset.
#' - **alternative identifier**: DOI of the original dataset. This way, no new
#'   DOI will be created when publishing to GBIF.
#' - **external link** and **alternative identifier**: URL created from
#'   `study_id` or the first "derived from" related identifier in the original
#'   dataset.
#'
#' To be set manually in the GBIF IPT: **type**, **subtype**,
#' **update frequency**, and **publishing organization**.
#'
#' Not set: geographic, taxonomic, temporal coverage, associated parties,
#' project data, sampling methods, and citations.
#' Not applicable: collection data.
#'
#' @section Data:
#' `package` is expected to contain a `reference-data` and `gps` resource.
#' Data are transformed into an [Occurrence core](https://rs.gbif.org/core/dwc_occurrence_2022-02-02.xml).
#' This **follows recommendations** discussed and created by Peter Desmet,
#' Sarah Davidson, John Wieczorek and others.
#' See the [SQL file(s)](https://github.com/inbo/movepub/tree/main/inst/sql)
#' used by this function for details.
#'
#' Key features of the Darwin Core transformation:
#' - Deployments (animal+tag associations) are parent events, with tag
#'   attachment (a human observation) and GPS positions (machine observations)
#'   as child events.
#'   No information about the parent event is provided other than its ID,
#'   meaning that data can be expressed in an Occurrence Core with one row per
#'   observation and `parentEventID` shared by all occurrences in a deployment.
#' - The tag attachment event often contains metadata about the animal (sex,
#'   lifestage, comments) and deployment as a whole.
#' - No event/occurrence is created for the deployment end, since the end date
#'   is often undefined, unreliable and/or does not represent an animal
#'   occurrence.
#' - Only `visible` (nonoutlier) GPS records that fall within a deployment are
#'   included.
#' - GPS positions are downsampled to the **first GPS position per hour**, to
#'   reduce the size of high-frequency data.
#'   It is possible for a deployment to contain no GPS positions, e.g. if the
#'   tag malfunctioned right after deployment.
#' @examples
#' \dontrun{
#' write_dwc(o_assen)
#' }
write_dwc <- function(package, directory = ".", doi = package$id,
                      contact = NULL, rights_holder = NULL, study_id = NULL) {
  # Retrieve metadata from DataCite and build EML
  if (is.null(doi)) {
    cli::cli_abort(c(
      "Can't find a DOI in {.field package$id}.",
      "i" = "Provide one in {.arg doi}."
    ))
  }
  if (!is.character(doi) || length(doi) != 1) {
    cli::cli_abort(c(
      "{.arg doi} must be a character (vector of length one).",
      "x" = "{.val {doi}} is {.type {doi}}."
    ))
  }
  eml <- datacite_to_eml(doi)

  # Update title
  title <- paste(eml$dataset$title, "[subsampled representation]")
  eml$dataset$title <- title
  dataset_name <- title # Used in DwC

  # Update license
  license <- eml$dataset$intellectualRights$rightsUri # Used in DwC
  if (is.null(license)) {
    license <- NA_character_
  }
  license_code <- eml$dataset$intellectualRights$rightsIdentifier
  eml$dataset$intellectualRights <- NULL # Remove original license elements that make EML invalid
  eml$dataset$intellectualRights$para <- license_code

  # Get DOI URL
  doi_url <- eml$dataset$alternateIdentifier[[1]]
  dataset_id <- doi_url # Used in DwC
  if (is.null(dataset_id)) {
    dataset_id <- NA_character_
  }

  # Get/set study url
  study_url_prefix <- "https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study"
  if (!is.null(study_id)) {
    # Provided as parameter
    study_url <- paste0(study_url_prefix, study_id)
    eml$dataset$alternateIdentifier[[2]] <- study_url # Set as second identifier
  } else {
    # Get from first "derived from" related identifier (2nd alternateIdentifier)
    study_url <- eml$dataset$alternateIdentifier[[2]]
    study_id <- if (!is.null(study_url)) {
      gsub(study_url_prefix, "", study_url, fixed = TRUE)
    } else {
      NA_character_
    }
  }
  if (!grepl("^\\d+$", study_id)) { # Works for non 32 bit integers
    cli::cli_abort(c(
      "{.arg study_id} must be an integer.",
      "x" = "{.val {study_id}} is {.obj {study_id}}."
    ))
  }

  # Add extra paragraph to description
  first_author <- eml$dataset$creator[[1]]$individualName$surName
  pub_year <- substr(eml$dataset$pubDate, 1, 4)
  first_para <- paste(
    # Add span to circumvent https://github.com/ropensci/EML/issues/342
    "<span></span>This animal tracking dataset is derived from ",
    first_author, " et al. (", pub_year,
    ", <a href=\"", doi_url, "\">", doi_url, "</a>), ",
    "a deposit of Movebank study <a href=\"", study_url, "\">", study_id,
    "</a>. ", "Data have been standardized to Darwin Core using the ",
    "<a href=\"https://inbo.github.io/movepub/\">movepub</a> R package ",
    "and are downsampled to the first GPS position per hour. ",
    "The original dataset description follows.",
    sep = ""
  )
  eml$dataset$abstract$para <- append(
    after = 0,
    eml$dataset$abstract$para,
    paste0("<![CDATA[", first_para, "]]>")
  )

  # Update contact and set metadata provider
  if (!is.null(contact)) {
    if (!inherits(contact, "person")) {
      cli::cli_abort(c(
        "{.arg contact} must be person as provided by {.fn person}.",
        "x" = "{.val {contact}} is {.type {contact}}."
      ))
    }
    eml$dataset$contact <- EML::set_responsibleParty(
      givenName = contact$given,
      surName = contact$family,
      electronicMailAddress = contact$email,
      userId = if (!is.null(contact$comment[["ORCID"]])) {
        list(directory = "https://orcid.org/", contact$comment[["ORCID"]])
      } else {
        NULL
      }
    )
  }
  eml$dataset$metadataProvider <- eml$dataset$contact

  # Set external link to Movebank study URL
  if (!is.null(study_url)) {
    eml$dataset$distribution <- list(
      scope = "document", online = list(
        url = list("function" = "information", study_url)
      )
    )
  }

  # Set rights_holder
  if (is.null(rights_holder)) {
    rights_holder <- NA_character_
  }

  # Read data from package
  cli::cli_h2("Reading data")
  if (!"reference-data" %in% frictionless::resources(package)) {
    cli::cli_abort("{.arg package} must contain resource {.val reference-data}.")
  }
  if (!"gps" %in% frictionless::resources(package)) {
    cli::cli_abort("{.arg package} must contain resource {.val gps}.")
  }
  ref <- frictionless::read_resource(package, "reference-data")
  gps <- frictionless::read_resource(package, "gps")

  # Expand data with all columns used in DwC mapping
  ref_cols <- c(
    "animal-id", "animal-life-stage", "animal-nickname",
    "animal-reproductive-condition", "animal-sex", "animal-taxon",
    "attachment-type", "deploy-on-date", "deploy-on-latitude",
    "deploy-on-longitude", "deployment-comments", "manipulation-type", "tag-id",
    "tag-manufacturer-name", "tag-model"
  )
  ref <- expand_cols(ref, ref_cols)
  gps_cols <- c(
    "comments", "event-id", "height-above-ellipsoid", "height-above-msl",
    "individual-local-identifier", "individual-taxon-canonical-name",
    "location-error-numerical", "location-lat", "location-long", "sensor-type",
    "tag-local-identifier", "timestamp", "visible"
  )
  gps <- expand_cols(gps, gps_cols)

  # Lookup AphiaIDs for taxa
  names <- dplyr::pull(dplyr::distinct(ref, .data$`animal-taxon`))
  taxa <- get_aphia_id(names)
  cli::cli_alert_info("Taxa found in reference data and their WoRMS AphiaID:")
  cli::cli_dl(dplyr::pull(taxa, .data$aphia_id, .data$name))

  # Data transformation to Darwin Core
  dwc_occurrence <- ref %>%
    dplyr::filter(!is.null(.data$`deploy-on-date`)) %>%
    dplyr::mutate(
      # RECORD LEVEL
      basisOfRecord = "HumanObservation",
      dataGeneralizations = NA_character_,
      # OCCURRENCE
      occurrenceID = paste(.data$`animal-id`, .data$`tag-id`, "start", sep = "_"), # Same as EventID
      sex = dplyr::case_when(
        `animal-sex` == "m" ~ "male",
        `animal-sex` == "f" ~ "female",
        `animal-sex` == "u" ~ "unknown"
      ),
      lifeStage = .data$`animal-life-stage`,
      reproductiveCondition = as.logical(.data$`animal-reproductive-condition`),
      occurrenceStatus = "present",
      # ORGANISM
      organismID = .data$`animal-id`,
      organismName = .data$`animal-nickname`,
      # EVENT
      eventID = paste(.data$`animal-id`, .data$`tag-id`, "start", sep = "_"),
      parentEventID = paste(.data$`animal-id`, .data$`tag-id`, sep = "_"),
      eventType = "tag attachment",
      eventDate = format(
        .data$`deploy-on-date`,
        format = "%Y-%m-%dT%H:%M:%SZ"
      ),
      samplingProtocol = "tag attachment",
      eventRemarks = paste( # Problems with NA ####
        dplyr::coalesce(
          paste2(c(.data$`tag-manufacturer-name`, .data$`tag-model`, "tag")
          ),
          paste2(c(.data$`tag-manufacturer-name`, "tag")),
          "tag"
        ),
        dplyr::coalesce(
          paste2(c("attached by", .data$`attachment-type`, "to")),
          "attached to"
        ),
        dplyr::case_when(
          `manipulation-type` == "none" ~ "free-ranging animal",
          `manipulation-type` == "confined" ~ "confined animal",
          `manipulation-type` == "recolated" ~ "relocated animal",
          `manipulation-type` == "manipulated other" ~ "manipulated animal",
          .default = "likely free-ranging animal"
        ),
        dplyr::coalesce(
          paste2(c("|", .data$`deployment-comments`)),
          "",
        )
      ),
      # LOCATION
      minimumElevationInMeters = NA_integer_,
      maximumElevationInMeters = NA_integer_,
      locationRemarks = NA_character_,
      decimalLatitude = .data$`deploy-on-latitude`,
      decimalLongitude = .data$`deploy-on-longitude`,
      geodeticDatum = dplyr::case_when(
        !is.null(.data$`deploy-on-latitude`) ~ "EPSG:4326"
      ),
      coordinateUncertaintyInMeters = dplyr::case_when(
        # Assume coordinate precision of 0.001 degree (157m) and recording by GPS (30m)
        !is.null(.data$`deploy-on-latitude`) ~ 187
      ),
      # TAXON
      scientificName = `animal-taxon`,
      kingdom = "Animalia",
      .keep = "none"
    ) %>%
    dplyr::left_join(
      taxa %>%
        dplyr::mutate(
          scientificNameID = .data$aphia_lsid,
          scientificName = .data$name,
          .keep = "none"
        ),
      by = "scientificName"
    ) %>%
    dplyr::relocate(
      .data$scientificNameID,
      .before = .data$scientificName
    ) %>%
    # GPS POSITIONS
    dplyr::union_all(
      gps %>%
        # Exclude outliers & (rare) empty coordinates
        dplyr::filter(visible & !is.null(.data$`location-lat`)) %>%
        dplyr::mutate(
          timePerHour = strftime(timestamp, "%y-%m-%d %H %Z", tz = "UTC")
        ) %>%
        # Group by animal+tag+date+hour combination
        dplyr::group_by(
          .data$`individual-local-identifier`,
          .data$`tag-local-identifier`,
          .data$timePerHour
        ) %>%
        dplyr::arrange(.data$timestamp) %>%
        dplyr::mutate(subsampleCount = dplyr::n()) %>%
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
        dplyr::filter(!is.null(`animal-taxon`)) %>%
        dplyr::left_join(
          taxa,
          by = dplyr::join_by("animal-taxon" == "name")
        ) %>%
        dplyr::mutate(
          # RECORD-LEVEL
          basisOfRecord = "MachineObservation",
          dataGeneralizations = paste(
            "subsampled by hour: first of", subsampleCount, "record(s)"
          ),
          # OCCURRENCE
          occurrenceID = as.character(.data$`event-id`),
          sex = dplyr::case_when(
            .data$`animal-sex` == "m" ~ "male",
            .data$`animal-sex` == "f" ~ "female",
            .data$`animal-sex` == "u" ~ "unknown"
          ),
          lifeStage = NA_character_, # Value at start of deployment might not apply to all records
          reproductiveCondition = NA, # Value at start of deployment might not apply to all records
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
          eventDate = format(
            .data$timestamp,
            format = "%Y-%m-%dT%H:%M:%SZ"
          ),
          samplingProtocol = .data$`sensor-type`,
          eventRemarks = dplyr::coalesce(.data$`comments`, ""),
          # LOCATION
          minimumElevationInMeters =
            dplyr::coalesce(
              .data$`height-above-msl`,
              as.numeric(.data$`height-above-ellipsoid`), NA_integer_
            ),
          maximumElevationInMeters =
            dplyr::coalesce(
              .data$`height-above-msl`,
              as.numeric(.data$`height-above-ellipsoid`), NA_integer_
            ),
          locationRemarks = dplyr::case_when(
            !is.null(.data$`height-above-msl`) ~
              "elevations are altitude above mean sea level",
            !is.null(.data$`height-above-ellipsoid`) ~
              "elevations are altitude above above" # ???? 2 times above in SQL file
          ),
          decimalLatitude = .data$`location-lat`,
          decimalLongitude = .data$`location-long`,
          geodeticDatum = "EPSG:4326",
          coordinateUncertaintyInMeters = .data$`location-error-numerical`,
          # TAXON
          scientificNameID = .data$aphia_lsid,
          scientificName = .data$`animal-taxon`,
          kingdom = "Animalia",
          .keep = "none",
          subsampleCount = NULL,
          # timePerHour = NULL
        )
    ) %>%
    dplyr::mutate(
      # DATASET-LEVEL
      type = "Event",
      license = license,
      rightsHolder = as.logical(rights_holder),
      datasetID = dataset_id,
      institutionCode = "MPIAB", # Max Planck Institute of Animal Behavior
      collectionCode = "Movebank",
      datasetName = dataset_name,
      .before = "basisOfRecord"
    ) %>%
    dplyr::arrange(
      parentEventID,
      eventDate
    )

  # Create database
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  DBI::dbWriteTable(con, "reference_data", ref)
  DBI::dbWriteTable(con, "gps", gps)
  DBI::dbWriteTable(con, "taxa", taxa)
  cli::cli_h2("Transforming data to Darwin Core")

  # Query database
  dwc_occurrence_sql <- glue::glue_sql(
    readr::read_file(
      system.file("sql/dwc_occurrence.sql", package = "movepub")
    ),
    .con = con
  )
  dwc_occurrence2 <- DBI::dbGetQuery(con, dwc_occurrence_sql)
  DBI::dbDisconnect(con)

  # Write files
  eml_path <- file.path(directory, "eml.xml")
  dwc_occurrence_path <- file.path(directory, "dwc_occurrence.csv")
  cli::cli_h2("Writing files")
  cli::cli_ul(c(
    "{.file {eml_path}}",
    "{.file {dwc_occurrence_path}}"
  ))
  if (!dir.exists(directory)) {
    dir.create(directory, recursive = TRUE)
  }
  EML::write_eml(eml, eml_path)
  readr::write_csv(dwc_occurrence, dwc_occurrence_path, na = "")
}
