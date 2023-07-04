dir.create(file.path(tempdir()), "movepub")
temp_dir <- file.path(tempdir(), "movepub")

package_to_write <-
  suppressMessages(
    frictionless::read_package(
      system.file(
        "extdata",
        "o_assen",
        "datapackage.json",
        package = "movepub"
      )
    )
  )

test_that("write_dwc() returns expected files and messaging", {
  expect_snapshot(
    write_dwc(package_to_write, directory = temp_dir),
    transform = remove_temp_path
  )
  expect_true(file.exists(file.path(temp_dir, "dwc_occurrence.csv")))
  expect_true(file.exists(file.path(temp_dir, "eml.xml")))
})

test_that("write_dwc() returns the expected Darwin Core terms as columns", {
  expect_identical(
    colnames(readr::read_csv(file.path(temp_dir, "dwc_occurrence.csv"),
                             n_max = 1,
                             show_col_types = FALSE)),
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
      "scientificName",
      "kingdom"
    )
  )
})

test_that("write_dwc() returns the expected DwC mapping for a known dataset", {
  expect_snapshot_file(file.path(temp_dir,"dwc_occurrence.csv"),
                       transform = remove_temp_path)
  expect_snapshot_file(file.path(temp_dir,"eml.xml"),
                       transform = remove_UUID)
})

test_that("write_dwc() returns error on invalid study_id", {
  expect_error(
    write_dwc(package_to_write,
              directory = temp_dir,
              study_id = "<NOT_A_VALID_STUDY_ID>"),
    regexp = "`study_id` (<NOT_A_VALID_STUDY_ID>) must be an integer.",
    fixed = TRUE
  )
  expect_error(
    write_dwc(package_to_write,
              directory = temp_dir,
              study_id = c("4",pi)),
    regexp = "more elements supplied than there are to replace",
    fixed = TRUE
  )
})

test_that("write_dwc() supports setting custom study_id", {
  suppressMessages(
  write_dwc(package_to_write,
            directory = temp_dir,
            study_id = 42))
  eml <- EML::read_eml(file.path(temp_dir,"eml.xml"))
  expect_true(grepl(42,x = eml$dataset$alternateIdentifier[[2]]))
})

# remove temporary files
unlink(temp_dir, recursive = TRUE)
