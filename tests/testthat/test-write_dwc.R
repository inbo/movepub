test_that("write_dwc() returns error on missing or malformed doi", {
  x_no_doi <- o_assen
  x_no_doi$id <- NULL
  temp_dir <- file.path(tempdir(), "dwc")
  on.exit(unlink(temp_dir, recursive = TRUE))

  expect_error(
    write_dwc(x_no_doi, temp_dir),
    class = "movepub_error_doi_missing"
  )
  expect_error(
    write_dwc(x_no_doi, temp_dir, doi = c("a", "b", "c")),
    class = "movepub_error_doi_invalid"
  )
  expect_error(
    write_dwc(x_no_doi, temp_dir, doi = 10.5281),
    class = "movepub_error_doi_invalid"
  )
})

test_that("write_dwc() returns error on missing resources", {
  skip_if_offline()
  x_no_ref_data <-
    remove_resource(o_assen, "reference-data")
  x_no_gps <-
    remove_resource(o_assen, "gps")
  temp_dir <- file.path(tempdir(), "dwc")
  on.exit(unlink(temp_dir, recursive = TRUE))

  expect_error(
    suppressMessages(
      write_dwc(x_no_ref_data, temp_dir, doi = "10.5281/zenodo.5653311")
    ),
    class = "movepub_error_reference_data_missing"
  )
  expect_error(
    suppressMessages(
      write_dwc(x_no_gps, temp_dir, doi = "10.5281/zenodo.5653311")
    ),
    class = "movepub_error_gps_data_missing"
  )
})

test_that("write_dwc() writes CSV and meta.xml files to a directory and
           a list of data frames invisibly", {
  skip_if_offline()
  x <- o_assen
  temp_dir <- file.path(tempdir(), "dwc")
  on.exit(unlink(temp_dir, recursive = TRUE))
  result <- suppressMessages(write_dwc(x, temp_dir))

  expect_identical(
    list.files(temp_dir),
    c("emof.csv", "meta.xml", "occurrence.csv")
  )
  expect_identical(names(result), c("occurrence", "emof"))
  expect_s3_class(result$occurrence, "tbl")
  expect_s3_class(result$emof, "tbl")
})

test_that("write_dwc() returns the expected Darwin Core terms as columns", {
  skip_if_offline()
  x <- o_assen
  temp_dir <- file.path(tempdir(), "dwc")
  on.exit(unlink(temp_dir, recursive = TRUE))
  result <- suppressMessages(write_dwc(x, temp_dir))

  expect_identical(
    colnames(result$occurrence),
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
  expect_identical(
    colnames(result$emof),
    c(
      "occurrenceID",
      "measurementType",
      "measurementTypeID",
      "measurementValue",
      "measurementValueID",
      "measurementUnit",
      "measurementUnitID"
    )
  )
})

test_that("write_dwc() returns the expected Darwin Core mapping for the example
           dataset", {
  skip_if_offline()
  x <- o_assen
  temp_dir <- file.path(tempdir(), "dwc")
  on.exit(unlink(temp_dir, recursive = TRUE))
  suppressMessages(write_dwc(x, temp_dir))

  expect_snapshot_file(file.path(temp_dir, "occurrence.csv"))
  expect_snapshot_file(file.path(temp_dir, "emof.csv"))
  expect_snapshot_file(file.path(temp_dir, "meta.xml"))
})

test_that("write_dwc() returns files that comply with the info in meta.xml", {
  skip_if_offline()
  x <- o_assen
  temp_dir <- file.path(tempdir(), "dwc")
  on.exit(unlink(temp_dir, recursive = TRUE))
  suppressMessages(write_dwc(x, temp_dir))

  # Use helper function to compare
  expect_meta_match(file.path(temp_dir, "occurrence.csv"))
  expect_meta_match(file.path(temp_dir, "emof.csv"))
})
