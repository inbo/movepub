test_that("get_mvb_term() is deprecated", {
  lifecycle::expect_deprecated(get_mvb_term("animal_id"))
})
