#' Convert text with HTML to DocBook
#'
#' Converts text with HTML syntax to [DocBook](https://docbook.org/), splitting
#' paragraphs and headers into separate elements.
#' Only a subset of HTML tags are supported (see transformation details), all
#' other HTML syntax is removed.
#'
#' @param string Character (vector) that may contain HTML syntax.
#' @return A character vector with HTML converted to DocBook.
#' @family support functions
#' @export
#' @section Transformation details:
#' The function splits text into a character vector, with one element for each
#' paragraph, header or line break (`\n`).
#' The remaining HTML is converted to DocBook, but only tags those supported by
#' EML for [paragraphs](
#' https://eml.ecoinformatics.org/schema/eml-text_xsd.html#TextType_para).
#' All other HTML/DocBook syntax is sanitized and empty elements are removed.
#'
#' Input | Output
#' --- | ---
#' `<h1>...</h1>` | `...` (separate element)
#' `<p>...</p>` | `...` (separate element)
#' `<div>...</div>` | `...` (separate element)
#' `<h2>...</h2>` | `...` (separate element)
#' `<h3>...</h3>` | `...` (separate element)
#' `<h4>...</h4>` | `...` (separate element)
#' `<h5>...</h4>` | `...` (separate element)
#' `<h6>...</h4>` | `...` (separate element)
#' `...\n` | `...` (separate element)
#' `<ul>...</ul>` | `<itemizedlist>...</itemizedlist>`
#' `<ol>...</ol>` | `<orderedlist>...</orderedlist>`
#' `<li>...</li>` | `<listitem><para>...</para></listitem>`
#' `<em>...</em>` | `<emphasis>...</emphasis>`
#' `<i>...</i>` | `<emphasis>...</emphasis>`
#' `<strong>...</strong>` | `<emphasis>...</emphasis>`
#' `<b>...</b>` | `<emphasis>...</emphasis>`
#' `<sub>...</sub>` | `<subscript>...</subscript>`
#' `<sup>...</sup>` | `<superscript>...</superscript>`
#' `<pre>...</pre>` | `<literalLayout>...</literalLayout>`
#' `<a href="http://example.com">...</a>` | `<ulink url="https://example.com"><citetitle>...</citetitle></ulink>`
#' `<code>...</code>` | `...` (HTML element sanitized)
#' `<foo>...</foo>` | `...` (HTML element sanitized)
#' `<span class="small">...</span>` | `...` (HTML property sanitized)
#' `<p class="small">...</p>` | `...` (HTML property sanitized)
#' `<img src="file.png">` | empty string (HTML element sanitized)
#' `<emphasis>...</emphasis>` | `...` (DocBook element sanitized)
#'
#' @section Use with EML:
#' 1. Capture EML with `eml <- movepub::write_eml()` or read with
#'   `EML::read_eml()`.
#' 2. Assign output of `html_to_docbook()` to `eml$dataset$abstract$para`.
#' 3. Write EML with `EML::write_eml()`.
#'
#' @examples
#' html_to_docbook(
#'   c(
#'     "This is <b>bold</b>.\nParagraph 1\n\nParagraph 2<p></p>",
#'     "What follows is a list: <ul><li>Item 1</li><li>Item 2</li></ul>"
#'   )
#' )
html_to_docbook <- function(string) {
  if (!is.character(string)) {
    cli::cli_abort(
      c(
        "{.arg string} must be a character (vector)",
        "x" = "{.arg string} has class {.val {class(string)}}."
      ),
      class = "movepub_error_string_invalid"
    )
  }

  purrr::map(string, convert_one_string) |>
    purrr::flatten_chr()
}

#' Convert a single string
#'
#' Helper function to convert a single string with HTML syntax to DocBook.
#'
#' @param string Text that may contain HTML.
#' @return A character vector of DocBook string; typically, each element is a
#' paragraph or block element in DocBook format.
#' @noRd
#' @examples
#' convert_one_string("This is <b>bold</b>.\nParagraph 1\n\nParagraph 2<p></p>")
convert_one_string <- function(string) {
  # Necessary for empty values and non-HTML text
  doc <- xml2::read_html(paste0("<root>", string, "</root>"))
  root <- xml2::xml_find_first(doc, ".//body/root")
  output <- paste(
    purrr::map_chr(xml2::xml_contents(root), convert_xml_node),
    collapse = ""
  )

  # Make sure <itemizedlist> and <orderedlist> are within one element
  itemized_pattern <- "<itemizedlist>[\\s\\S]*?</itemizedlist>"
  ordered_pattern <- "<orderedlist>[\\s\\S]*?</orderedlist>"
  output_cleaned <-
    output |>
    stringr::str_replace_all(
      itemized_pattern,
      function(x) gsub("<split>|</split>|\\n", "", x)
    ) |>
    stringr::str_replace_all(
      ordered_pattern,
      function(x) gsub("<split>|</split>|\\n", "", x)
    )

  # Split into elements (paragraphs)
  paragraphs <-
    output_cleaned |>
    strsplit("<split>|</split>|\\n") |>
    purrr::map(~ purrr::discard(.x, ~ .x == ""))

  if (length(paragraphs) == 1) {
    paragraphs <- unlist(paragraphs)
  }

  if (length(paragraphs) == 0) {
    paragraphs <- ""
  }

  return(paragraphs)
}

#' Convert XML node to DocBook.
#'
#' Helper function to recursively convert XML nodes to DocBook.
#'
#' @param node An XML node to convert.
#' @returns A string with HTML converted to DocBook.
#' @noRd
convert_xml_node <- function(node) {
  tag_map <- list(
    p = "split",
    div = "split",
    h1 = "split",
    h2 = "split",
    h3 = "split",
    h4 = "split",
    h5 = "split",
    h6 = "split",
    "\n" = "split",
    ul = "itemizedlist",
    ol = "orderedlist",
    li = "listitem",
    em = "emphasis",
    i = "emphasis",
    strong = "emphasis",
    b = "emphasis",
    sub = "subscript",
    sup = "superscript",
    pre = "literalLayout",
    a = "ulink"
  )

  if (xml2::xml_type(node) == "text") {
    output <- xml2::xml_text(node)
  } else {
    tag <- xml2::xml_name(node)
    mapped <- tag_map[[tag]]

    children <- paste(
      purrr::map_chr(xml2::xml_contents(node), convert_xml_node),
      collapse = ""
    )

    if (tag == "a") {
      attr_href <- xml2::xml_attr(node, "href")
      output <- paste0(
        "<ulink url=\"", attr_href, "\"><citetitle>", children,
        "</citetitle></ulink>"
      )
    } else if (tag == "li") {
      output <- paste0("<listitem><para>", children, "</para></listitem>")
    } else if (!is.null(mapped)) {
      output <- paste0("<", mapped, ">", children, "</", mapped, ">")
    } else if (is.null(mapped)) {
      output <- children
    }
  }

  return(output)
}
