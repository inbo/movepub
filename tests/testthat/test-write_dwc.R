# Create temporary files
temp_dir <- file.path(tempdir(), "dwc")
dir.create(temp_dir)

test_that("write_dwc() returns expected files", {
  expect_snapshot_file(
    write_dwc_snapshot(o_assen, temp_dir, file = "occurrence"),
    transform = remove_UUID
  )
})

test_that("write_dwc() returns expected messages" , {
  # One of the headings
  expect_message(
    write_dwc(o_assen, temp_dir),
    "Transforming data to Darwin Core",
    fixed = TRUE
  )

  # AphiaID matching
  expect_message(
    write_dwc(o_assen, temp_dir),
    "Haematopus ostralegus: 147436",
    fixed = TRUE
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

test_that("write_dwc() returns error on missing or malformed doi", {
  package_no_doi <- o_assen
  package_no_doi$id <- NULL
  expect_error(
    write_dwc(package_no_doi, temp_dir),
    class = "movepub_error_doi_missing"
  )
  expect_error(
    write_dwc(package_no_doi, temp_dir, doi = c("a", "b", "c")),
    class = "movepub_error_doi_invalid"
  )
  expect_error(
    write_dwc(package_no_doi, temp_dir, doi = 10.5281),
    class = "movepub_error_doi_invalid"
  )
})

test_that("write_dwc() returns error on missing resources", {
  # Create data package with no reference-data resource
  package_no_ref_data <-
    frictionless::remove_resource(o_assen, "reference-data")

  expect_error(
    suppressMessages(
      write_dwc(package_no_ref_data, temp_dir, doi = "10.5281/zenodo.5653311")
    ),
    class = "movepub_error_reference_data_missing"
  )

  # Create package with no GPS resource
  package_no_gps <-
    frictionless::remove_resource(o_assen, "gps")
  expect_error(
    suppressMessages(
      write_dwc(package_no_gps, temp_dir, doi = "10.5281/zenodo.5653311")
    ),
    class = "movepub_error_gps_data_missing"
  )
})

# Remove temporary files
unlink(temp_dir, recursive = TRUE)
