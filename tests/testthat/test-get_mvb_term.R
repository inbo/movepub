test_that("get_mvb_term() returns information about at term", {
  skip_if_offline()
  expected_info <- list(
    id = "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/",
    identifier = "SDN:MVB::MVB000016",
    prefLabel = "animal ID",
    altLabel = "individual local identifier",
    definition = paste(
      "An individual identifier for the animal, provided by the data owner.",
      "Values are unique within the study. If the data owner does not provide",
      "an Animal ID, an internal Movebank animal identifier is sometimes shown.",
      "Example: 'TUSC_CV5'; Units: none; Entity described: individual"
    ),
    date = "2022-08-15 10:20:18.0",
    version = "3",
    hasCurrentVersion = "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/3/",
    hasVersion = c(
      "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/1/",
      "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/2/"
    ),
    deprecated = "false",
    note = "accepted"
  )
  expect_identical(get_mvb_term("animal ID"), expected_info)
})

test_that("get_mvb_term() returns term with prefLabel first", {
  skip_if_offline()
  label <- "individual local identifier"
  expect_identical(get_mvb_term(label)$prefLabel, label)
  # Not term http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/ with
  # animal ID as pref label
})

test_that("get_mvb_term() returns term with altLabel too", {
  skip_if_offline()
  expect_identical(
    get_mvb_term("deploy on timestamp"), # prefLabel
    get_mvb_term("deploy on date") # altLabel
  )
})

test_that("get_mvb_term() ignores case and converts to space", {
  skip_if_offline()
  expect_identical(
    get_mvb_term("ANIMAL-exact_date.of:birth")$prefLabel,
    "animal exact date of birth"
  )
})

test_that("get_mvb_terms() makes use of MVB version 4 changes", {
  skip_if_offline()
  # See https://github.com/inbo/movepub/issues/28
  expect_identical(
    get_mvb_term("magnetic field raw x"),
    get_mvb_term("mag magnetic field raw x")
  )
  expect_identical(
    get_mvb_term("light level"),
    get_mvb_term("gls light level")
  )
  expect_identical(
    get_mvb_term("Ornitela transmission protocol"),
    get_mvb_term("orn transmission protocol")
  )
  expect_identical(
    get_mvb_term("behavior according to"),
    get_mvb_term("behaviour according to")
  )
  expect_type(get_mvb_term("study timezone"), "list") # Not "study time zone"
  expect_type(get_mvb_term("study local timestamp"), "list") # Not "local timestamp"
})

test_that("get_mvb_term() returns error when term cannot be found", {
  skip_if_offline()
  expect_error(
    get_mvb_term("no-such term"),
    paste(
      "Can't find term \"no such term\" in Movebank Attribute Dictionary",
      "(<https://vocab.nerc.ac.uk/collection/MVB/current/>)."
    ),
    fixed = TRUE
  )
})
