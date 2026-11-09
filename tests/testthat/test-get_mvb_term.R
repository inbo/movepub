test_that("get_mvb_term() is defunct", {
  lifecycle::expect_defunct(get_mvb_term("animal_id"))
})
