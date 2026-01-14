# Changelog

## movepub (development version)

- [`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md)
  now requires `animal-taxon`, `animal-id` and `tag-id` in the source
  data. It also gracefully handles any non-required missing fields
  ([\#120](https://github.com/inbo/movepub/issues/120)).
- [`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md)
  now adds
  [georeferenceSources](http://rs.tdwg.org/dwc/terms/georeferenceSources)
  (set to `GPS` for GPS sensor data) and
  [identificationVerificationStatus](http://rs.tdwg.org/dwc/terms/identificationVerificationStatus)
  (set to `verified by expert` for all records, since the taxon is
  assumed to be well-known before the tag was attached).

## movepub 0.4.0

### write_eml

- [`write_eml()`](https://inbo.github.io/movepub/reference/write_eml.md)
  is now a separate function from
  [`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md)
  ([\#57](https://github.com/inbo/movepub/issues/57)).
- [`write_eml()`](https://inbo.github.io/movepub/reference/write_eml.md)
  now formats the `derived_paragraph` as DocBook (rather than HTML), a
  format supported by EML and the GBIF IPT
  ([\#102](https://github.com/inbo/movepub/issues/102)). The paragraph
  is also shorter and added at the end of the abstract
  ([\#76](https://github.com/inbo/movepub/issues/76)).
- New
  [`html_to_docbook()`](https://inbo.github.io/movepub/reference/html_to_docbook.md)
  allows to convert a string or character vector from HTML to DocBook.
  You can use this to convert descriptions in order to have valid EML
  ([\#101](https://github.com/inbo/movepub/issues/101)).
- [`write_eml()`](https://inbo.github.io/movepub/reference/write_eml.md)
  and
  [`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md)
  no longer add `[subsampled representation]` to the dataset title
  ([\#76](https://github.com/inbo/movepub/issues/76)).

### write_dwc

- [`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md)
  can now be used for an unpublished dataset (i.e. without metadata on
  DataCite, which was required for the previously build-in
  [`write_eml()`](https://inbo.github.io/movepub/reference/write_eml.md)
  functionality). Some record-level terms (e.g. `dwc:datasetName`) can
  be provided as arguments
  ([\#57](https://github.com/inbo/movepub/issues/57),
  [\#72](https://github.com/inbo/movepub/issues/72)).
- [`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md)
  (and
  [`write_eml()`](https://inbo.github.io/movepub/reference/write_eml.md))
  no longer writes to `"."` by default, since this is not allowed by
  CRAN policies. The user needs to explicitly define a directory
  ([\#70](https://github.com/inbo/movepub/issues/70)).
- [`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md)
  now writes the output file as `occurrence.csv` (previously
  `dwc_occurrence.csv`) and adds a `meta.xml` file. The sex and life
  stage of the animal are - in addition to `dwc:sex` and `dwc:lifeStage`
  in `occurrence.csv` - expressed in an extended measurement or facts
  file (`emof.csv`), for better support with OBIS
  ([\#71](https://github.com/inbo/movepub/issues/71),
  [\#77](https://github.com/inbo/movepub/issues/77),
  [\#78](https://github.com/inbo/movepub/issues/78)).
- [`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md)
  provides a message regarding the matching of scientific names with
  WoRMS Aphia IDs. These IDs are now clickable URLs, making it easier to
  verify the match ([\#58](https://github.com/inbo/movepub/issues/58)).
- [`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md)
  is now more modular, facilitating extension for non-GPS tracking data
  ([\#66](https://github.com/inbo/movepub/issues/66)).

### Other

- movepub now relies on R \>= 4.1.0 (because of move2 dependency) and
  uses base pipes (`|>` rather than `%>%`)
  ([\#98](https://github.com/inbo/movepub/issues/98)).
- Many functions of
  [frictionless](https://docs.ropensci.org/frictionless/) are now
  reexported by movepub, so you no longer have to load that package to
  create Data Packages
  ([\#54](https://github.com/inbo/movepub/issues/54)).
- [`get_mvb_term()`](https://inbo.github.io/movepub/reference/get_mvb_term.md)
  is deprecated in favour of
  [`move2::movebank_get_vocabulary()`](https://bartk.gitlab.io/move2/reference/movebank_get_vocabulary.html)
  ([\#60](https://github.com/inbo/movepub/issues/60)).
- [Sanne Govaert](https://orcid.org/0000-0002-8939-1305) is added as
  author.

## movepub 0.3.0

- [`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md)
  now makes use of dplyr rather than SQL for its transformation. This
  reduces the number of dependencies
  ([\#61](https://github.com/inbo/movepub/issues/61)).

## movepub 0.2.0

- As per [OBIS
  recommendations](https://manual.obis.org/darwin_core.html#taxonomy-and-identification),
  [`write_dwc()`](https://inbo.github.io/movepub/reference/write_dwc.md)
  now adds a `scientificNameID` to all occurrences, with the WoRMS LSID
  for that taxon. It does so using the new
  [`get_aphia_id()`](https://inbo.github.io/movepub/reference/get_aphia_id.md).
- The cli package is now used for all messages.
