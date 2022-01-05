#' Get Movebank term
#'
#' Get information for a term in the [Movebank Attribute
#' Dictionary](http://vocab.nerc.ac.uk/collection/MVB/current/).
#'
#' @param label Preferred label of the term.
#' @return List object with term information.
#' @export
#' @examples
#' # Get information for term "animal ID"
#' get_movebank_term("animal ID")
get_movebank_term <- function(label) {
  vocab_url <- file.path(
    "http://vocab.nerc.ac.uk/collection/MVB/current",
    "?_profile=nvs&_mediatype=application/ld+json"
  )
  vocab <- jsonlite::fromJSON(vocab_url, simplifyDataFrame = FALSE)

  concepts <- purrr::keep(vocab$`@graph`, ~.$`@type` == "skos:Concept")
  concept <- purrr::keep(terms, ~.$prefLabel$`@value` == label)

  assertthat::assert_that(
    length(concept) > 0,
    msg = glue::glue(
      "Can't find term with label `{label}` in Movebank Attribute Dictionary."
    )
  )
  concept <- concept[[1]]

  term <- list(
    # Identifiers
    id = concept$`@id`,
    # @type: "skos:Concept" for all
    identifier = concept$identifier,
    # dc:identifier: same as identifier

    # Labels
    # prefLabel$`@language`: "en" for all
    prefLabel = concept$prefLabel$`@value`,
    altLabel = concept$altLabel,

    # Definition
    # definition$`@language`: "en" for all
    definition = concept$definition$`@value`,

    # Date
    date = concept$date,
    # authoredOn: same as date

    # Versions
    version = concept$version,
    hasCurrentVersion = concept$hasCurrentVersion,
    hasVersion = concept$hasVersion,
    # inDataset: "http://vocab.nerc.ac.uk/.well-known/void" for all
    deprecated = concept$deprecated,
    # versionInfo: same as version
    # notation: same as identifier
    # note$`@language`: "en" for all
    note = concept$note$`@value`
  )

  return(term)
}
