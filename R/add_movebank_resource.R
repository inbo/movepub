#' Add Movebank Data Resource
#'
#' [frictionless::add_resource()] for [Movebank](https://www.movebank.org/)
#' data.
#'
#' @inheritParams frictionless::read_resource
#' @param csv_files One or more paths to CSV file(s) that contain the data for
#'   this resource, as a character (vector).
#' @return Provided `package` with one additional resource.
#' @export
add_movebank_resource <- function(package, resource_name, csv_files) {
  # Read last file and create schema
  last_file <- csv_files[length(csv_files)]
  df <- readr::read_csv(last_file, show_col_types = FALSE)
  schema <- frictionless::create_schema(df)

  # Rebuild and extends field properties
  fields <- purrr::map(schema$fields, function(field) {
    term <- get_movebank_term(field$name)
    type <- dplyr::recode(term$prefLabel,
      "tag ID" = "string",
      "tag local identifier" = "string",
      "animal ID" = "string",
      "individual local identifier" = "string",
      "deployment ID" = "string",
      "tag serial no" = "string",
      "event ID" = "integer",
      "GPS satellite count" = "integer",
      "barometric pressure" = "number",
      .missing = field$type,
      .default = field$type
    )

    list(
      name = field$name,
      title = term$prefLabel,
      description = term$definition,
      type = type,
      format = ifelse(
        grepl("Format: yyyy-MM-dd HH:mm:ss.SSS;", term$definition),
        "%Y-%m-%d %H:%M:%S.%f",
        "default"
      ),
      `skos:exactMatch` = term$hasCurrentVersion
    )
  })
  schema$fields <- fields

  # Add resource to package
  frictionless::add_resource(
    package = package,
    resource_name = resource_name,
    data = csv_files,
    schema = schema
  )
}
