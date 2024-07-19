test_that("write_eml() returns error on missing or malformed doi", {
  temp_dir <- file.path(tempdir(), "eml")
  on.exit(unlink(temp_dir, recursive = TRUE))

  expect_error(
    write_dwc(doi = NULL, temp_dir),
    class = "movepub_error_doi_missing"
  )
  expect_error(
    write_dwc(doi = c("a", "b", "c"), temp_dir),
    class = "movepub_error_doi_invalid"
  )
  expect_error(
    write_dwc(doi = 10.5281, temp_dir),
    class = "movepub_error_doi_invalid"
  )
})

test_that("write_eml() returns error on invalid study_id", {
  skip_if_offline()
  doi <- "10.5281/zenodo.10053903"
  expect_error(
    write_eml(doi, temp_dir, study_id = "not_a_study_id"),
    class = "movepub_error_study_id_invalid"
  )
  expect_error(
    write_eml(doi, temp_dir, study_id = c("4", pi)),
    "more elements supplied than there are to replace",
    fixed = TRUE
  )
})

test_that("write_eml() returns error on invalid contact", {
  skip_if_offline()
  doi <- "10.5281/zenodo.10053903"
  expect_error(
    write_eml(doi, temp_dir, contact = "not_a_contact"),
    class = "movepub_error_contact_invalid"
  )
  expect_error(
    write_eml(doi, temp_dir, contact = list(not_a = "person_object")),
    class = "movepub_error_contact_invalid"
  )
})

test_that("write_dwc() writes an eml.xml to a directory and returns eml
           invisibly", {
  skip_if_offline()
  doi <- "10.5281/zenodo.10053903"
  temp_dir <- file.path(tempdir(), "eml")
  on.exit(unlink(temp_dir, recursive = TRUE))
  result <- suppressMessages(write_eml(doi, temp_dir))

  expect_identical(list.files(temp_dir), c("eml.xml"))
  expect_identical(
    result$dataset$title,
    paste(
      "O_ASSEN - Eurasian oystercatchers (Haematopus ostralegus,",
      "Haematopodidae) breeding in Assen (the Netherlands)"
    )
  )
  expect_type(result, "list")
})

test_that("write_dwc() returns the expected Darwin Core mapping for the example
           dataset", {
  skip_if_offline()
  doi <- "10.5281/zenodo.10053903"
  temp_dir <- file.path(tempdir(), "eml")
  on.exit(unlink(temp_dir, recursive = TRUE))
  result <- suppressMessages(write_eml(doi, temp_dir))

  expect_snapshot_file(
    file.path(temp_dir, "eml.xml"),
    transform = remove_uuid
  )
})

test_that("write_eml() supports a custom study_id", {
  skip_if_offline()
  doi <- "10.5281/zenodo.10053903"
  temp_dir <- file.path(tempdir(), "eml")
  on.exit(unlink(temp_dir, recursive = TRUE))
  result <- suppressMessages(write_eml(doi, temp_dir, study_id = 42))

  expect_identical(
    result$dataset$alternateIdentifier[[2]],
    "https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study42"
  )
})

test_that("write_eml() supports a custom contact", {
  skip_if_offline()
  doi <- "10.5281/zenodo.10053903"
  temp_dir <- file.path(tempdir(), "eml")
  on.exit(unlink(temp_dir, recursive = TRUE))
  result <- suppressMessages(write_eml(
    doi,
    temp_dir,
    contact = person(
      given = "Jean Luc",
      family = "Picard",
      email = "cptn@enterprise.trek",
      comment = c(ORCID = "0000-0001-2345-6789")
    )
  ))

  expect_identical(
    result$dataset$contact$individualName,
    list(givenName = "Jean Luc", surName = "Picard")
  )
  expect_identical(
    result$dataset$contact$electronicMailAddress,
    "cptn@enterprise.trek"
  )
  expect_identical(
    result$dataset$contact$userId,
    list(directory = "https://orcid.org/", "0000-0001-2345-6789")
  )
})

test_that("write_eml() supports disabling the derived paragraph", {
  skip_if_offline()
  doi <- "10.5281/zenodo.10053903"
  temp_dir <- file.path(tempdir(), "eml")
  on.exit(unlink(temp_dir, recursive = TRUE))
  result <- suppressMessages(
    write_eml(doi, temp_dir, derived_paragraph = FALSE)
  )

  expect_error(result$dataset$abstract$para[[3]]) # Subscript out of bounds
})
