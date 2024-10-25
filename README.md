
<!-- README.md is generated from README.Rmd. Please edit that file -->

# movepub

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/movepub)](https://CRAN.R-project.org/package=movepub)
[![R-CMD-check](https://github.com/inbo/movepub/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/inbo/movepub/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/inbo/movepub/branch/main/graph/badge.svg)](https://app.codecov.io/gh/inbo/movepub/)
[![repo
status](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

Movepub is an R package to prepare animal tracking data from
[Movebank](https://movebank.org) for publication in a research
repository. With movepub you can document data with metadata following
the [Data Package](https://specs.frictionlessdata.io/) standard and
transform these to [Darwin Core](https://dwc.tdwg.org) and Ecological
Metadata Language ([EML](https://eml.ecoinformatics.org/) for
publication to the Global Biodiversity Information Facility
([GBIF](https://www.gbif.org)) and the Ocean Biodiversity Information
System ([OBIS](https://obis.org)).

To get started, see:

- [Prepare your
  study](https://www.movebank.org/cms/movebank-content/archiving-movebank#general_best_practice_tips):
  guidelines on how data owners should prepare their study in Movebank
  for archiving, prior to using this package.
- [Get started](https://inbo.github.io/movepub/articles/movepub.html):
  an introduction to the package’s main functionalities.
- [Function
  reference](https://inbo.github.io/movepub/reference/index.html):
  overview of all functions.

Note that Movebank users retain ownership of their data, and use should
follow the [general Movebank terms of
use](https://www.movebank.org/cms/movebank-content/general-movebank-terms-of-use)
and any other license terms set by the owner.

## Installation

You can install the development version of movepub from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("inbo/movepub")
```

## Usage

This package supports two use cases:

- [Make a Movebank dataset
  “frictionless”](https://inbo.github.io/movepub/articles/movepub.html#frictionless)
  with `add_resource()`. This is useful when publishing a dataset on
  e.g. [Zenodo](https://zenodo.org).
- [Transform a Movebank dataset to Darwin
  Core](https://inbo.github.io/movepub/articles/movepub.html#dwc) with
  `write_dwc()`. This is necessary when publishing a dataset to
  [GBIF](https://www.gbif.org).

## Meta

- We welcome [contributions](.github/CONTRIBUTING.md) including bug
  reports.
- License: MIT
- Get citation information for movepub in R doing `citation("movepub")`.
- Please note that this project is released with a [Contributor Code of
  Conduct](.github/CODE_OF_CONDUCT.md). By participating in this project
  you agree to abide by its terms.
