test_that("get_aphia_id() surpresses warnings", {
  expect_no_warning(get_aphia_id("Mola mola"))
})

test_that("get_aphia_id() returns the correct output", {
  # Name with result
  df_mola <- dplyr::tibble(
    name = "Mola mola",
    aphia_id = 127405,
    aphia_lsid = "urn:lsid:marinespecies.org:taxname:127405",
    aphia_url = "https://www.marinespecies.org/aphia.php?p=taxdetails&id=127405",
    aphia_url_cli = "{.href [127405](https://www.marinespecies.org/aphia.php?p=taxdetails&id=127405)}"
  )
  expect_equal(get_aphia_id("Mola mola"), df_mola)

  # Name without result
  df_na <- dplyr::tibble(
    name = "not_a_name",
    aphia_id = NA,
    aphia_lsid = NA_character_,
    aphia_url = NA_character_,
    aphia_url_cli = NA_character_
  )
  expect_equal(get_aphia_id("not_a_name"), df_na)

  # Name as questionmark
  df_questionmark <- dplyr::mutate(df_na, name = "?")
  expect_equal(get_aphia_id("?"), df_questionmark)

  # Name is unaccepted taxa
  df_pisces <- dplyr::tibble(
    name = "Pisces",
    aphia_id = 11676,
    aphia_lsid = "urn:lsid:marinespecies.org:taxname:11676",
    aphia_url = "https://www.marinespecies.org/aphia.php?p=taxdetails&id=11676",
    aphia_url_cli = "{.href [11676](https://www.marinespecies.org/aphia.php?p=taxdetails&id=11676)}"
  )
  expect_equal(get_aphia_id("Pisces"), df_pisces)

  # 2 names
  expect_equal(
    get_aphia_id(c("Mola mola", "not_a_name")),
    dplyr::bind_rows(df_mola, df_na)
  )
})
