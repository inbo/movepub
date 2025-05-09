#' Get term from the Movebank Attribute Dictionary
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function is deprecated in favour of [move2::movebank_get_vocabulary()],
#' which offers the same functionality and more.
#'
#' Search a term by its label in the [Movebank Attribute
#' Dictionary (MVB)](http://vocab.nerc.ac.uk/collection/MVB/current/).
#' Returns in order: term with matching `prefLabel`, matching `altLabel` or
#' error when no matching term is found.
#'
#' @param label Label of the term to look for. Case will be ignored and `-`,
#'   `_`, `.` and `:` interpreted as space.
#' @return List with term information.
#' @keywords internal
#' @export
#' @examples
#' get_mvb_term("animal_id")
#' get_mvb_term("individual-local-identifier") # A deprecated term
#' get_mvb_term("Deploy.On.Date")
#'
#' # With move2
#' library(move2)
#' movebank_get_vocabulary("animal_id", return_type = "list")
#' movebank_get_vocabulary(
#'  "individual-local-identifier",
#'  omit_deprecated = TRUE,
#'  return_type = "list"
#' )
#' movebank_get_vocabulary("Deploy.On.Date", return_type = "list")
get_mvb_term <- function(label) {
  lifecycle::deprecate_warn(
    when = "0.4.0",
    what = "get_mvb_term()",
    with = "move2::movebank_get_vocabulary()"
  )

  label_clean <- tolower(gsub("(-|_|\\.|:)", " ", label))

  # Get terms
  vocab_url <- file.path(
    "http://vocab.nerc.ac.uk/collection/MVB/current",
    "?_profile=nvs&_mediatype=application/ld+json"
  )
  vocab <- jsonlite::fromJSON(vocab_url, simplifyDataFrame = FALSE)
  terms <- purrr::keep(vocab$`@graph`, ~.$`@type` == "skos:Concept")

  # Search for concept using prefLabel, and altLabel if not found
  term <- purrr::keep(terms, function(x) {
    tolower(x$`skos:prefLabel`$`@value`) == label_clean
  })
  if (length(term) == 0) {
    term <- purrr::keep(terms, function(x) {
      tolower(x$`skos:altLabel`) == label_clean
    })
  }
  if (length(term) == 0) {
    cli::cli_abort(
      "Can't find term {.val {label_clean}} in {.href [Movebank Attribute
       Dictionary](https://vocab.nerc.ac.uk/collection/MVB/current/)}."
    )
  }
  term <- term[[1]]

  # Prepare output
  list(
    # Identifiers
    id = term$`@id`,
    # @type: "skos:Concept" for all
    identifier = term$`dc:identifier`,
    # dc:identifier: same as identifier

    # Labels
    # prefLabel$`@language`: "en" for all
    prefLabel = term$`skos:prefLabel`$`@value`,
    altLabel = term$`skos:altLabel`,

    # Definition
    # definition$`@language`: "en" for all
    definition = term$`skos:definition`$`@value`,

    # Date
    date = term$`dc:date`,
    # authoredOn: same as date

    # Versions
    version = term$`pav:version`,
    hasCurrentVersion = term$`pav:hasCurrentVersion`$`@id`,
    hasVersion = unname(unlist(term$`pav:hasVersion`)),
    # inDataset: "http://vocab.nerc.ac.uk/.well-known/void" for all
    deprecated = term$`owl:deprecated`,
    # versionInfo: same as version
    # notation: same as identifier
    # note$`@language`: "en" for all
    note = term$`skos:note`$`@value`
  )
}
