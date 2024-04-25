#' Transform Movebank data to EML (metadata)
#'
#' Uses the doi of a Movebank dataset (formatted as a [Frictionless Data
#' Package](https://specs.frictionlessdata.io/data-package/)) to derive
#' metadata from Datacite and build EML.
#' The resulting EML file can be uploaded to an [IPT](https://www.gbif.org/ipt)
#' for publication to GBIF and/or OBIS, together with a CSV (data) file created
#' with `write_dwc()`
#' A `meta.xml` file is not created.
#'
#' See [Get started](https://inbo.github.io/movepub/articles/movepub.html#dwc)
#' for examples.
#'
#' @param package A Frictionless Data Package of Movebank data, as read by
#'   [frictionless::read_package()].
#' @param directory Path to local directory to write file(s) to.
#' @param doi DOI of the original dataset, used to get metadata.
#' @param contact Person to be set as resource contact and metadata provider.
#'   To be provided as a [person()].
#' @param study_id Identifier of the Movebank study from which the dataset was
#'   derived (e.g. `1605797471` for
#'   [this study](https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study160579747)). # nolint: line_length_linter
#' @return EML (metadata) file written to disk.
#' @family dwc functions
#' @export
#' @section Metadata:
#' Metadata are derived from the original dataset by looking up its `doi` in
#' DataCite ([example](https://api.datacite.org/dois/10.5281/zenodo.5879096))
#' and transforming these to EML.
#' Uses `datacite_to_eml()` under the hood.
#' The following properties are set:
#'
#' - **title**: Original title + `[subsampled representation]`.
#' - **description**: Automatically created first paragraph describing this is
#'   a derived dataset, followed by the original dataset description.
#' - **license**: License of the original dataset.
#' - **creators**: Creators of the original dataset.
#' - **contact**: `contact` or first creator of the original dataset.
#' - **metadata provider**: `contact` or first creator of the original dataset.
#' - **keywords**: Keywords of the original dataset.
#' - **alternative identifier**: DOI of the original dataset. This way, no new
#'   DOI will be created when publishing to GBIF.
#' - **external link** and **alternative identifier**: URL created from
#'   `study_id` or the first "derived from" related identifier in the original
#'   dataset.
#'
#' To be set manually in the GBIF IPT: **type**, **subtype**,
#' **update frequency**, and **publishing organization**.
#'
#' Not set: geographic, taxonomic, temporal coverage, associated parties,
#' project data, sampling methods, and citations.
#' Not applicable: collection data.
#' @examples
#' \dontrun{
#' write_eml(o_assen)
#' # same as
#' write_eml(doi = "10.5281/zenodo.10053903")
#' }
write_eml <- function(package, directory = ".", doi = package$id,
                      contact = NULL, study_id = NULL) {
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

  # Update license
  license_code <- eml$dataset$intellectualRights$rightsIdentifier
  # Remove original license elements that make EML invalid
  eml$dataset$intellectualRights <- NULL
  eml$dataset$intellectualRights$para <- license_code

  # Get DOI URL
  doi_url <- eml$dataset$alternateIdentifier[[1]]

  # Get/set study url
  study_url_prefix <- "https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study" # nolint: line_length_linter
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
