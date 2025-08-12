test_that("html_to_docbook() handles empty character string", {
  expect_equal(html_to_docbook(""), "")
})

test_that("html_to_docbook() converts HTML to DocBook", {
  # Para
  expect_equal(html_to_docbook("<p>Text</p>"), "<para>Text</para>")
  expect_equal(html_to_docbook("<div>Text</div>"), "<para>Text</para>")
  expect_equal(html_to_docbook("<h1>Text</h1>"), "<title>Text</title>")
  expect_equal(html_to_docbook("<h2>Text</h2>"), "<para>Text</para>")
  expect_equal(html_to_docbook("<h3>Text</h3>"), "<para>Text</para>")
  expect_equal(html_to_docbook("<h4>Text</h4>"), "<para>Text</para>")
  expect_equal(html_to_docbook("<h5>Text</h5>"), "<para>Text</para>")
  expect_equal(html_to_docbook("<h6>Text</h6>"), "<para>Text</para>")

  # itemizedlist, orderedlist
  expect_equal(
    html_to_docbook("<ul><li>Item 1</li></ul>"),
    "<itemizedlist><listitem><para>Item 1</para></listitem></itemizedlist>"
  )
  expect_equal(
    html_to_docbook("<ol><li>Item 1</li></ol>"),
    "<orderedlist><listitem><para>Item 1</para></listitem></orderedlist>"
  )

  # emphasis
  expect_equal(html_to_docbook("<em>Text</em>"), "<emphasis>Text</emphasis>")
  expect_equal(html_to_docbook("<i>Text</i>"), "<emphasis>Text</emphasis>")
  expect_equal(
    html_to_docbook("<strong>Text</strong>"),
    "<emphasis>Text</emphasis>"
  )
  expect_equal(html_to_docbook("<b>Text</b>"), "<emphasis>Text</emphasis>")

  # subscript, superscript
  expect_equal(
    html_to_docbook("<sub>Text</sub>"),
    "<subscript>Text</subscript>"
  )
  expect_equal(
    html_to_docbook("<sup>Text</sup>"),
    "<superscript>Text</superscript>"
  )

  # literalvalue
  expect_equal(
    html_to_docbook("<pre>Text</pre>"),
    "<literalLayout>Text</literalLayout>"
  )

  # ulink
  expect_equal(
    html_to_docbook("<a href=\"https://example.com\">Text</a>"),
    "<ulink url=\"https://example.com\"><citetitle>Text</citetitle></ulink>"
  )

  # Sanitized values
  expect_equal(html_to_docbook("Text"), "Text")
  expect_equal(html_to_docbook("<code>Text</code>"), "Text")
  expect_equal(html_to_docbook("<foo>Text</foo>"), "Text")
  expect_equal(html_to_docbook("<span class=\"small\">Text</span>"), "Text")
  expect_equal(
    html_to_docbook("<p class=\"small\">Text</p>"),
    "<para>Text</para>"
  )
  expect_equal(html_to_docbook("<img src=\"file.png\">"), "")
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
