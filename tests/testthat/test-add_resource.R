test_that("add_resource() returns a valid Data Package", {
  skip_if_offline()
  package <- o_assen
  reference_data <- file.path(
    "https://datarepository.movebank.org/server/api/core/bitstreams",
    "a6e123b0-7588-40da-8f06-73559bb3ff6b/content"
  )
  package <- remove_resource(package, "reference-data")

  expect_no_error(
    frictionless::check_package(
      add_resource(package, "reference-data", reference_data)
    )
  )
})

test_that("add_resource() returns error on invalid Data Package", {
  skip_if_offline()
  reference_data <- file.path(
    "https://datarepository.movebank.org/server/api/core/bitstreams",
    "a6e123b0-7588-40da-8f06-73559bb3ff6b/content"
  )

  expect_error(
    add_resource(list(), "reference-data", reference_data),
    class = "frictionless_error_package_invalid"
  )
})

test_that("add_resource() returns error on invalid resource name", {
  skip_if_offline()
  package <- o_assen
  reference_data <- file.path(
    "https://datarepository.movebank.org/server/api/core/bitstreams",
    "a6e123b0-7588-40da-8f06-73559bb3ff6b/content"
  )

  expect_error(
    add_resource(package, "not_a_resource_name", reference_data),
    class = "movepub_error_resource_name_invalid"
  )
  expect_error(
    add_resource(package, "REFERENCE DATA", reference_data),
    class = "movepub_error_resource_name_invalid"
  )
  expect_error(
    add_resource(package, "reference_data", reference_data),
    class = "movepub_error_resource_name_invalid"
  )
})

test_that("add_resource() adds resource with skos:exactMatch references to the
           Movebank Attribute Dictionary, primary keys and foreign keys", {
  skip_if_offline()
  # Dataset: https://doi.org/10.5441/001/1.5k6b1364
  reference_data <- file.path(
    "https://datarepository.movebank.org/server/api/core/bitstreams",
    "a6e123b0-7588-40da-8f06-73559bb3ff6b/content"
  )
  gps_data <- file.path(
    "https://datarepository.movebank.org/server/api/core/bitstreams",
    "df28a80e-e0c4-49fb-aa87-76ceb2d2b76f/content"
  )
  package <-
    create_package() |>
    add_resource("reference-data", reference_data) |>
    add_resource("gps", gps_data)
  temp_dir <- file.path(tempdir(), "package")
  on.exit(unlink(temp_dir, recursive = TRUE))
  write_package(package, temp_dir)

  expect_snapshot_file(file.path(temp_dir, "datapackage.json"))
})
