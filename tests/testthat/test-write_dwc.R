# Create temporary files
temp_dir <- file.path(tempdir(), "movepub")
dir.create(temp_dir)

test_that("write_dwc() returns expected files", {
  expect_snapshot_file(
    write_dwc_snapshot(o_assen, temp_dir, file = "occurrence"),
    transform = remove_UUID
  )
  expect_snapshot_file(
    write_dwc_snapshot(o_assen, temp_dir, file = "eml"),
    transform = remove_UUID
  )
})

test_that("write_dwc() returns expected messages" , {
  expect_message(
    write_dwc(o_assen, temp_dir),
    "Transforming data to Darwin Core", # Part of the messages
    fixed = FALSE
  )

  expect_message(
    write_dwc(o_assen, temp_dir),
    "Haematopus ostralegus: 147436", # Inform on AphiaID matching
    fixed = FALSE
  )
})

test_that("write_dwc() returns the expected Darwin Core terms as columns", {
  expect_named(
    readr::read_csv(
      file.path(temp_dir, "dwc_occurrence.csv"),
      n_max = 1,
      show_col_types = FALSE
    ),
    c(
      "type",
      "license",
      "rightsHolder",
      "datasetID",
      "institutionCode",
      "collectionCode",
      "datasetName",
      "basisOfRecord",
      "dataGeneralizations",
      "occurrenceID",
      "sex",
      "lifeStage",
      "reproductiveCondition",
      "occurrenceStatus",
      "organismID",
      "organismName",
      "eventID",
      "parentEventID",
      "eventType",
      "eventDate",
      "samplingProtocol",
      "eventRemarks",
      "minimumElevationInMeters",
      "maximumElevationInMeters",
      "locationRemarks",
      "decimalLatitude",
      "decimalLongitude",
      "geodeticDatum",
      "coordinateUncertaintyInMeters",
      "scientificNameID",
      "scientificName",
      "kingdom"
    )
  )
})

test_that("write_dwc() returns error on invalid study_id", {
  expect_error(
    write_dwc(o_assen, temp_dir, study_id = "NOT_A_VALID_STUDY_ID"),
    regexp = "`study_id` (NOT_A_VALID_STUDY_ID) must be an integer.",
    fixed = TRUE
  )
  expect_error(
    write_dwc(o_assen, temp_dir, study_id = c("4", pi)),
    regexp = "more elements supplied than there are to replace",
    fixed = TRUE
  )
})

test_that("write_dwc() supports setting custom study_id", {
  suppressMessages(
    write_dwc(o_assen, file.path(temp_dir, "study_id"), study_id = 42)
  )
  eml <- EML::read_eml(file.path(temp_dir, "study_id", "eml.xml"))
  expect_true(grepl(42, x = eml$dataset$alternateIdentifier[[2]]))
})

test_that("write_dwc() returns error on invalid contact information", {
  expect_error(
    write_dwc(o_assen, temp_dir, contact = list(not_a = "person_object")),
    regexp = "`contact` is a list, but should be a person as provided by `person()`",
    fixed = TRUE
  )
  expect_error(
    write_dwc( o_assen, temp_dir, contact = "pineapple"),
    regexp = "`contact` is a character, but should be a person as provided by `person()`",
    fixed = TRUE
  )
})

test_that("write_dwc() supports setting custom contact information", {
  suppressMessages(
    write_dwc(
      o_assen,
      file.path(temp_dir, "custom_contact"),
      contact = person(
        given = "Jean Luc",
        family = "Picard",
        email = "cptn@enterprise.trek",
        comment = c(ORCID = "0000-0001-2345-6789")
      )
    )
  )
  eml <- EML::read_eml(file.path(temp_dir, "custom_contact", "eml.xml"))
  expect_identical(
    eml$dataset$contact,
    list(
      individualName = list(givenName = "Jean Luc", surName = "Picard"),
      electronicMailAddress = "cptn@enterprise.trek", userId = list(
        directory = "https://orcid.org/", userId = "0000-0001-2345-6789"
      )
    )
  )

  # Test where custom contact information is provided, but no orcid
  suppressMessages(
    write_dwc(
      o_assen,
      file.path(temp_dir, "custom_contact_no_orcid"),
      contact = person(given = "Kathryn", family = "Janeway")
    )
  )
  eml <- EML::read_eml(file.path(temp_dir, "custom_contact_no_orcid", "eml.xml"))
  expect_identical(
    eml$dataset$contact,
    list(
      individualName = list(givenName = "Kathryn", surName = "Janeway")
    )
  )
})

test_that("write_dwc() returns error on missing or malformed doi", {
  package_no_doi <- o_assen
  package_no_doi$id <- NULL
  expect_error(
    write_dwc(package_no_doi, temp_dir),
    regexp = "No DOI found in `package$id`, provide one in `doi` parameter.",
    fixed = TRUE
  )
  expect_error(
    write_dwc(package_no_doi, temp_dir, doi = c("a", "b", "c")),
    regexp = "doi is not a string (a length one character vector).",
    fixed = TRUE
  )
  expect_error(
    write_dwc(package_no_doi, temp_dir, doi = 10.5281),
    regexp = "doi is not a string (a length one character vector).",
    fixed = TRUE
  )
})

test_that("write_dwc() returns error on missing resources", {
  # Create data package with no reference-data resource
  package_no_ref_data <-
    purrr::discard(o_assen$resources, ~ .x$name == "reference-data")

  expect_error(
    suppressMessages(
      write_dwc(package_no_ref_data, temp_dir, doi = "10.5281/zenodo.5653311")
    ),
    regexp = "`package` must contain resource `reference-data`.",
    fixed = TRUE
  )
  # Create package with no GPS resource
  package_no_gps <-
    purrr::discard(o_assen$resources, ~ .x$name == "gps")
  expect_error(
    suppressMessages(
      write_dwc(package_no_gps, temp_dir, doi = "10.5281/zenodo.5653311")
    ),
    regexp = "`package` must contain resource `reference-data`.",
    fixed = TRUE
  )
})

# Remove temporary files
unlink(temp_dir, recursive = TRUE)
