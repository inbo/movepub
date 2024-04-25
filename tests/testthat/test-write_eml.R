# Create temporary files
temp_dir <- file.path(tempdir(), "movepub")
dir.create(temp_dir)

test_that("write_eml() returns expected files", {
  expect_snapshot_file(
    write_eml_snapshot(o_assen, temp_dir, file = "eml"),
    transform = remove_UUID
  )
  expect_snapshot_file(
    write_eml_snapshot(
      doi = "10.5281/zenodo.10053903",
      directory = temp_dir,
      file = "eml"),
    transform = remove_UUID
  )
})

test_that("write_eml() returns error on missing or malformed doi", {
  package_no_doi <- o_assen
  package_no_doi$id <- NULL
  expect_error(
    write_eml(package_no_doi, temp_dir),
    class = "movepub_error_doi_missing"
  )
  expect_error(
    write_eml(package_no_doi, temp_dir, doi = c("a", "b", "c")),
    class = "movepub_error_doi_invalid"
  )
  expect_error(
    write_eml(package_no_doi, temp_dir, doi = 10.5281),
    class = "movepub_error_doi_invalid"
  )
})

test_that("write_eml() returns error on invalid study_id", {
  expect_error(
    write_eml(o_assen, temp_dir, study_id = "not_a_study_id"),
    class = "movepub_error_study_id_invalid"
  )
  expect_error(
    write_eml(o_assen, temp_dir, study_id = c("4", pi)),
    "more elements supplied than there are to replace",
    fixed = TRUE
  )
})

test_that("write_eml() supports setting custom study_id", {
  suppressMessages(
    write_eml(o_assen, file.path(temp_dir, "study_id"), study_id = 42)
  )
  eml <- EML::read_eml(file.path(temp_dir, "study_id", "eml.xml"))
  expect_true(grepl(42, x = eml$dataset$alternateIdentifier[[2]]))
})

test_that("write_eml() returns error on invalid contact information", {
  expect_error(
    write_eml(o_assen, temp_dir, contact = list(not_a = "person_object")),
    class = "movepub_error_contact_invalid"
  )
  expect_error(
    write_eml(o_assen, temp_dir, contact = "pineapple"),
    class = "movepub_error_contact_invalid"
  )
})

test_that("write_eml() supports setting custom contact information", {
  suppressMessages(
    write_eml(
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
    write_eml(
      o_assen,
      file.path(temp_dir, "custom_contact_no_orcid"),
      contact = person(given = "Kathryn", family = "Janeway")
    )
  )
  eml <- EML::read_eml(
    file.path(temp_dir, "custom_contact_no_orcid", "eml.xml")
    )
  expect_identical(
    eml$dataset$contact,
    list(
      individualName = list(givenName = "Kathryn", surName = "Janeway")
    )
  )
})

# Remove temporary files
unlink(temp_dir, recursive = TRUE)
