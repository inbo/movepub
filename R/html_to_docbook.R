#' Convert text with HTML to DocBook
#'
#' Converts text with HTML syntax to [DocBook](https://docbook.org/).
#' Only a subset of HTML tags are supported (see transformation details), all
#' other HTML syntax is removed.
#'
#' @param string Text that may contain HTML.
#' @return Text with HTML converted to DocBook.
#' @family support functions
#' @export
#' @section Transformation details:
#' The function only converts HTML tags that can be translated to the EML
#' element `<title>`, the EML element `<para>` or [DocBook tags](
#' https://eml.ecoinformatics.org/schema/eml-text_xsd.html#TextType_para)
#' supported by EML within `<para>`.
#' All the rest is sanitized.
#'
#' Input | Output
#' --- | ---
#' `<h1>...</h1>` | `<title>...</title>`
#' `<p>...</p>` | `<para>...</para>`
#' `<div>...</div>` | `<para>...</para>`
#' `<h2>...</h2>` | `<para>...</para>`
#' `<h3>...</h3>` | `<para>...</para>`
#' `<h4>...</h4>` | `<para>...</para>`
#' `<h5>...</h4>` | `<para>...</para>`
#' `<h6>...</h4>` | `<para>...</para>`
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
#' `...` | `...`
#' `<code>...</code>` | `...`
#' `<foo>...</foo>` | `...`
#' `<span class="small">...</span>` | `...`
#' `<p class="small">...</p>` | `<para>...</para>`
#' `<img src="file.png">` | empty string
#'
#' @examples
#' html_to_docbook("<div>My <b>bold</b> text.</div>")
html_to_docbook <- function(string) {
  # Necessary for empty values and non-HTML text
  doc <- xml2::read_html(paste0("<root>", string, "</root>"))
  root <- xml2::xml_find_first(doc, ".//body/root")
  paste(
    purrr::map_chr(xml2::xml_contents(root), convert_xml_node),
    collapse = ""
  )
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
    p = "para",
    div = "para",
    h1 = "title",
    h2 = "para",
    h3 = "para",
    h4 = "para",
    h5 = "para",
    h6 = "para",
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
