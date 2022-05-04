#' Get term from the Movebank Attribute Dictionary
#'
#' Search a term by its label in the [Movebank Attribute
#' Dictionary (MVB)](http://vocab.nerc.ac.uk/collection/MVB/current/).
#' Returns in order: term with matching `prefLabel`, matching `altLabel` or
#' error when no matching term is found.
#'
#' @param label Label of the term to look for. Case will be ignored and `-`,
#'   `_`, `.` and `:` interpreted as space.
#' @return List with term information.
#' @export
#' @examples
#' get_mvb_term("animal_id")
#'
#' get_mvb_term("Deploy.On.Date")
get_mvb_term <- function(label) {
  label_clean <- tolower(gsub("(-|_|\\.|:)", " ", label))
  label_clean <- ifelse(
    label_clean == "bar barometric pressure",
    "bar:barometric pressure",
    label_clean
  )
  label_clean <- ifelse(
    label_clean == "behavior according to",
    "behaviour according to",
    label_clean
  )


  # Get terms
  vocab_url <- file.path(
    "http://vocab.nerc.ac.uk/collection/MVB/current",
    "?_profile=nvs&_mediatype=application/ld+json"
  )
  vocab <- jsonlite::fromJSON(vocab_url, simplifyDataFrame = FALSE)
  terms <- purrr::keep(vocab$`@graph`, ~.$`@type` == "skos:Concept")

  # Search for concept using prefLabel, and altLabel if not found
  term <- purrr::keep(terms, function(x) {
    tolower(x$prefLabel$`@value`) == label_clean
  })
  if (length(term) == 0) {
    term <- purrr::keep(terms, function(x) {
      tolower(x$altLabel) == label_clean
    })
  }
  assertthat::assert_that(
    length(term) > 0,
    msg = glue::glue(
      "Can't find term `{label_clean}` in Movebank Attribute Dictionary."
    )
  )
  term <- term[[1]]

  # Prepare output
  list(
    # Identifiers
    id = term$`@id`,
    # @type: "skos:Concept" for all
    identifier = term$identifier,
    # dc:identifier: same as identifier

    # Labels
    # prefLabel$`@language`: "en" for all
    prefLabel = term$prefLabel$`@value`,
    altLabel = term$altLabel,

    # Definition
    # definition$`@language`: "en" for all
    definition = term$definition$`@value`,

    # Date
    date = term$date,
    # authoredOn: same as date

    # Versions
    version = term$version,
    hasCurrentVersion = term$hasCurrentVersion,
    hasVersion = term$hasVersion,
    # inDataset: "http://vocab.nerc.ac.uk/.well-known/void" for all
    deprecated = term$deprecated,
    # versionInfo: same as version
    # notation: same as identifier
    # note$`@language`: "en" for all
    note = term$note$`@value`
  )
}
