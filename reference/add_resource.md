# Add Movebank data to a Frictionless Data Package

Adds Movebank data (`reference-data`, `gps`, `acceleration`,
`accessory-measurements`) as a Data Resource to a Frictionless Data
Package. The function extends
[`frictionless::add_resource()`](https://docs.ropensci.org/frictionless/reference/add_resource.html).
The title, definition, format and URI of each field are looked up in the
latest version of the [Movebank Attribute
Dictionary](http://vocab.nerc.ac.uk/collection/MVB/current/) and
included in the Table Schema of the resource.

## Usage

``` r
add_resource(package, resource_name, files, keys = TRUE)
```

## Arguments

- package:

  Data Package object, as returned by
  [`read_package()`](https://docs.ropensci.org/frictionless/reference/read_package.html)
  or
  [`create_package()`](https://docs.ropensci.org/frictionless/reference/create_package.html).

- resource_name:

  Name of the Data Resource.

- files:

  One or more paths to CSV file(s) that contain the data for this
  resource, as a character (vector).

- keys:

  If `TRUE`, `primaryKey` and `foreignKey` properties are added to the
  Table Schema.

## Value

Provided `package` with one additional resource.

## Details

See
[`vignette("movepub")`](https://inbo.github.io/movepub/articles/movepub.md)
for examples.
