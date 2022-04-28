#' Convert DataCite metadata to EML
#'
#' Gets metadata for a DOI from DataCite and converts it to EML that can be
#' uploaded to a [GBIF IPT](https://www.gbif.org/ipt).
#'
#' @param doi DOI of a dataset.
#' @return EML list that can be extended and/or written to file with
#' [EML::write_eml()].
#' @export
datacite_to_eml <- function(doi) {
  # Read metadata from DataCite
  doi <- gsub("https://doi.org/", "", doi)
  result <- jsonlite::read_json(paste0("https://api.datacite.org/dois/", doi))
  attr <- result$data$attributes

  # Remove null values and empty lists
  attr <- clean_list(
    attr,
    function(x) is.null(x) | length(x) == 0L,
    recursive = TRUE
  )

  # Get creators
  creators <- purrr::map(attr$creators, ~ EML::set_responsibleParty(
    givenName = .$givenName,
    surName = .$familyName,
    organizationName = .$affiliation,
    userId = .$nameIdentifiers[[1]]$nameIdentifier
  ))

  # Create eml
  list(
    dataset = list(
      alternateIdentifier = paste0("https://doi.org/", attr$doi), # TODO: test
      title = attr$titles[[1]]$title,
      creator = creators,
      metadataProvider = NULL, # TODO
      pubDate = attr$publicationYear, # TODO: test, or $dates[[1]]$date
      language = attr$language, # TODO: en vs eng
      abstract = list(
        para = purrr::map_chr(attr$descriptions, function(x) {
          description <- x$description
          if (grepl("</", description)) { # Description contains HTML
            paste0("<![CDATA[", description, "]]>")
          } else {
            description
          }
        })
      ),
      keywordsSet = list(
        list(
          keywordThesaurus = "n/a",
          keyword =  purrr::map_chr(attr$subjects, "subject")
        )
      ),
      intellectualRights = attr$rightsList[[1]]$rightsUri, # TODO: test
      distribution = list(
        online = list(
          url = "https://example.org" # TODO: test
        )
      ),
      contact = NULL # TODO
      # methods
      # coverage
    )
  )
}
