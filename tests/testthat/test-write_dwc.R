dir.create(file.path(tempdir()), "movepub")
temp_dir <- file.path(tempdir(), "movepub")
test_that("write_dwc() writes csv file to a path", {
  expect_true(file.exists(file.path(temp_dir, "dwc_occurrence.csv")))
})

test_that("write_dwc() writes EML file to a path", {
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

test_that("write_dwc() returns the expected Darwin Core mapping for a known dataset", {
  expect_snapshot_file(file.path(temp_dir,"dwc_occurrence.csv"),
                       transform = ~gsub("\\/tmp\\/[a-zA-Z]+\\/movepub","path"))
  expect_snapshot_file(file.path(temp_dir,"eml.xml"),
                       transform = ~gsub("\\/tmp\\/[a-zA-Z]+\\/movepub","path"))
})

test_that("write_dwc() returns expected messaging to console", {

})

