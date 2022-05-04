test_that("get_mvb_term() returns information about at term", {
  expected_info <- list(
    id = "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/",
    identifier = "SDN:MVB::MVB000016",
    prefLabel = "animal ID",
    altLabel = "individual local identifier",
    definition = paste(
      "An individual identifier for the animal, provided by the data owner.",
      "If the data owner does not provide an Animal ID, an internal Movebank",
      "animal identifier is sometimes shown. Example: '91876A, Gary';",
      "Units: none; Entity described: individual"
    ),
    date = "2019-10-03 20:36:04.0",
    version = "2",
    hasCurrentVersion = "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/2/",
    hasVersion = "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/1/",
    deprecated = "false",
    note = "accepted"
  )
  expect_identical(get_mvb_term("animal ID"), expected_info)
})

test_that("get_mvb_term() returns term with prefLabel first", {
  label <- "individual local identifier"
  expect_identical(get_mvb_term(label)$prefLabel, label)
  # Not term http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/ with
  # animal ID as pref label
})

test_that("get_mvb_term() returns term with altLabel too", {
  expect_identical(
    get_mvb_term("deploy on timestamp"), # prefLabel
    get_mvb_term("deploy on date") # altLabel
  )
})

test_that("get_mvb_term() ignores case and converts to space", {
  expect_identical(
    get_mvb_term("ANIMAL-exact_date.of:birth")$prefLabel,
    "animal exact date of birth"
  )
})

test_that("get_mvb_term() returns error when term cannot be found", {
  expect_error(
    get_mvb_term("no-such term"),
    "Can't find term `no such term` in Movebank Attribute Dictionary.",
    fixed = TRUE
  )
})
