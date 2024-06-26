#' Get DataCite metadata as EML
#'
#' Get metadata from [DataCite](https://datacite.org/) and transform to EML.
#'
#' @param doi DOI of a dataset.
#' @return EML list that can be extended and/or written to file with
#'   [EML::write_eml()].
#' @family support functions
#' @export
datacite_to_eml <- function(doi) {
  # Read metadata from DataCite
  doi <- gsub("https://doi.org/", "", doi, fixed = TRUE)
  result <- jsonlite::read_json(file.path("https://api.datacite.org/dois/", doi))
  metadata <- result$data$attributes

  # Remove null values and empty lists
  metadata <- clean_list(
    metadata,
    function(x) is.null(x) | length(x) == 0L,
    recursive = TRUE
  )

  # Create attributes
  title <- metadata$titles[[1]]$title
  abstract <- list(
    para = purrr::map_chr(metadata$descriptions, function(x) {
      desc <- x$description
      if (grepl("</", desc)) paste0("<![CDATA[", desc, "]]>") else desc
    })
  )
  keywords <- purrr::map_chr(metadata$subjects, "subject")
  creators <- purrr::map(metadata$creators, ~ EML::set_responsibleParty(
    givenName = .$givenName,
    surName = .$familyName,
    userId = if (!is.null(.$nameIdentifiers[[1]]$nameIdentifier)) {
      list(
        directory = "https://orcid.org/",
        gsub("https://orcid.org/", "", .$nameIdentifiers[[1]]$nameIdentifier)
      )
    } else {
      NULL
    }
  ))
  pub_date <- purrr::map_chr(metadata$dates, ~
                               if (.$dateType == "Issued") .$date)
  source_id <- if (length(metadata$relatedIdentifiers) > 0) {
    unlist(purrr::map(
      metadata$relatedIdentifiers,
      ~ if (.$relationType == "IsDerivedFrom") .$relatedIdentifier
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
      intellectualRights = metadata$rightsList[[1]],
      alternateIdentifier = append(paste0("https://doi.org/", doi), source_id)
    )
  )
}
