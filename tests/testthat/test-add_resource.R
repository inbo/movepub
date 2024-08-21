test_that("add_resource() returns error on invalid resource names", {
  skip_if_offline()
  package <- o_assen
  df <- data.frame("col_1" = c(1, 2), "col_2" = c("a", "b"))
  expect_error(
    add_resource(package, "not_a_resource_name", df),
    class = "movepub_error_invalid_resource_names"
  )
  expect_error(
    add_resource(package, "GPS", df),
    class = "movepub_error_invalid_resource_names"
  )
  expect_error(
    add_resource(package, "reference_data", df),
    class = "movepub_error_invalid_resource_names"
  )
})

test_that("add_resource() returns a valid Data Package", {
  skip_if_offline()
  package <- o_assen
  gps_data <- "https://datarepository.movebank.org/server/api/core/bitstreams/df28a80e-e0c4-49fb-aa87-76ceb2d2b76f/content"
  package <- remove_resource(package, "gps")
  expect_no_error(frictionless::check_package(
      add_resource(package = package, resource_name = "gps", files = gps_data)
      ))
})

test_that("add_resource() returns error on invalid Data Package", {
  skip_if_offline()
  gps_data <- "https://datarepository.movebank.org/server/api/core/bitstreams/df28a80e-e0c4-49fb-aa87-76ceb2d2b76f/content"
  expect_error(
    add_resource(list(), "gps", gps_data),
    class = "frictionless_error_package_invalid"
  )
})

test_that("add_resource() adds resource", {
  skip_if_offline()
  gps_data <- "https://datarepository.movebank.org/server/api/core/bitstreams/df28a80e-e0c4-49fb-aa87-76ceb2d2b76f/content"
  doi <- "https://doi.org/10.5441/001/1.5k6b1364"
  package <-
    create_package() %>%
    append(c(id = doi), after = 0) %>%
    create_package() %>% # Bug fix for https://github.com/frictionlessdata/frictionless-r/issues/198
    add_resource("gps", gps_data)
  expect_identical(package$resources[[1]][["name"]], "gps")
  expect_identical(package$resources[[1]][["profile"]], "tabular-data-resource")
  expect_identical(resources(package), "gps")
})
