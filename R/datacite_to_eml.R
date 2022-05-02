#' Convert DataCite metadata to EML
#'
#' Gets metadata for a DOI from DataCite and converts it to EML that can be
#' uploaded to a [GBIF IPT](https://www.gbif.org/ipt).
#'
#' @param doi DOI of a dataset.
#' @param contact One or more persons to be set as resource contact. Provide as
#'   person objects, e.g. `person("Peter", "Desmet", , "fakeaddress@email.com",
#'   "mdc", c(ORCID = "0000-0002-8442-8025"))`.
#' @param metadata_provider One or more person to be set as metadata provider.
#'   Same format as `contact`.
#' @return EML list that can be extended and/or written to file with
#' [EML::write_eml()].
#' @export
datacite_to_eml <- function(doi, contact, metadata_provider = contact) {
  # Read metadata from DataCite
  doi <- gsub("https://doi.org/", "", doi)
  result <- jsonlite::read_json(paste0("https://api.datacite.org/dois/", doi))
  metadata <- result$data$attributes

  # Remove null values and empty lists
  metadata <- clean_list(
    metadata,
    function(x) is.null(x) | length(x) == 0L,
    recursive = TRUE
  )

  # Set parties
  create_party <- function(first_name, last_name, orcid, email = NULL) {
    party <- list(
      individualName = list(givenName = first_name, surName = last_name),
      # organizationName: reserved for organizations
      userId = if (!is.null(orcid)) {
        # Note that GBIF IPT sets directory to http, not https
        list(directory = "http://orcid.org/", gsub("https://orcid.org/", "", orcid))
      } else {
        NULL
      },
      electronicMailAddress = email
    )
    party <- clean_list(party)
  }
  contacts <- purrr::map(contact, ~ create_party(
    .$given, .$family, .$comment, .$email
  ))
  metadata_providers <- purrr::map(metadata_provider, ~ create_party(
    .$given, .$family, .$comment, .$email
  ))
  creators <- purrr::map(metadata$creators, ~ create_party(
    .$givenName, .$familyName, .$nameIdentifiers[[1]]$nameIdentifier, NULL
  ))

  # Create eml
  list(
    dataset = list(
      title = metadata$titles[[1]]$title,
      abstract = list(
        para = purrr::map_chr(metadata$descriptions, function(x) {
          description <- x$description
          if (grepl("</", description)) {
            paste0("<![CDATA[", description, "]]>") # Wrap HTML
          } else {
            description
          }
        })
      ),
      contact = contacts,
      creator = creators,
      metadataProvider = metadata_providers,
      keywordsSet = list(
        list(
          keywordThesaurus = "n/a",
          keyword =  purrr::map_chr(metadata$subjects, "subject")
        )
      ),
      pubDate = metadata$publicationYear, # TODO: test, or $dates[[1]]$date
      # language: not set, GBIF IPT will assume English
      intellectualRights = metadata$rightsList[[1]]$rightsUri, # TODO: test
      distribution = list(
        online = list(
          url = "https://example.org" # TODO: test
        )
      ),
      alternateIdentifier = paste0("https://doi.org/", metadata$doi) # TODO: test
      # methods TODO
      # coverage TODO
    )
  )
}
