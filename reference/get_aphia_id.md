# Get WoRMS AphiaID from a taxonomic name

This function wraps
[`worrms::wm_name2id_()`](https://docs.ropensci.org/worrms/reference/wm_name2id.html)
so that it returns a data frame rather than a list. It also silences
"not found" warnings, returning `NA` instead.

## Usage

``` r
get_aphia_id(x)
```

## Arguments

- x:

  A (vector with) taxonomic name(s).

## Value

Data frame with `name`, `aphia_id`, `aphia_lsid` and `aphia_url`.

## See also

Other support functions:
[`datacite_to_eml()`](https://inbo.github.io/movepub/reference/datacite_to_eml.md),
[`html_to_docbook()`](https://inbo.github.io/movepub/reference/html_to_docbook.md)

## Examples

``` r
get_aphia_id("Mola mola")
#> # A tibble: 1 × 5
#>   name      aphia_id aphia_lsid                          aphia_url aphia_url_cli
#>   <chr>        <int> <chr>                               <chr>     <chr>        
#> 1 Mola mola   127405 urn:lsid:marinespecies.org:taxname… https://… {.href [1274…
get_aphia_id(c("Mola mola", "not_a_name"))
#> # A tibble: 2 × 5
#>   name       aphia_id aphia_lsid                         aphia_url aphia_url_cli
#>   <chr>         <int> <chr>                              <chr>     <chr>        
#> 1 Mola mola    127405 urn:lsid:marinespecies.org:taxnam… https://… {.href [1274…
#> 2 not_a_name       NA NA                                 NA        NA           
```
