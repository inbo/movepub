#' Convert text with HTML to DocBook
#'
#' Converts text with HTML syntax to [DocBook](https://docbook.org/).
#' Only a subset of HTML tags are supported (see transformation details), all
#' other HTML syntax is removed.
#'
#' @param strings Character or character vector with text that may contain HTML.
#' @return A character vector of DocBook strings; typically, each element is a
#' paragraph or block element in DocBook format.
#' @family support functions
#' @export
#' @section Transformation details:
#' The function only converts HTML tags to [DocBook tags](
#' https://eml.ecoinformatics.org/schema/eml-text_xsd.html#TextType_para)
#' supported by EML.
#' It splits the output into elements (paragraphs) and also ensures that
#' itemized and ordered lists are wrapped properly as single elements.
#'
#' All the rest (including existing DocBook tags) is sanitized.
#'
#' Input | Output
#' --- | ---
#' `<h1>...</h1>` | `...` (seperate element)
#' `<p>...</p>` | `...` (seperate element)
#' `<div>...</div>` | `...` (seperate element)
#' `<h2>...</h2>` | `...` (seperate element)
#' `<h3>...</h3>` | `...` (seperate element)
#' `<h4>...</h4>` | `...` (seperate element)
#' `<h5>...</h4>` | `...` (seperate element)
#' `<h6>...</h4>` | `...` (seperate element)
#' `<ul>...</ul>` | `<itemizedlist>...</itemizedlist>` (seperate element)
#' `<ol>...</ol>` | `<orderedlist>...</orderedlist>` (seperate element)
#' `<li>...</li>` | `<listitem><para>...</para></listitem>`
#' `<em>...</em>` | `<emphasis>...</emphasis>`
#' `<i>...</i>` | `<emphasis>...</emphasis>`
#' `<strong>...</strong>` | `<emphasis>...</emphasis>`
#' `<b>...</b>` | `<emphasis>...</emphasis>`
#' `<sub>...</sub>` | `<subscript>...</subscript>`
#' `<sup>...</sup>` | `<superscript>...</superscript>`
#' `<pre>...</pre>` | `<literalLayout>...</literalLayout>`
#' `<a href="http://example.com">...</a>` | `<ulink url="https://example.com"><citetitle>...</citetitle></ulink>`
#' `...` | `...`
#' `<code>...</code>` | `...`
#' `<foo>...</foo>` | `...`
#' `<span class="small">...</span>` | `...`
#' `<p class="small">...</p>` | `...`
#' `<img src="file.png">` | empty string
#' `<emphasis>...</emphasis>` | `...`
#'
#' @section Use:
#' - Read a EML file with `EML::read_eml()` or create an EML list.
#' - Assign the output of `html_to_docbook()` to `eml$dataset$abstract$para`.
#' - Write the EML list to a file with `EML::write_eml()`. `EML::write_eml()`
#' will wrap each element in `eml$dataset$abstract$para` with
#' `<para>...</para>`.
#'
#' @examples
#' html_to_docbook(
#' "<p>My <b>bold</b> text.</p><ul><li>Item 1</li><li>Item 2</li></ul>"
#' )
#' \dontrun{
#' # How to use this function for the abstract in EML:
#' # Create and write EML
#' eml <- movepub::write_eml("10.5281/zenodo.10053903", "my_directory")
#' # Get abstract with HTML content
#' zenodo_export <-
#'   jsonlite::read_json("https://zenodo.org/records/10053903/export/json")
#' description_full <- zenodo_export$metadata$description
#' # Convert HTML to DocBook
#' eml$dataset$abstract$para <- html_to_docbook(description_full)
#' # Write EML (again)
#' EML::write_eml(eml, file = file.path("my_directory", "eml.xml"))
#' # Clean up (don't do this if you want to keep your files)
#' unlink("my_directory", recursive = TRUE)
#' }
html_to_docbook <- function(strings) {
  if (!is.character(strings)) {
    cli::cli_abort(
      c(
        "{.arg strings} must be a character or character vector",
        "x" = "{.arg string} has class {.val {class(strings)}}."
      ),
      class = "movepub_error_strings_invalid"
    )
  }

  purrr::map(strings, convert_one_string) |>
    purrr::flatten_chr()
}

#' Convert a single string
#'
#' Helper function to convert a single string with HTML syntax to DocBook.
#'
#' @param string Text that may contain HTML.
#' @return A character vector of DocBook strings; typically, each element is a
#' paragraph or block element in DocBook format.
#' @noRd
#' @examples
#' convert_one_string(
#' "<p>My <b>bold</b> text.</p><ul><li>Item 1</li><li>Item 2</li></ul>"
#' )
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
