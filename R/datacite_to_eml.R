#' Get DataCite metadata as EML
#'
#' Get metadata from [DataCite](https://datacite.org/) and transform to EML.
#'
#' @param doi DOI of a dataset.
#' @return EML list that can be extended and/or written to file with
#'   [EML::write_eml()].
#' @export
datacite_to_eml <- function(doi) {
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

  # Create helper function for parties
  create_party <- function(first_name, last_name, orcid, email = NULL) {
    party <- list(
      individualName = list(givenName = first_name, surName = last_name),
      # organizationName: reserved for organizations
      userId = if (!is.null(orcid)) {
        list(directory = "http://orcid.org/", gsub("https://orcid.org/", "", orcid))
      } else {
        NULL
      },
      electronicMailAddress = email
    )
    party <- clean_list(party)
  }

  # Create attributes
  title <- metadata$titles[[1]]$title
  abstract <- list(
    para = purrr::map_chr(metadata$descriptions, function(x) {
      desc <- x$description
      if (grepl("</", desc)) paste0("<![CDATA[", desc, "]]>") else desc
    })
  )
  keywords <- purrr::map_chr(metadata$subjects, "subject")
  creators <- purrr::map(metadata$creators, ~ create_party(
    # Assumes first nameIdentifier (if any) is ORCID
    .$givenName, .$familyName, .$nameIdentifiers[[1]]$nameIdentifier, NULL
  ))
  pub_date <- purrr::map_chr(metadata$dates, ~ if(.$dateType == "Issued") .$date)
  license_url <- metadata$rightsList[[1]]$rightsUri
  source_id <- if (length(metadata$relatedIdentifiers) > 0) {
    unlist(purrr::map(
      metadata$relatedIdentifiers,
      ~ if(.$relationType == "IsDerivedFrom") .$relatedIdentifier
    ))
  } else {
    NULL
  }

  # Create EML
  list(
    packageId = uuid::UUIDgenerate(),
    system = "uuid",
    dataset = list(
      title = title,
      abstract = abstract,
      keywordSet = list(list(keywordThesaurus = "n/a", keyword = keywords)),
      creator = creators,
      contact = creators[[1]], # First author,
      pubDate = pub_date,
      intellectualRights = license_url,
      alternateIdentifier = list(paste0("https://doi.org/", doi), source_id)
    )
  )
}
