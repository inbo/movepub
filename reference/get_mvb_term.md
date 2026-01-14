# Get term from the Movebank Attribute Dictionary

**\[deprecated\]**

This function is deprecated in favour of
[`move2::movebank_get_vocabulary()`](https://bartk.gitlab.io/move2/reference/movebank_get_vocabulary.html),
which offers the same functionality and more.

Search a term by its label in the [Movebank Attribute Dictionary
(MVB)](http://vocab.nerc.ac.uk/collection/MVB/current/). Returns in
order: term with matching `prefLabel`, matching `altLabel` or error when
no matching term is found.

## Usage

``` r
get_mvb_term(label)
```

## Arguments

- label:

  Label of the term to look for. Case will be ignored and `-`, `_`, `.`
  and `:` interpreted as space.

## Value

List with term information.

## Examples

``` r
get_mvb_term("animal_id")
#> Warning: `get_mvb_term()` was deprecated in movepub 0.4.0.
#> ℹ Please use `move2::movebank_get_vocabulary()` instead.
#> $id
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/"
#> 
#> $identifier
#> [1] "SDN:MVB::MVB000016"
#> 
#> $prefLabel
#> [1] "animal ID"
#> 
#> $altLabel
#> [1] "individual local identifier"
#> 
#> $definition
#> [1] "An individual identifier for the animal, provided by the data owner. Values are unique within the study. If the data owner does not provide an Animal ID, an internal Movebank animal identifier is sometimes shown. Example: 'TUSC_CV5'; Units: none; Entity described: individual"
#> 
#> $date
#> [1] "2022-08-15 10:20:18.0"
#> 
#> $version
#> [1] "3"
#> 
#> $hasCurrentVersion
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/3/"
#> 
#> $hasVersion
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/1/"
#> [2] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/2/"
#> 
#> $deprecated
#> [1] "false"
#> 
#> $note
#> [1] "accepted"
#> 
get_mvb_term("individual-local-identifier") # A deprecated term
#> $id
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000134/"
#> 
#> $identifier
#> [1] "SDN:MVB::MVB000134"
#> 
#> $prefLabel
#> [1] "individual local identifier"
#> 
#> $altLabel
#> [1] "animal ID"
#> 
#> $definition
#> [1] "This attribute has been merged with 'animal ID'. An individual identifier for the animal, provided by the data owner. Values are unique within the study. If the data owner does not provide an Animal ID, an internal Movebank animal identifier is sometimes shown. Example: '91876A, Gary'; Units: none; Entity described: individual"
#> 
#> $date
#> [1] "2022-09-23 14:36:33.0"
#> 
#> $version
#> [1] "4"
#> 
#> $hasCurrentVersion
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000134/4/"
#> 
#> $hasVersion
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000134/2/"
#> [2] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000134/3/"
#> [3] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000134/1/"
#> 
#> $deprecated
#> [1] "true"
#> 
#> $note
#> [1] "deprecated"
#> 
get_mvb_term("Deploy.On.Date")
#> $id
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000081/"
#> 
#> $identifier
#> [1] "SDN:MVB::MVB000081"
#> 
#> $prefLabel
#> [1] "deploy on timestamp"
#> 
#> $altLabel
#> [1] "deploy on date"
#> 
#> $definition
#> [1] "The timestamp when the tag deployment started. Data records recorded before this day and time are not associated with the animal related to the deployment. Values are typically defined by the data owner, and in some cases are created automatically during data import. Example: '2008-08-30 18:00:00.000'; Format: yyyy-MM-dd HH:mm:ss.SSS; Units: UTC or GPS time; Entity described: deployment"
#> 
#> $date
#> [1] "2022-08-15 10:20:18.0"
#> 
#> $version
#> [1] "3"
#> 
#> $hasCurrentVersion
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000081/3/"
#> 
#> $hasVersion
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000081/1/"
#> [2] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000081/2/"
#> 
#> $deprecated
#> [1] "false"
#> 
#> $note
#> [1] "accepted"
#> 

# With move2
library(move2)
movebank_get_vocabulary("animal_id", return_type = "list")
#> $animal_id
#> $animal_id$hasVersion
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/1/"
#> 
#> $animal_id$hasVersion
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/2/"
#> 
#> $animal_id$type
#> list()
#> attr(,"resource")
#> [1] "http://www.w3.org/2004/02/skos/core#Concept"
#> 
#> $animal_id$related
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/collection/P06/current/XXXX/"
#> 
#> $animal_id$definition
#> $animal_id$definition[[1]]
#> [1] "An individual identifier for the animal, provided by the data owner. Values are unique within the study. If the data owner does not provide an Animal ID, an internal Movebank animal identifier is sometimes shown. Example: 'TUSC_CV5'; Units: none; Entity described: individual"
#> 
#> attr(,"lang")
#> [1] "en"
#> 
#> $animal_id$inDataset
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/.well-known/void"
#> 
#> $animal_id$deprecated
#> $animal_id$deprecated[[1]]
#> [1] "false"
#> 
#> 
#> $animal_id$note
#> $animal_id$note[[1]]
#> [1] "accepted"
#> 
#> attr(,"lang")
#> [1] "en"
#> 
#> $animal_id$identifier
#> $animal_id$identifier[[1]]
#> [1] "SDN:MVB::MVB000016"
#> 
#> 
#> $animal_id$prefLabel
#> $animal_id$prefLabel[[1]]
#> [1] "animal ID"
#> 
#> attr(,"lang")
#> [1] "en"
#> 
#> $animal_id$versionInfo
#> $animal_id$versionInfo[[1]]
#> [1] "3"
#> 
#> 
#> $animal_id$date
#> $animal_id$date[[1]]
#> [1] "2022-08-15 10:20:18.0"
#> 
#> 
#> $animal_id$altLabel
#> $animal_id$altLabel[[1]]
#> [1] "individual local identifier"
#> 
#> 
#> $animal_id$notation
#> $animal_id$notation[[1]]
#> [1] "SDN:MVB::MVB000016"
#> 
#> 
#> $animal_id$version
#> $animal_id$version[[1]]
#> [1] "3"
#> 
#> 
#> $animal_id$identifier
#> $animal_id$identifier[[1]]
#> [1] "SDN:MVB::MVB000016"
#> 
#> 
#> $animal_id$hasCurrentVersion
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/3/"
#> 
#> $animal_id$authoredOn
#> $animal_id$authoredOn[[1]]
#> [1] "2022-08-15 10:20:18.0"
#> 
#> 
#> attr(,"about")
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/"
#> 
movebank_get_vocabulary(
 "individual-local-identifier",
 omit_deprecated = TRUE,
 return_type = "list"
)
#> $`individual-local-identifier`
#> $`individual-local-identifier`$hasVersion
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/1/"
#> 
#> $`individual-local-identifier`$hasVersion
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/2/"
#> 
#> $`individual-local-identifier`$type
#> list()
#> attr(,"resource")
#> [1] "http://www.w3.org/2004/02/skos/core#Concept"
#> 
#> $`individual-local-identifier`$related
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/collection/P06/current/XXXX/"
#> 
#> $`individual-local-identifier`$definition
#> $`individual-local-identifier`$definition[[1]]
#> [1] "An individual identifier for the animal, provided by the data owner. Values are unique within the study. If the data owner does not provide an Animal ID, an internal Movebank animal identifier is sometimes shown. Example: 'TUSC_CV5'; Units: none; Entity described: individual"
#> 
#> attr(,"lang")
#> [1] "en"
#> 
#> $`individual-local-identifier`$inDataset
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/.well-known/void"
#> 
#> $`individual-local-identifier`$deprecated
#> $`individual-local-identifier`$deprecated[[1]]
#> [1] "false"
#> 
#> 
#> $`individual-local-identifier`$note
#> $`individual-local-identifier`$note[[1]]
#> [1] "accepted"
#> 
#> attr(,"lang")
#> [1] "en"
#> 
#> $`individual-local-identifier`$identifier
#> $`individual-local-identifier`$identifier[[1]]
#> [1] "SDN:MVB::MVB000016"
#> 
#> 
#> $`individual-local-identifier`$prefLabel
#> $`individual-local-identifier`$prefLabel[[1]]
#> [1] "animal ID"
#> 
#> attr(,"lang")
#> [1] "en"
#> 
#> $`individual-local-identifier`$versionInfo
#> $`individual-local-identifier`$versionInfo[[1]]
#> [1] "3"
#> 
#> 
#> $`individual-local-identifier`$date
#> $`individual-local-identifier`$date[[1]]
#> [1] "2022-08-15 10:20:18.0"
#> 
#> 
#> $`individual-local-identifier`$altLabel
#> $`individual-local-identifier`$altLabel[[1]]
#> [1] "individual local identifier"
#> 
#> 
#> $`individual-local-identifier`$notation
#> $`individual-local-identifier`$notation[[1]]
#> [1] "SDN:MVB::MVB000016"
#> 
#> 
#> $`individual-local-identifier`$version
#> $`individual-local-identifier`$version[[1]]
#> [1] "3"
#> 
#> 
#> $`individual-local-identifier`$identifier
#> $`individual-local-identifier`$identifier[[1]]
#> [1] "SDN:MVB::MVB000016"
#> 
#> 
#> $`individual-local-identifier`$hasCurrentVersion
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/3/"
#> 
#> $`individual-local-identifier`$authoredOn
#> $`individual-local-identifier`$authoredOn[[1]]
#> [1] "2022-08-15 10:20:18.0"
#> 
#> 
#> attr(,"about")
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000016/"
#> 
movebank_get_vocabulary("Deploy.On.Date", return_type = "list")
#> $Deploy.On.Date
#> $Deploy.On.Date$hasVersion
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000081/1/"
#> 
#> $Deploy.On.Date$hasVersion
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000081/2/"
#> 
#> $Deploy.On.Date$type
#> list()
#> attr(,"resource")
#> [1] "http://www.w3.org/2004/02/skos/core#Concept"
#> 
#> $Deploy.On.Date$related
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/collection/P06/current/TISO/"
#> 
#> $Deploy.On.Date$definition
#> $Deploy.On.Date$definition[[1]]
#> [1] "The timestamp when the tag deployment started. Data records recorded before this day and time are not associated with the animal related to the deployment. Values are typically defined by the data owner, and in some cases are created automatically during data import. Example: '2008-08-30 18:00:00.000'; Format: yyyy-MM-dd HH:mm:ss.SSS; Units: UTC or GPS time; Entity described: deployment"
#> 
#> attr(,"lang")
#> [1] "en"
#> 
#> $Deploy.On.Date$inDataset
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/.well-known/void"
#> 
#> $Deploy.On.Date$deprecated
#> $Deploy.On.Date$deprecated[[1]]
#> [1] "false"
#> 
#> 
#> $Deploy.On.Date$note
#> $Deploy.On.Date$note[[1]]
#> [1] "accepted"
#> 
#> attr(,"lang")
#> [1] "en"
#> 
#> $Deploy.On.Date$identifier
#> $Deploy.On.Date$identifier[[1]]
#> [1] "SDN:MVB::MVB000081"
#> 
#> 
#> $Deploy.On.Date$prefLabel
#> $Deploy.On.Date$prefLabel[[1]]
#> [1] "deploy on timestamp"
#> 
#> attr(,"lang")
#> [1] "en"
#> 
#> $Deploy.On.Date$versionInfo
#> $Deploy.On.Date$versionInfo[[1]]
#> [1] "3"
#> 
#> 
#> $Deploy.On.Date$date
#> $Deploy.On.Date$date[[1]]
#> [1] "2022-08-15 10:20:18.0"
#> 
#> 
#> $Deploy.On.Date$altLabel
#> $Deploy.On.Date$altLabel[[1]]
#> [1] "deploy on date"
#> 
#> 
#> $Deploy.On.Date$notation
#> $Deploy.On.Date$notation[[1]]
#> [1] "SDN:MVB::MVB000081"
#> 
#> 
#> $Deploy.On.Date$version
#> $Deploy.On.Date$version[[1]]
#> [1] "3"
#> 
#> 
#> $Deploy.On.Date$identifier
#> $Deploy.On.Date$identifier[[1]]
#> [1] "SDN:MVB::MVB000081"
#> 
#> 
#> $Deploy.On.Date$hasCurrentVersion
#> list()
#> attr(,"resource")
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000081/3/"
#> 
#> $Deploy.On.Date$authoredOn
#> $Deploy.On.Date$authoredOn[[1]]
#> [1] "2022-08-15 10:20:18.0"
#> 
#> 
#> attr(,"about")
#> [1] "http://vocab.nerc.ac.uk/collection/MVB/current/MVB000081/"
#> 
```
