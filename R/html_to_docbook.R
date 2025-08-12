#' Convert text with HTML to DocBook
#'
#' Converts HTML to [DocBook](https://docbook.org/) for a given text.
#' Only a subset of HTML/DocBook tags are supported, see transformation details.
#'
#' @param string Text that may contain HTML.
#' @return Text with HTML converted to DocBook.
#' @family support functions
#' @export
#' @section Transformation details:
#' The function only converts HTML tags that can be translated to DocBook tags
#' supported by EML for the [paragraph](
#' https://eml.ecoinformatics.org/schema/eml-text_xsd.html#TextType_para)
#' element.
#' The following replacements are made:
#'
#' HTML tag | DocBook tag
#' --- | ---
#' `<p>...</p>` | `<para>...</para>`
#' `<div>...</div>` | `<para>...</para>`
#' `<h2>...</h2>` | `<para>...</para>`
#' `<h3>...</h3>` | `<para>...</para>`
#' `<h4>...</h4>` | `<para>...</para>`
#' `<h5>...</h4>` | `<para>...</para>`
#' `<h6>...</h4>` | `<para>...</para>`
#' `<ul>...</ul>` | `<itemizedlist>...</itemizedlist>`
#' `<ol>...</ol>` | `<orderedlist>...</orderedlist>`
#' `<li>...</li>` | `<listitem>...</listitem>`
#' `<strong>...</strong>` | `<emphasis>...</emphasis>`
#' `<b>...</b>` | `<emphasis>...</emphasis>`
#' `<em>...</em>` | `<emphasis>...</emphasis>`
#' `<i>...</i>` | `<emphasis>...</emphasis>`
#' `<sub>...</sub>` | `<subscript>...</subscript>`
#' `<sup>...</sup>` | `<superscript>...</superscript>`
#' `<pre>...</pre>` | `<literalLayout>...</literalLayout>`
#' `<a href="http://example.com">...</a>` | `<ulink url="https://example.com"><citetitle>...</citetitle></ulink>`
#' `<h1>...</h1>` | `<title>...</title>`
#'
#' @examples
#' html_to_docbook("<div>My <b>bold</b> text.</div>")
html_to_docbook <- function(string) {
  # Necessary for empty values and non-HTML text
  doc <- xml2::read_html(paste0("<root>", string, "</root>"))
  root <- xml2::xml_find_first(doc, ".//body/root")
  paste(purrr::map_chr(xml2::xml_contents(root), convert), collapse = "")
}

#' Helper function to recursively convert XML nodes to DocBook XML
#'
#' @param node An XML node to convert.
#' @returns A string with HTML converted to Dokbook XML
#' @noRd
convert <- function(node) {
  tag_map <- list(
    div = "para",
    p = "para",
    b = "emphasis",
    strong = "emphasis",
    i = "emphasis",
    em = "emphasis",
    a = "ulink",
    ul = "itemizedlist",
    ol = "orderedlist",
    li = "listitem",
    sup = "superscript",
    sub = "subscript",
    pre = "literalLayout",
    h1 = "title",
    h2 = "para",
    h3 = "para",
    h4 = "para",
    h5 = "para",
    h6 = "para"
  )

  if (xml2::xml_type(node) == "text") {
    output <- xml2::xml_text(node)
  } else {
    tag <- xml2::xml_name(node)
    mapped <- tag_map[[tag]]

    children <- paste(
      purrr::map_chr(xml2::xml_contents(node), convert),
      collapse = ""
    )

    if (tag == "a") {
      attr_href <- xml2::xml_attr(node, "href")
      output <- paste0(
        '<ulink url="', attr_href, '"><citetitle>', children,
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
