# Get DataCite metadata as EML

Get metadata from [DataCite](https://datacite.org/) and transform to
EML.

## Usage

``` r
datacite_to_eml(doi)
```

## Arguments

- doi:

  DOI of a dataset.

## Value

EML list that can be extended and/or written to file with
[`EML::write_eml()`](https://docs.ropensci.org/EML/reference/write_eml.html).

## See also

Other support functions:
[`get_aphia_id()`](https://inbo.github.io/movepub/reference/get_aphia_id.md),
[`html_to_docbook()`](https://inbo.github.io/movepub/reference/html_to_docbook.md)

## Examples

``` r
datacite_to_eml("10.5281/zenodo.10053903")
#> $packageId
#> [1] "54273343-6b9f-47bf-86de-b0eeba975eeb"
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
#> $dataset$intellectualRights
#> $dataset$intellectualRights$rights
#> [1] "Creative Commons Zero v1.0 Universal"
#> 
#> $dataset$intellectualRights$rightsUri
#> [1] "https://creativecommons.org/publicdomain/zero/1.0/legalcode"
#> 
#> $dataset$intellectualRights$schemeUri
#> [1] "https://spdx.org/licenses/"
#> 
#> $dataset$intellectualRights$rightsIdentifier
#> [1] "cc0-1.0"
#> 
#> $dataset$intellectualRights$rightsIdentifierScheme
#> [1] "SPDX"
#> 
#> 
#> $dataset$alternateIdentifier
#> [1] "https://doi.org/10.5281/zenodo.10053903"                                           
#> [2] "https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study1605797471"
#> 
#> 
```
