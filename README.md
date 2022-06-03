
<!-- README.md is generated from README.Rmd. Please edit that file -->

# movepub

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/movepub)](https://CRAN.R-project.org/package=movepub)
[![repo
status](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![funding](https://img.shields.io/static/v1?label=funded+by&message=NLBIF&labelColor=2e9228&color=87b950)](https://www.nlbif.nl/move2gbif-gps-zendergegevens-van-dieren-mobiliseren-naar-movebank-en-gbif/)
<!-- badges: end -->

Movepub is an R package to prepare [Movebank](https://movebank.org)
animal tracking data for publication in a research repository or the
[Global Biodiversity Information Facility (GBIF)](https://gbif.org).

To get started, see:

-   [Get started](https://inbo.github.io/movepub/articles/movepub.html):
    an introduction to the package’s main functionalities.
-   [Function
    reference](https://inbo.github.io/movepub/reference/index.html):
    overview of all functions.

## Installation

You can install the development version of movepub from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("inbo/movepub")
```

## Usage

This package supports two use cases:

-   [Make a Movebank dataset
    “frictionless”](https://inbo.github.io/movepub/articles/movepub.html#frictionless)
    with `add_resource()`. This is useful when publishing a dataset on
    e.g. [Zenodo](https://zenodo.org).
-   [Transform a Movebank dataset to Darwin
    Core](https://inbo.github.io/movepub/articles/movepub.html#dwc) with
    `write_dwc()`. This is necessary when publishing a dataset to
    [GBIF](https://www.gbif.org).
