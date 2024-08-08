test_that("get_aphia_id() surpresses warnings", {
  expect_no_warning(get_aphia_id("Mola mola"))
})

test_that("get_aphia_id() returns the correct output", {
  # 1 record
  record_mola <- get_aphia_id("Mola mola")
  df_mola <- dplyr::tibble(
    name = "Mola mola",
    aphia_id = 127405,
    aphia_lsid = "urn:lsid:marinespecies.org:taxname:127405",
    aphia_url = "https://www.marinespecies.org/aphia.php?p=taxdetails&id=127405"
  )
  expect_equal(record_mola, df_mola)

  # 1 record, not a name
  record_NA <- get_aphia_id("not_a_name")
  df_NA <- dplyr::tibble(
    name = "not_a_name",
    aphia_id = NA,
    aphia_lsid = NA_character_,
    aphia_url = NA_character_
  )
  expect_equal(record_NA, df_NA)

  # 2 records, one without a valid name
  record_mola_NA <- get_aphia_id(c("Mola mola", "not_a_name"))
  df_mola_NA <- dplyr::bind_rows(df_mola, df_NA)
  expect_equal(record_mola_NA, df_mola_NA)

  # Question mark as a species name
  record_mola_question <- get_aphia_id(c("Mola mola", "?"))
  df_question <- df_NA %>%
    dplyr::mutate(name = "?")
  df_mola_question <- dplyr::bind_rows(df_mola, df_question)
  expect_equal(record_mola_question, df_mola_question)

  # Unaccepted taxa (informal group)
  record_pisces <- get_aphia_id("Pisces")
  df_pisces <- dplyr::tibble(
    name = "Pisces",
    aphia_id = 11676,
    aphia_lsid = "urn:lsid:marinespecies.org:taxname:11676",
    aphia_url = "https://www.marinespecies.org/aphia.php?p=taxdetails&id=11676"
  )
  expect_equal(record_pisces, df_pisces)
})
