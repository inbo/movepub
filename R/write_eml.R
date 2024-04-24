write_dwc <- function(package, directory = ".", doi = package$id,
                      contact = NULL, rights_holder = NULL, study_id = NULL) {
  # Retrieve metadata from DataCite and build EML
  if (is.null(doi)) {
    cli::cli_abort(
      c(
        "Can't find a DOI in {.field package$id}.",
        "i" = "Provide one in {.arg doi}."
      ),
      class = "movepub_error_doi_missing"
    )
  }
  if (!is.character(doi) || length(doi) != 1) {
    cli::cli_abort(
      c(
        "{.arg doi} must be a character (vector of length one).",
        "x" = "{.val {doi}} is {.type {doi}}."
      ),
      class = "movepub_error_doi_invalid"
    )
  }
  eml <- datacite_to_eml(doi)

  # Update title
  title <- paste(eml$dataset$title, "[subsampled representation]")
  eml$dataset$title <- title
  dataset_name <- title # Used in DwC

  # Update license
  license <- eml$dataset$intellectualRights$rightsUri # Used in DwC
  if (is.null(license)) {
    license <- NA_character_
  }
  license_code <- eml$dataset$intellectualRights$rightsIdentifier
  eml$dataset$intellectualRights <- NULL # Remove original license elements that make EML invalid
  eml$dataset$intellectualRights$para <- license_code

  # Get DOI URL
  doi_url <- eml$dataset$alternateIdentifier[[1]]
  dataset_id <- doi_url # Used in DwC
  if (is.null(dataset_id)) {
    dataset_id <- NA_character_
  }

  # Get/set study url
  study_url_prefix <- "https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study"
  if (!is.null(study_id)) {
    # Provided as parameter
    study_url <- paste0(study_url_prefix, study_id)
    eml$dataset$alternateIdentifier[[2]] <- study_url # Set as second identifier
  } else {
    # Get from first "derived from" related identifier (2nd alternateIdentifier)
    study_url <- eml$dataset$alternateIdentifier[[2]]
    study_id <- if (!is.null(study_url)) {
      gsub(study_url_prefix, "", study_url, fixed = TRUE)
    } else {
      NA_character_
    }
  }
  if (!grepl("^\\d+$", study_id)) { # Works for non 32 bit integers
    cli::cli_abort(
      c(
        "{.arg study_id} must be an integer.",
        "x" = "{.val {study_id}} is {.obj {study_id}}."
      ),
      class = "movepub_error_study_id_invalid"
    )
  }

  # Add extra paragraph to description
  first_author <- eml$dataset$creator[[1]]$individualName$surName
  pub_year <- substr(eml$dataset$pubDate, 1, 4)
  first_para <- paste0(
    # Add span to circumvent https://github.com/ropensci/EML/issues/342
    "<span></span>This animal tracking dataset is derived from ",
    first_author, " et al. (", pub_year,
    ", <a href=\"", doi_url, "\">", doi_url, "</a>), ",
    "a deposit of Movebank study <a href=\"", study_url, "\">", study_id,
    "</a>. ", "Data have been standardized to Darwin Core using the ",
    "<a href=\"https://inbo.github.io/movepub/\">movepub</a> R package ",
    "and are downsampled to the first GPS position per hour. ",
    "The original dataset description follows.",
    sep = ""
  )
  eml$dataset$abstract$para <- append(
    after = 0,
    eml$dataset$abstract$para,
    paste0("<![CDATA[", first_para, "]]>")
  )

  # Update contact and set metadata provider
  if (!is.null(contact)) {
    if (!inherits(contact, "person")) {
      cli::cli_abort(
        c(
          "{.arg contact} must be person as provided by {.fn person}.",
          "x" = "{.val {contact}} is {.type {contact}}."
        ),
        class = "movepub_error_contact_invalid"
      )
    }
    eml$dataset$contact <- EML::set_responsibleParty(
      givenName = contact$given,
      surName = contact$family,
      electronicMailAddress = contact$email,
      userId = if (!is.null(contact$comment[["ORCID"]])) {
        list(directory = "https://orcid.org/", contact$comment[["ORCID"]])
      } else {
        NULL
      }
    )
  }
  eml$dataset$metadataProvider <- eml$dataset$contact

  # Set external link to Movebank study URL
  if (!is.null(study_url)) {
    eml$dataset$distribution <- list(
      scope = "document", online = list(
        url = list("function" = "information", study_url)
      )
    )
  }

  # Set rights_holder
  if (is.null(rights_holder)) {
    rights_holder <- NA_character_
  }

  # Write file
  eml_path <- file.path(directory, "eml.xml")
  cli::cli_h2("Writing file")
  cli::cli_ul(c(
    "{.file {eml_path}}"
  ))
  if (!dir.exists(directory)) {
    dir.create(directory, recursive = TRUE)
  }
  EML::write_eml(eml, eml_path)

}
