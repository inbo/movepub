# movepub 0.2.0

* As per [OBIS recommendations](https://manual.obis.org/darwin_core.html#taxonomy-and-identification), `write_dwc()` now adds a `scientificNameID` to all occurrences, with the WoRMS LSID for that taxon.
  It does so using the new function `get_aphia_id()`.
* The cli package is now used for all messages.
* Fix `fieldsEnclosedBy` issue in `meta.xml`, so GBIF occurrence processing correctly handles commas in fields.
