test_that("write_dwc() returns error on missing resources", {
  skip_if_offline()
  temp_dir <- tempdir()
  on.exit(unlink(temp_dir, recursive = TRUE))

  # Create datasets with missing resource
  x_no_ref_data <- remove_resource(o_assen, "reference-data")
  x_no_gps <- remove_resource(o_assen, "gps")

  expect_error(
    suppressMessages(
      write_dwc(x_no_ref_data, temp_dir)
    ),
    class = "movepub_error_ref_data_missing"
  )
  expect_error(
    suppressMessages(
      write_dwc(x_no_gps, temp_dir)
    ),
    class = "movepub_error_gps_data_missing"
  )
})

test_that("write_dwc() returns error on missing required fields", {
  skip_if_offline()
  temp_dir <- tempdir()
  on.exit(unlink(temp_dir, recursive = TRUE))

  # Create dataset with missing cols
  ref <- read_resource(o_assen, "reference-data")
  gps <- read_resource(o_assen, "gps")
  x_missing_ref_cols <-
    create_package() |>
    frictionless::add_resource("reference-data", iris) |>
    frictionless::add_resource("gps", gps)
  x_missing_gps_cols <-
    create_package() |>
    frictionless::add_resource("reference-data", ref) |>
    frictionless::add_resource("gps", iris)
  temp_dir <- tempdir()
  on.exit(unlink(temp_dir, recursive = TRUE))

  expect_error(
    suppressMessages(
      write_dwc(x_missing_ref_cols, temp_dir)
    ),
    class = "movepub_error_ref_cols_missing"
  )
  expect_error(
    suppressMessages(
      write_dwc(x_missing_gps_cols, temp_dir)
    ),
    class = "movepub_error_gps_cols_missing"
  )
})

test_that("write_dwc() writes CSV and meta.xml files to a directory and
           a list of data frames invisibly", {
  skip_if_offline()
  x <- o_assen
  temp_dir <- tempdir()
  on.exit(unlink(temp_dir, recursive = TRUE))
  result <- suppressMessages(write_dwc(x, temp_dir))

  expect_contains(
    list.files(temp_dir),
    c("emof.csv", "meta.xml", "occurrence.csv")
  )
  expect_identical(names(result), c("occurrence", "emof"))
  expect_s3_class(result$occurrence, "tbl")
  expect_s3_class(result$emof, "tbl")
  expect_invisible(suppressMessages(write_dwc(x, temp_dir)))
})

test_that("write_dwc() returns the expected Darwin Core terms as columns", {
  skip_if_offline()
  x <- o_assen
  temp_dir <- tempdir()
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
  temp_dir <- tempdir()
  on.exit(unlink(temp_dir, recursive = TRUE))
  suppressMessages(write_dwc(x, temp_dir))

  expect_snapshot_file(file.path(temp_dir, "occurrence.csv"))
  expect_snapshot_file(file.path(temp_dir, "emof.csv"))
  expect_snapshot_file(file.path(temp_dir, "meta.xml"))
})

test_that("write_dwc() returns files that comply with the info in meta.xml", {
  skip_if_offline()
  x <- o_assen
  temp_dir <- tempdir()
  on.exit(unlink(temp_dir, recursive = TRUE))
  suppressMessages(write_dwc(x, temp_dir))

  # Use helper function to compare
  expect_meta_match(file.path(temp_dir, "occurrence.csv"))
  expect_meta_match(file.path(temp_dir, "emof.csv"))
})

test_that("write_dwc() supports custom dataset id, name, license, rights_holder", {
  skip_if_offline()
  x <- o_assen
  temp_dir <- tempdir()
  on.exit(unlink(temp_dir, recursive = TRUE))
  result <- suppressMessages(write_dwc(
    x,
    temp_dir,
    dataset_id = "custom_dataset_id",
    dataset_name = "custom_dataset_name",
    license = "custom_license",
    rights_holder = "custom_rights_holder"
  ))

  dataset_id <- purrr::pluck(result, "occurrence", "datasetID", 1)
  dataset_name <- purrr::pluck(result, "occurrence", "datasetName", 1)
  license <- purrr::pluck(result, "occurrence", "license", 1)
  rights_holder <- purrr::pluck(result, "occurrence", "rightsHolder", 1)

  expect_identical(dataset_id, "custom_dataset_id")
  expect_identical(dataset_name, "custom_dataset_name")
  expect_identical(license, "custom_license")
  expect_identical(rights_holder, "custom_rights_holder")

  # Note: if not set, the function will default to package properties.
  # Those are present in o_assen and tested with the snapshot file.
})
