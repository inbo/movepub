#' Add Movebank data to a Frictionless Data Package
#'
#' Adds Movebank data (`reference-data`, `gps`, `acceleration`,
#' `accessory-measurements`) as a Data Resource to a Frictionless Data Package.
#' This function extends and masks `[frictionless::add_resource()]`.
#'
#' @inheritParams frictionless::read_resource
#' @param files One or more paths to CSV file(s) that contain the data for
#'   this resource, as a character (vector).
#' @param keys Should `primaryKey` and `foreignKey` properties be added to the
#'   Table Schema?
#' @return Provided `package` with one additional resource.
#' @export
add_resource <- function(package, resource_name, files, keys = TRUE) {
  # Check resource names
  allowed_names <- c("reference-data", "gps", "acceleration",
                     "accessory-measurements")
  allowed_names_collapsed <- paste(allowed_names, collapse = "`, `")
  assertthat::assert_that(
    resource_name %in% allowed_names,
    msg = glue::glue(
      "`resource_name` must be a recognized Movebank data type:",
      "`{allowed_names_collapsed}`.",
      .sep = " "
    )
  )

  # Read last file and create schema
  last_file <- files[length(files)]
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

  # Add keys
  if (keys) {
    if (resource_name == "reference-data") {
      schema$primaryKey <- c("tag-id", "animal-id")
    } else {
      schema$primaryKey <- "event-id"
      schema$foreignKeys <- list(
        list(
          fields = c("tag-local-identifier", "individual-local-identifier"),
          reference = list(
            resource = "reference-data",
            fields = c("tag-id", "animal-id")
          )
        )
      )
    }
  }

  # Add resource to package
  frictionless::add_resource(
    package = package,
    resource_name = resource_name,
    data = files,
    schema = schema
  )
}
