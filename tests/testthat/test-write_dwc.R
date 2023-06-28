dir.create(file.path(tempdir()), "movepub")
temp_dir <- file.path(tempdir(), "movepub")
test_that("write_dwc() writes csv file to a path", {
  expect_true(file.exists(file.path(temp_dir, "dwc_occurrence.csv")))
})

test_that("write_dwc() writes EML file to a path", {
  expect_true(file.exists(file.path(temp_dir, "eml.xml")))
})
