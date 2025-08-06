test_that("html_to_docbook() handles empty character string", {
  expect_equal(html_to_docbook(""), "")
})

test_that("html_to_docbook() converts HTML to DocBook", {
  paragraph <- "<p>Text</p>"
  section_div <- "<div>Text</div>"
  title <- "<h1>Text</h1>"
  expected_title <- "<title>Text</title>"
  heading2 <- "<h2>Text</h2>"
  heading3 <- "<h3>Text</h3>"
  heading4 <- "<h4>Text</h4>"
  heading5 <- "<h5>Text</h5>"
  heading6 <- "<h6>Text</h6>"
  expected_paragragh <- "<para>Text</para>"
  itemizedlist <- "<ul><li>Item 1</li></ul>"
  expected_itemizedlist <- "<itemizedlist><listitem><para>Item 1</para></listitem></itemizedlist>"
  orderedlist <- "<ol><li>Item 1</li></ol>"
  expected_orderdlist <- "<orderedlist><listitem><para>Item 1</para></listitem></orderedlist>"
  emphasis <- "<em>Text</em>"
  strong <- "<strong>Text</strong>"
  italic <- "<i>Text</i>"
  expected_empahis <- "<emphasis>Text</emphasis>"
  subscript <- "<sub>Text</sub>"
  expected_subscript <- "<subscript>Text</subscript>"
  superscript <- "<sup>Text</sup>"
  expected_superscript <- "<superscript>Text</superscript>"
  literallayout <- "<pre>Text</pre>"
  expected_literallayout <- "<literalLayout>Text</literalLayout>"
  ulink <- '<a href="https://example.com">Text</a>'
  expected_ulink <- '<ulink url="https://example.com"><citetitle>Text</citetitle></ulink>'
  value <- "Text"
  expected_value <- "Text"
  span <- "<span>Text</span>"
  code <- "<code>Text</code>"

  #expect_equal(html_to_docbook(value), expected_value)
  expect_equal(html_to_docbook(paragraph), expected_paragragh)
  expect_equal(html_to_docbook(section_div), expected_paragragh)
  expect_equal(html_to_docbook(title), expected_title)
  expect_equal(html_to_docbook(heading2), expected_paragragh)
  expect_equal(html_to_docbook(heading3), expected_paragragh)
  expect_equal(html_to_docbook(heading4), expected_paragragh)
  expect_equal(html_to_docbook(heading5), expected_paragragh)
  expect_equal(html_to_docbook(heading6), expected_paragragh)
  expect_equal(html_to_docbook(itemizedlist), expected_itemizedlist)
  expect_equal(html_to_docbook(orderedlist), expected_orderdlist)
  expect_equal(html_to_docbook(emphasis), expected_empahis)
  expect_equal(html_to_docbook(strong), expected_empahis)
  expect_equal(html_to_docbook(italic), expected_empahis)
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
    doi = paste0("https://doi.org/", doi),
    directory = temp_dir
  )
  # Create and write EML
  eml <- suppressMessages(movepub::write_eml(doi, temp_dir))
  # Get abstract with HTML content
  zenodo_export <-
    jsonlite::read_json("https://zenodo.org/records/10053903/export/json")
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
