test_that("get_mvb_term() is deprecated", {
  rlang::local_options(lifecycle_verbosity = "error")
  expect_error(get_mvb_term("animal_id"), class = "defunctError")
})
