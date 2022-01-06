#' Get Movebank term
#'
#' Get information for a term in the [Movebank Attribute
#' Dictionary](http://vocab.nerc.ac.uk/collection/MVB/current/).
#'
#' @param label Preferred label of the term to look for. Case will be ignored
#'   and `-`, `_`, `.` and `:` interpreted as space.
#' @return List object with term information.
#' @export
#' @examples
#' get_movebank_term("animal_id")
#'
#' get_movebank_term("Deploy.On.Date")
get_movebank_term <- function(label) {
  label_clean <- gsub("(-|_|\\.|:)", " ", label)

  # Get concepts
  vocab_url <- file.path(
    "http://vocab.nerc.ac.uk/collection/MVB/current",
    "?_profile=nvs&_mediatype=application/ld+json"
  )
  vocab <- jsonlite::fromJSON(vocab_url, simplifyDataFrame = FALSE)
  concepts <- purrr::keep(vocab$`@graph`, ~.$`@type` == "skos:Concept")

  # Search for concept using prefLabel, and altLabel if not found
  concept <- purrr::keep(terms, function(x) {
    tolower(x$prefLabel$`@value`) == label_clean
  })
  if (length(concept) == 0) {
    concept <- purrr::keep(terms, function(x) {
      tolower(x$altLabel) == label_clean
    })
  }
  assertthat::assert_that(
    length(concept) > 0,
    msg = glue::glue(
      "Can't find term `{label_clean}` in Movebank Attribute Dictionary."
    )
  )
  concept <- concept[[1]]

  # Prepare output
  list(
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
}
