test_that("html_to_docbook() handles empty character string", {
  expect_equal(html_to_docbook(""), "")
})

test_that("html_to_docbook() converts HTML to DocBook", {
  value <- "Text"
  expected_value <- "Text"
  itemizedlist <- "<ul><li>Item 1</li></ul>"
  expected_itemizedlist <- "<itemizedlist><listitem>Item 1</listitem></itemizedlist>"
  orderedlist <- "<ol><li>Item 1</li></ol>"
  expected_orderdlist <- "<orderedlist><listitem>Item 1</listitem></orderedlist>"
  emphasis <- "<em>Text 1</em><strong>Text 2</strong>"
  expected_empahis <- "<emphasis>Text 1</emphasis><emphasis>Text 2</emphasis>"
  subscript <- "<sub>Text</sub>"
  expected_subscript <- "<subscript>Text</subscript>"
  superscript <- "<sup>Text</sup>"
  expected_superscript <- "<superscript>Text</superscript>"
  literallayout <- "<pre>Text</pre>"
  expected_literallayout <- "<literalLayout>Text</literalLayout>"
  ulink <- '<a href="https://example.com">Text</a>'
  expected_ulink <- '<ulink url="https://example.com"><citetitle>Text</citetitle></ulink>'
  span <- "<span>Text</span>"
  code <- "<code>Text</code>"

  #expect_equal(html_to_docbook(value), expected_value)
  expect_equal(html_to_docbook(itemizedlist), expected_itemizedlist)
  expect_equal(html_to_docbook(orderedlist), expected_orderdlist)
  expect_equal(html_to_docbook(emphasis), expected_empahis)
  expect_equal(html_to_docbook(subscript), expected_subscript)
  expect_equal(html_to_docbook(superscript), expected_superscript)
  expect_equal(html_to_docbook(literallayout), expected_literallayout)
  expect_equal(html_to_docbook(ulink), expected_ulink)
  expect_equal(html_to_docbook(span), expected_value)
  expect_equal(html_to_docbook(code), expected_value)
})

test_that("html_to_docbook() converts an abstract with HTML to DocBook", {
  skip_if_offline()
  doi <- "10.5281/zenodo.10053903"
  temp_dir <- tempdir()
  on.exit(unlink(temp_dir, recursive = TRUE))
  eml <- movepub::write_eml(
    doi = "https://doi.org/10.5281/zenodo.5879096",
    directory = temp_dir
  )
  # Create and write EML
  eml <- suppressMessages(movepub::write_eml(doi, temp_dir))
  # Get abstract with HTML content
  zenodo_export <-
    jsonlite::read_json("https://zenodo.org/records/5879096/export/json")
  description_full <- zenodo_export$metadata$description
  # Convert HTML to DocBook
  eml$dataset$abstract$para <- html_to_docbook(description_full)
  # Write EML (again)
  EML::write_eml(eml, file = file.path(temp_dir, "eml.xml"))

  expect_snapshot_file(
    file.path(temp_dir, "eml.xml"),
    transform = remove_uuid
  )
})
