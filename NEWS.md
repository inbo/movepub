# movepub (development version)

* movepub now relies on R >= 4.1.0 (because of move2 dependency) and uses base pipes (`|>` rather than `%>%`) (#98
).
* `write_eml()` is now a separate function from `write_dwc()`. This allows you to use `write_dwc()` for an unpublished dataset (i.e. without metadata on DataCite). Some record-level terms (e.g. `dwc:datasetName`) can be provided as arguments (#57, #72).
* `write_eml()` and `write_dwc()` no longer add `[subsampled representation]` to the dataset title. The extra abstract paragraph is now shorter and is added at the end of the abstract (#76).
* `write_dwc()` (and `write_eml()`) no longer writes to `"."` by default, since this is not allowed by CRAN policies. The user needs to explicitly define a directory (#70).
* `write_dwc()` now writes the output file as `occurrence.csv` (previously `dwc_occurrence.csv`) and adds a `meta.xml` file. The sex and life stage of the animal are - in addition to `dwc:sex` and `dwc:lifeStage` in `occurrence.csv` - expressed in an extended measurement or facts file (`emof.csv`), for better support with OBIS (#71, #77, #78).
* `write_dwc()` provides a message regarding the matching of scientific names with WoRMS Aphia IDs. These IDs are now clickable URLs, making it easier to verify the match (#58).
* Many functions of [frictionless](https://docs.ropensci.org/frictionless/) are now reexported by movepub, so you no longer have to load that package to create Data Packages (#54).
* `write_dwc()` is now more modular, facilitating extension for non-GPS tracking data (#66).
* `get_mvb_term()` is deprecated in favour of `move2::movebank_get_vocabulary()`.

# movepub 0.3.0

* `write_dwc()` now makes use of dplyr rather than SQL for its transformation. This reduces the number of dependencies (#61).
* Add [Sanne Govaert](https://orcid.org/0000-0002-8939-1305) as author.

# movepub 0.2.0

* As per [OBIS recommendations](https://manual.obis.org/darwin_core.html#taxonomy-and-identification), `write_dwc()` now adds a `scientificNameID` to all occurrences, with the WoRMS LSID for that taxon. It does so using the new function `get_aphia_id()`.
* The cli package is now used for all messages.
