# Transform Movebank metadata to EML

Transforms the metadata of a published Movebank dataset (with a DOI) to
an [Ecological Metadata Language (EML)](https://eml.ecoinformatics.org/)
file.

## Usage

``` r
write_eml(
  doi,
  directory,
  contact = NULL,
  study_id = NULL,
  derived_paragraph = TRUE
)
```

## Arguments

- doi:

  DOI of the original dataset, used to get metadata.

- directory:

  Path to local directory to write files to.

- contact:

  Person to be set as resource contact and metadata provider. To be
  provided as a [`person()`](https://rdrr.io/r/utils/person.html).

- study_id:

  Identifier of the Movebank study from which the dataset was derived
  (e.g. `1605797471` for [this
  study](https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study1605797471)).

- derived_paragraph:

  If `TRUE`, a paragraph will be added to the abstract, indicating that
  data have been transformed using
  [`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md).

## Value

`eml.xml` file written to disk. And invisibly, an
[EML::eml](https://docs.ropensci.org/EML/reference/eml.html) object.

## Details

The resulting EML file can be uploaded to an
[IPT](https://www.gbif.org/ipt) for publication to GBIF and/or OBIS. A
corresponding Darwin Core Archive can be created with
[`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md).
See
[`vignette("movepub")`](https://inbo.github.io/movepub/articles/movepub.md)
for an example.

## Transformation details

Metadata are derived from the original dataset by looking up its `doi`
in DataCite
([example](https://api.datacite.org/dois/10.5281/zenodo.5879096)) and
transforming these to EML. The following properties are set:

- **title**: Original dataset title.

- **description**: Original dataset description. If
  `derived_paragraph = TRUE` a generated paragraph is added, e.g.:

  Data have been standardized to Darwin Core using the
  [movepub](https://inbo.github.io/movepub/) R package and are
  downsampled to the first GPS position per hour. The original data are
  available in Dijkstra et al. (2023,
  [doi:10.5281/zenodo.10053903](https://doi.org/10.5281/zenodo.10053903)
  ), a deposit of Movebank study
  [1605797471](https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study1605797471).

- **license**: License of the original dataset.

- **creators**: Creators of the original dataset.

- **contact**: `contact` or first creator of the original dataset.

- **metadata provider**: `contact` or first creator of the original
  dataset.

- **keywords**: Keywords of the original dataset.

- **alternative identifier**: DOI of the original dataset. As a result,
  no new DOI will be created when publishing to GBIF.

- **external link** and **alternative identifier**: URL created from
  `study_id` or the first `derived from` related identifier in the
  original dataset.

The following properties are not set:

- **type**

- **subtype**

- **update frequency**

- **publishing organization**

- **geographic coverage**

- **taxonomic coverage**

- **temporal coverage**

- **associated parties**

- **project data**

- **sampling methods**

- **citations**

- **collection data**: not applicable.

## See also

Other dwc functions:
[`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md)

## Examples

``` r
(write_eml(doi = "10.5281/zenodo.10053903", directory = "my_directory"))
#> 
#> ── Writing file ──
#> 
#> • my_directory/eml.xml
#> $packageId
#> [1] "9decfc06-09df-41e7-8775-66276eeb7f46"
#> 
#> $system
#> [1] "uuid"
#> 
#> $dataset
#> $dataset$title
#> [1] "O_ASSEN - Eurasian oystercatchers (Haematopus ostralegus, Haematopodidae) breeding in Assen (the Netherlands)"
#> 
#> $dataset$abstract
#> $dataset$abstract$para
#> [1] "O_ASSEN - Eurasian oystercatchers (Haematopus ostralegus, Haematopodidae) breeding in Assen (the Netherlands) is a bird tracking dataset published by the Vogelwerkgroep Assen, Netherlands Institute of Ecology (NIOO-KNAW), Sovon, Radboud University, the University of Amsterdam and the Research Institute for Nature and Forest (INBO). It contains animal tracking data collected for the study O_ASSEN using trackers developed by the University of Amsterdam Bird Tracking System (UvA-BiTS, http://www.uva-bits.nl). The study was operational from 2018 to 2019. In total 6 individuals of Eurasian oystercatchers (Haematopus ostralegus) have been tagged as a breeding bird in the city of Assen (the Netherlands), mainly to study space use of oystercatchers breeding in urban areas. Data are uploaded from the UvA-BiTS database to Movebank and from there archived on Zenodo (see https://github.com/inbo/bird-tracking). No new data are expected.\n\nSee van der Kolk et al. (2022, https://doi.org/10.3897/zookeys.1123.90623) for a more detailed description of this dataset.\n\nFiles\n\nData in this package are exported from Movebank study 1605797471. Fields in the data follow the Movebank Attribute Dictionary and are described in datapackage.json. Files are structured as a Frictionless Data Package. You can access all data in R via https://zenodo.org/records/10053903/files/datapackage.json using frictionless.\n\n\n\ndatapackage.json: technical description of the data files.\n\nO_ASSEN-reference-data.csv: reference data about the animals, tags and deployments.\n\nO_ASSEN-gps-yyyy.csv.gz: GPS data recorded by the tags, grouped by year.\n\nO_ASSEN-acceleration-yyyy.csv.gz: acceleration data recorded by the tags, grouped by year.\n\n\nAcknowledgements\n\nThese data were collected by Bert Dijkstra and Rinus Dillerop from Vogelwerkgroep Assen, in collaboration with the Netherlands Institute of Ecology (NIOO-KNAW), Sovon, Radboud University and the University of Amsterdam (UvA). Funding was provided by the Prins Bernard Cultuurfonds Drenthe, municipality of Assen, IJsvogelfonds (from Birdlife Netherlands and Nationale Postcodeloterij) and the Waterleiding Maatschappij Drenthe. The dataset was published with funding from Stichting NLBIF - Netherlands Biodiversity Information Facility."
#> [2] "Changelog\n\n\n\nAdd alt-project-id to the reference-data.\n\nReference the latest Movebank Attribute Dictionary."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
#> [3] "Data have been standardized to Darwin Core using the <ulink url=\"https://inbo.github.io/movepub/\"><citetitle>movepub</citetitle></ulink> R package and are downsampled to the first GPS position per hour. The original data are available in Dijkstra et al. (2023, <ulink url=\"https://doi.org/10.5281/zenodo.10053903\"><citetitle>https://doi.org/10.5281/zenodo.10053903</citetitle></ulink>), a deposit of Movebank study <ulink url=\"https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study1605797471\"><citetitle>1605797471</citetitle></ulink>."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
#> 
#> 
#> $dataset$keywordSet
#> $dataset$keywordSet[[1]]
#> $dataset$keywordSet[[1]]$keywordThesaurus
#> [1] "n/a"
#> 
#> $dataset$keywordSet[[1]]$keyword
#>  [1] "animal movement"  "animal tracking"  "gps tracking"     "accelerometer"   
#>  [5] "altitude"         "temperature"      "biologging"       "birds"           
#>  [9] "UvA-BiTS"         "Movebank"         "frictionlessdata"
#> 
#> 
#> 
#> $dataset$creator
#> $dataset$creator[[1]]
#> '@id': ~
#> address: ~
#> electronicMailAddress: ~
#> individualName:
#>   givenName: Bert
#>   surName: Dijkstra
#> onlineUrl: ~
#> organizationName: ~
#> phone: ~
#> positionName: ~
#> userId: ~
#> 
#> $dataset$creator[[2]]
#> '@id': ~
#> address: ~
#> electronicMailAddress: ~
#> individualName:
#>   givenName: Rinus
#>   surName: Dillerop
#> onlineUrl: ~
#> organizationName: ~
#> phone: ~
#> positionName: ~
#> userId: ~
#> 
#> $dataset$creator[[3]]
#> '@id': ~
#> address: ~
#> electronicMailAddress: ~
#> individualName:
#>   givenName: Kees
#>   surName: Oosterbeek
#> onlineUrl: ~
#> organizationName: ~
#> phone: ~
#> positionName: ~
#> userId: ~
#> 
#> $dataset$creator[[4]]
#> '@id': ~
#> address: ~
#> electronicMailAddress: ~
#> individualName:
#>   givenName: Willem
#>   surName: Bouten
#> onlineUrl: ~
#> organizationName: ~
#> phone: ~
#> positionName: ~
#> userId:
#>   directory: https://orcid.org/
#>   '': 0000-0002-5250-8872
#> 
#> $dataset$creator[[5]]
#> '@id': ~
#> address: ~
#> electronicMailAddress: ~
#> individualName:
#>   givenName: Peter
#>   surName: Desmet
#> onlineUrl: ~
#> organizationName: ~
#> phone: ~
#> positionName: ~
#> userId:
#>   directory: https://orcid.org/
#>   '': 0000-0002-8442-8025
#> 
#> $dataset$creator[[6]]
#> '@id': ~
#> address: ~
#> electronicMailAddress: ~
#> individualName:
#>   givenName: Henk-Jan
#>   surName: van der Kolk
#> onlineUrl: ~
#> organizationName: ~
#> phone: ~
#> positionName: ~
#> userId:
#>   directory: https://orcid.org/
#>   '': 0000-0002-8023-379X
#> 
#> $dataset$creator[[7]]
#> '@id': ~
#> address: ~
#> electronicMailAddress: ~
#> individualName:
#>   givenName: Bruno J.
#>   surName: Ens
#> onlineUrl: ~
#> organizationName: ~
#> phone: ~
#> positionName: ~
#> userId:
#>   directory: https://orcid.org/
#>   '': 0000-0002-4659-4807
#> 
#> 
#> $dataset$contact
#> '@id': ~
#> address: ~
#> electronicMailAddress: ~
#> individualName:
#>   givenName: Bert
#>   surName: Dijkstra
#> onlineUrl: ~
#> organizationName: ~
#> phone: ~
#> positionName: ~
#> userId: ~
#> 
#> $dataset$pubDate
#> [1] "2023-10-30"
#> 
#> $dataset$alternateIdentifier
#> [1] "https://doi.org/10.5281/zenodo.10053903"                                           
#> [2] "https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study1605797471"
#> 
#> $dataset$intellectualRights
#> $dataset$intellectualRights$para
#> [1] "cc0-1.0"
#> 
#> 
#> $dataset$metadataProvider
#> '@id': ~
#> address: ~
#> electronicMailAddress: ~
#> individualName:
#>   givenName: Bert
#>   surName: Dijkstra
#> onlineUrl: ~
#> organizationName: ~
#> phone: ~
#> positionName: ~
#> userId: ~
#> 
#> $dataset$distribution
#> $dataset$distribution$scope
#> [1] "document"
#> 
#> $dataset$distribution$online
#> $dataset$distribution$online$url
#> $dataset$distribution$online$url$`function`
#> [1] "information"
#> 
#> $dataset$distribution$online$url[[2]]
#> [1] "https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study1605797471"
#> 
#> 
#> 
#> 
#> 

# Clean up (don't do this if you want to keep your files)
unlink("my_directory", recursive = TRUE)
```
