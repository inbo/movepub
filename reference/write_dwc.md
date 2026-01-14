# Transform Movebank data to a Darwin Core Archive

Transforms a Movebank dataset (formatted as a [Frictionless Data
Package](https://specs.frictionlessdata.io/data-package/)) to a [Darwin
Core Archive](https://dwc.tdwg.org/text/).

## Usage

``` r
write_dwc(
  package,
  directory,
  dataset_id = package$id,
  dataset_name = package$title,
  license = NULL,
  rights_holder = NULL
)
```

## Arguments

- package:

  A Frictionless Data Package of Movebank data, as returned by
  [`read_package()`](https://docs.ropensci.org/frictionless/reference/read_package.html).
  It is expected to contain a `reference-data` and `gps` resource.

- directory:

  Path to local directory to write files to.

- dataset_id:

  Identifier for the dataset.

- dataset_name:

  Title of the dataset.

- license:

  License of the dataset.

- rights_holder:

  Acronym of the organization owning or managing the rights over the
  data.

## Value

CSV and `meta.xml` files written to disk. And invisibly, a list of data
frames with the transformed data.

## Details

The resulting files can be uploaded to an
[IPT](https://www.gbif.org/ipt) for publication to GBIF and/or OBIS. A
corresponding `eml.xml` metadata file can be created with
[`write_eml()`](https://inbo.github.io/movepub/reference/write_eml.md).
See
[`vignette("movepub")`](https://inbo.github.io/movepub/articles/movepub.md)
for an example.

## Transformation details

This function **follows recommendations** suggested by Peter Desmet,
Sarah Davidson, John Wieczorek and others and transforms data to:

- An [Occurrence
  core](https://rs.gbif.org/core/dwc_occurrence_2022-02-02.xml).

- An [Extended Measurements Or Facts
  extension](https://rs.gbif.org/extension/obis/extended_measurement_or_fact_2023-08-28.xml)

- A `meta.xml` file.

Key features of the Darwin Core transformation:

- Deployments (animal+tag associations) are parent events, with tag
  attachment (a human observation) and GPS positions (machine
  observations) as child events. No information about the parent event
  is provided other than its ID, meaning that data can be expressed in
  an Occurrence core with one row per observation and `parentEventID`
  shared by all occurrences in a deployment.

- The tag attachment event often contains metadata about the animal
  (sex, life stage, comments) and deployment as a whole. The sex and
  life stage are additionally provided in an Extended Measurement Or
  Facts extension, where values are mapped to a controlled vocabulary
  recommended by [OBIS](https://obis.org/).

- No event/occurrence is created for the deployment end, since the end
  date is often undefined, unreliable and/or does not represent an
  animal occurrence.

- Only `visible` (non-outlier) GPS records that fall within a deployment
  are included.

- GPS positions are downsampled to the **first GPS position per hour**,
  to reduce the size of high-frequency data. It is possible for a
  deployment to contain no GPS positions, e.g. if the tag malfunctioned
  right after deployment.

- Parameters or metadata are used to set the following record-level
  terms:

  - `dwc:datasetID`: `dataset_id`, defaulting to `package$id`.

  - `dwc:datasetName`: `dataset_name`, defaulting to `package$title`.

  - `dcterms:license`: `license`, defaulting to the first license `name`
    (e.g. `CC0-1.0`) in `package$licenses`.

  - `dcterms:rightsHolder`: `rights_holder`, defaulting to the first
    contributor in `package$contributors` with role `rightsHolder`.

## Required data

The source data should have the following resources and fields:

- **reference-data** with at least the fields `animal-id`,
  `animal-taxon`, and `tag-id`. Records must have a `deploy-on-date` to
  be retained.

- **gps** with at least the fields `individual-local-identifier`,
  `tag-local-identifier`, and `timestamp`. Records must have a
  `location-lat`, `visible = TRUE` and a link with the reference data to
  be retained.

## See also

Other dwc functions:
[`write_eml()`](https://inbo.github.io/movepub/reference/write_eml.md)

## Examples

``` r
write_dwc(o_assen, directory = "my_directory")
#> 
#> ── Reading data ──
#> 
#> ℹ Taxa found in reference data and their WoRMS AphiaID:
#> Haematopus ostralegus: 147436
#> (<https://www.marinespecies.org/aphia.php?p=taxdetails&id=147436>)
#> 
#> ── Transforming data to Darwin Core ──
#> 
#> ── Writing files ──
#> 
#> • my_directory/occurrence.csv
#> • my_directory/meta.xml
#> • my_directory/emof.csv

# Clean up (don't do this if you want to keep your files)
unlink("my_directory", recursive = TRUE)
```
