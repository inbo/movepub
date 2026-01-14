# Convert text with HTML to DocBook

Converts text with HTML syntax to [DocBook](https://docbook.org/),
splitting paragraphs and headers into separate elements. Only a subset
of HTML tags are supported (see transformation details), all other HTML
syntax is removed.

## Usage

``` r
html_to_docbook(string)
```

## Arguments

- string:

  Character (vector) that may contain HTML syntax.

## Value

A character vector with HTML converted to DocBook.

## Transformation details

The function splits text into a character vector, with one element for
each paragraph, header or line break (`\n`). The remaining HTML is
converted to DocBook, but only tags those supported by EML for
[paragraphs](https://eml.ecoinformatics.org/schema/eml-text_xsd.html#TextType_para).
All other HTML/DocBook syntax is sanitized and empty elements are
removed.

|                                        |                                                                       |
|----------------------------------------|-----------------------------------------------------------------------|
| Input                                  | Output                                                                |
| `<h1>...</h1>`                         | `...` (separate element)                                              |
| `<p>...</p>`                           | `...` (separate element)                                              |
| `<div>...</div>`                       | `...` (separate element)                                              |
| `<h2>...</h2>`                         | `...` (separate element)                                              |
| `<h3>...</h3>`                         | `...` (separate element)                                              |
| `<h4>...</h4>`                         | `...` (separate element)                                              |
| `<h5>...</h4>`                         | `...` (separate element)                                              |
| `<h6>...</h4>`                         | `...` (separate element)                                              |
| `...\n`                                | `...` (separate element)                                              |
| `<ul>...</ul>`                         | `<itemizedlist>...</itemizedlist>`                                    |
| `<ol>...</ol>`                         | `<orderedlist>...</orderedlist>`                                      |
| `<li>...</li>`                         | `<listitem><para>...</para></listitem>`                               |
| `<em>...</em>`                         | `<emphasis>...</emphasis>`                                            |
| `<i>...</i>`                           | `<emphasis>...</emphasis>`                                            |
| `<strong>...</strong>`                 | `<emphasis>...</emphasis>`                                            |
| `<b>...</b>`                           | `<emphasis>...</emphasis>`                                            |
| `<sub>...</sub>`                       | `<subscript>...</subscript>`                                          |
| `<sup>...</sup>`                       | `<superscript>...</superscript>`                                      |
| `<pre>...</pre>`                       | `<literalLayout>...</literalLayout>`                                  |
| `<a href="http://example.com">...</a>` | `<ulink url="https://example.com"><citetitle>...</citetitle></ulink>` |
| `<code>...</code>`                     | `...` (HTML element sanitized)                                        |
| `<foo>...</foo>`                       | `...` (HTML element sanitized)                                        |
| `<span class="small">...</span>`       | `...` (HTML property sanitized)                                       |
| `<p class="small">...</p>`             | `...` (HTML property sanitized)                                       |
| `<img src="file.png">`                 | empty string (HTML element sanitized)                                 |
| `<emphasis>...</emphasis>`             | `...` (DocBook element sanitized)                                     |

## Use with EML

1.  Capture EML with `eml <- movepub::write_eml()` or read with
    [`EML::read_eml()`](https://docs.ropensci.org/EML/reference/read_eml.html).

2.  Assign output of `html_to_docbook()` to `eml$dataset$abstract$para`.

3.  Write EML with
    [`EML::write_eml()`](https://docs.ropensci.org/EML/reference/write_eml.html).

## See also

Other support functions:
[`datacite_to_eml()`](https://inbo.github.io/movepub/reference/datacite_to_eml.md),
[`get_aphia_id()`](https://inbo.github.io/movepub/reference/get_aphia_id.md)

## Examples

``` r
html_to_docbook(
  c(
    "This is <b>bold</b>.\nParagraph 1\n\nParagraph 2<p></p>",
    "What follows is a list: <ul><li>Item 1</li><li>Item 2</li></ul>"
  )
)
#> [1] "This is <emphasis>bold</emphasis>."                                                                                                   
#> [2] "Paragraph 1"                                                                                                                          
#> [3] "Paragraph 2"                                                                                                                          
#> [4] "What follows is a list: <itemizedlist><listitem><para>Item 1</para></listitem><listitem><para>Item 2</para></listitem></itemizedlist>"
```
