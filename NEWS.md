# movepub (development version)

* `write_eml()` is now a separate function from `write_dwc()`. This allows you to use `write_dwc()` for an unpublished dataset (i.e. without metadata on DataCite) (#57).
* `write_eml()` and `write_dwc()` no longer  add `[subsampled representation]` to the dataset title. The extra abstract paragraph is now shorter and is added at the end of the abstract (#76).
* `write_dwc()` (and `write_eml()`) no longer writes to `"."` by default, since this is not allowed by CRAN policies. The user needs to explicitly define a directory (#70).
* `write_dwc()` now writes the output file as `occurrence.csv` and adds a `meta.xml` (cf. camtrapdp) and a `emof.csv` (extended measurements or facts) file (#71, #77, #78).
* `write_dwc()` is now more modular, facilitating extension for non-GPS tracking data (#66).
* `create_package()`, `read_package()` and `write_package()` reexport the create, read and write functionality of Data Packages from frictionless (#54).
* `resources()` lists the names of the Data Resources included in a Data Package. It is a reexport from frictionless.
* `read_resource()` and `remove_resource()` reexport the read and remove functionality of Data Resources from frictionless.

# movepub 0.3.0

* `write_dwc()` now makes use of dplyr rather than SQL for its transformation. This reduces the number of dependencies (#61).
* Add [Sanne Govaert](https://orcid.org/0000-0002-8939-1305) as author.

# movepub 0.2.0

* As per [OBIS recommendations](https://manual.obis.org/darwin_core.html#taxonomy-and-identification), `write_dwc()` now adds a `scientificNameID` to all occurrences, with the WoRMS LSID for that taxon. It does so using the new function `get_aphia_id()`.
* The cli package is now used for all messages.
