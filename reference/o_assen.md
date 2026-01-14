# Sample Movebank dataset with GPS tracking data

A sample Movebank dataset with GPS tracking data, formatted as a
[Frictionless Data
Package](https://specs.frictionlessdata.io/data-package/) and read by
[`read_package()`](https://docs.ropensci.org/frictionless/reference/read_package.html).

## Usage

``` r
o_assen
```

## Format

An object of class `datapackage` (inherits from `list`) of length 7.

## Source

[doi:10.5281/zenodo.10053903](https://doi.org/10.5281/zenodo.10053903)

## Details

This sample is derived from the Zenodo-deposited dataset [Dijkstra et
al. (2023)](https://zenodo.org/records/10053903), but excludes the
acceleration data.

## Examples

``` r
if (FALSE) { # \dontrun{
# The data in o_assen was created with the code below
o_assen <-
  read_package("https://zenodo.org/records/10053903/files/datapackage.json") |>
  remove_resource("acceleration")
o_assen$title <- paste(
  "O_ASSEN - Eurasian oystercatchers (Haematopus ostralegus, Haematopodidae),",
  "breeding in Assen (the Netherlands)"
)
o_assen$licenses[[1]]$name <- "CC0-1.0"
o_assen$contributors[[1]]$title <- "Vogelwerkgroep Assen"
o_assen$contributors[[1]]$role <- "rightsHolder"
usethis::use_data(o_assen, overwrite = TRUE)
} # }
```
