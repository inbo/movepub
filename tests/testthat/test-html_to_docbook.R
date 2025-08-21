test_that("html_to_docbook() returns error on invalid input", {
  expect_error(
    html_to_docbook(123),
    class = "movepub_error_string_invalid"
  )
  expect_error(
    html_to_docbook(list("a", "b")),
    class = "movepub_error_string_invalid"
  )
  expect_error(
    html_to_docbook(data.frame("a", "b")),
    class = "movepub_error_string_invalid"
  )
})

test_that("html_to_docbook() handles empty character string", {
  expect_equal(html_to_docbook(""), "")
})

test_that("html_to_docbook() returns a charachter", {
  expect_type(html_to_docbook("Text"), "character")
  expect_type(html_to_docbook("<b>Bold</b>"), "character")
  expect_type(html_to_docbook(c("<div>Text1</div>", "Text2")), "character")
  expect_type(html_to_docbook(""), "character")
  expect_type(html_to_docbook("<img src=\"file.png\">"), "character")
})

test_that("html_to_docbook() converts HTML to DocBook", {
  # paragraphs and headers
  expect_equal(html_to_docbook("<p>Text</p>"), "Text")
  expect_equal(html_to_docbook("<div>Text</div>"), "Text")
  expect_equal(html_to_docbook("<h1>Text</h1>"), "Text")
  expect_equal(html_to_docbook("<h2>Text</h2>"), "Text")
  expect_equal(html_to_docbook("<h3>Text</h3>"), "Text")
  expect_equal(html_to_docbook("<h4>Text</h4>"), "Text")
  expect_equal(html_to_docbook("<h5>Text</h5>"), "Text")
  expect_equal(html_to_docbook("<h6>Text</h6>"), "Text")

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
  expect_equal(html_to_docbook("<p class=\"small\">Text</p>"), "Text")
  expect_equal(html_to_docbook("<img src=\"file.png\">"), "")
})

test_that("html_to_docbook() splits paragraphs, headers and newlines,
           removing empty elements", {
  expect_equal(
    html_to_docbook(
      "Start  <h1>Title</h1>Para 1\nPara 2\n\n\nPara 3<p>Para 4</p><p></p>"
    ),
    c(
      "Start  ",
      "Title",
      "Para 1",
      "Para 2",
      "Para 3",
      "Para 4"
    )
  )
})

test_that("html_to_docbook() can handle vectorized strings", {
  expect_equal(
    html_to_docbook(
      c(
        "This is <b>bold</b>.\nParagraph 1\n\nParagraph 2<p></p>",
        "What follows is a code block: <pre>my code</pre>"
      )
    ),
    c(
      "This is <emphasis>bold</emphasis>.",
      "Paragraph 1",
      "Paragraph 2",
      "What follows is a code block: <literalLayout>my code</literalLayout>"
    )
  )
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
  # Test for valid EML
  expect_true(EML::eml_validate(eml))

  # Write EML (again)
  EML::write_eml(eml, file = file.path(temp_dir, "eml.xml"))

  expect_snapshot_file(
    file.path(temp_dir, "eml.xml"),
    transform = remove_uuid
  )
})
