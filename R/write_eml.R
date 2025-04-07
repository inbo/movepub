#' Transform Movebank metadata to EML
#'
#' Transforms the metadata of a published Movebank dataset (with a DOI) to an
#' [Ecological Metadata Language (EML)](https://eml.ecoinformatics.org/) file.
#'
#' The resulting EML file can be uploaded to an [IPT](https://www.gbif.org/ipt)
#' for publication to GBIF and/or OBIS.
#' A corresponding Darwin Core Archive can be created with [write_dwc()].
#' See `vignette("movepub")` for an example.
#'
#' @param doi DOI of the original dataset, used to get metadata.
#' @param directory Path to local directory to write files to.
#' @param contact Person to be set as resource contact and metadata provider.
#'   To be provided as a [person()].
#' @param study_id Identifier of the Movebank study from which the dataset was
#'   derived (e.g. `1605797471` for [this study](
#'   https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study1605797471)).
#' @param derived_paragraph If `TRUE`, a paragraph will be added to the
#'   abstract, indicating that data have been transformed using `write_dwc()`.
#' @return `eml.xml` file written to disk.
#'   And invisibly, an [EML::eml] object.
#' @family dwc functions
#' @export
#' @section Transformation details:
#' Metadata are derived from the original dataset by looking up its `doi` in
#' DataCite ([example](https://api.datacite.org/dois/10.5281/zenodo.5879096))
#' and transforming these to EML.
#' The following properties are set:
#' - **title**: Original dataset title.
#' - **description**: Original dataset description.
#'   If `derived_paragraph = TRUE` a generated paragraph is added, e.g.:
#'
#'   Data have been standardized to Darwin Core using the [movepub](
#'   https://inbo.github.io/movepub/) R package and are downsampled to the first
#'   GPS position per hour. The original data are available in Dijkstra et al.
#'   (2023, <https://doi.org/10.5281/zenodo.10053903>), a deposit of Movebank
#'   study [1605797471](
#'   https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study1605797471).
#' - **license**: License of the original dataset.
#' - **creators**: Creators of the original dataset.
#' - **contact**: `contact` or first creator of the original dataset.
#' - **metadata provider**: `contact` or first creator of the original dataset.
#' - **keywords**: Keywords of the original dataset.
#' - **alternative identifier**: DOI of the original dataset.
#'   As a result, no new DOI will be created when publishing to GBIF.
#' - **external link** and **alternative identifier**: URL created from
#'   `study_id` or the first `derived from` related identifier in the original
#'   dataset.
#'
#' The following properties are not set:
#' - **type**
#' - **subtype**
#' - **update frequency**
#' - **publishing organization**
#' - **geographic coverage**
#' - **taxonomic coverage**
#' - **temporal coverage**
#' - **associated parties**
#' - **project data**
#' - **sampling methods**
#' - **citations**
#' - **collection data**: not applicable.
#' @examples
#' (write_eml(doi = "10.5281/zenodo.10053903", directory = "my_directory"))
#'
#' # Clean up (don't do this if you want to keep your files)
#' unlink("my_directory", recursive = TRUE)
write_eml <- function(doi, directory, contact = NULL, study_id = NULL,
                      derived_paragraph = TRUE) {
  # Check DOI
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

  # Retrieve metadata from DataCite and build EML
  eml <- datacite_to_eml(doi)

  # Update license
  license_code <- eml$dataset$intellectualRights$rightsIdentifier
  # Remove original license elements that make EML invalid
  eml$dataset$intellectualRights <- NULL
  eml$dataset$intellectualRights$para <- license_code

  # Get DOI URL
  doi_url <- eml$dataset$alternateIdentifier[[1]]

  # Get/set study URL
  study_url_prefix <-
    "https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study"
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

  # Clean abstract
  description_full <- eml$dataset$abstract$para
  paragraphs <- unlist(strsplit(description_full, "<p>|</p>|\n", perl = TRUE))
  paragraphs <- paragraphs[paragraphs != ""] %>%
    # Add <p></p> tags to each paragraph
    purrr::map_chr(~ paste0("<p>", ., "</p>"))

  # Add extra paragraph to description
  if (derived_paragraph) {
    first_author <- eml$dataset$creator[[1]]$individualName$surName
    pub_year <- substr(eml$dataset$pubDate, 1, 4)
    last_para <- paste0(
      "<p>Data have been standardized to Darwin Core using the ",
      "<a href=\"https://inbo.github.io/movepub/\">movepub</a> R package ",
      "and are downsampled to the first GPS position per hour. ",
      "The original data are available in ", first_author, " et al. (",
      pub_year, ", <a href=\"", doi_url, "\">", doi_url, "</a>), ",
      "a deposit of Movebank study <a href=\"", study_url, "\">", study_id,
      "</a>.</p>"
    )
    paragraphs <- append(paragraphs, last_para)
  }

  # Add collapsed paragraphs to EML
  eml$dataset$abstract$para <- paste0(paragraphs , collapse = "")

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

  # Return EML list invisibly
  invisible(eml)
}
