#' Convert HTML to DocBook XML
#'
#' Converts HTML strings to DocBook XML strings.
#' Handles the following tags: div, p, b, strong, i, em, a, ul, ol, li, sup,
#' sub, pre and h1:h6.
#' @param text String, may contain HTML.
#' @return String, with HTML converted to DocBook XML.
#' @family support functions
#' @export
#' @section Transformation details:
#' `<title>`
#' - `<h1>`
#' `<para>`
#' - `<div>`
#' - `<p>`
#' - `<h2>`to `<h6>`
#'
#' `<emphasis>`
#' - `<b>`
#' - `<strong>`
#' - `<i>`
#' - `<em>`
#'
#' `<ulink>`
#' - `<a href="...">`
#'
#' `<itemizedlist>`
#' - `<ul>`
#'
#' `<orderedlist>`
#' - `<ol>`
#'
#' `<listitem>`
#' - `<li>`
#'
#' `<superscript>`
#' - `<sup>`
#'
#' `<subscript>`
#' - `<sub>`
#'
#' `<literalLayout>`
#' - `<pre>`
#' @examples
#' html_to_docbook("<div>text - <b>bold</b></div>")
html_to_docbook <- function(text) {
  # Necessary for empty values and non-HTML text
  doc <- xml2::read_html(paste0("<root>", text, "</root>"))
  root <- xml2::xml_find_first(doc, ".//body/root")
  paste(purrr::map_chr(xml2::xml_contents(root), convert), collapse = "")
}

#' Helper function to recursively convert XML nodes to DocBook XML
#'
#' @param node An XML node to convert.
#'
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
