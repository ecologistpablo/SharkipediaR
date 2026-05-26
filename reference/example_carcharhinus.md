# Example Sharkipedia data for *Carcharhinus acronotus*

Returns cached trait, trend, taxonomy, and reference tables parsed from
a real Sharkipedia species page. Used in vignettes and examples so
documentation can be built without live HTTP requests.

## Usage

``` r
example_carcharhinus()
```

## Value

A list with elements `species_meta`, `traits`, `trends`, `references`,
and `species_index` (all tibbles).

## Examples

``` r
ex <- example_carcharhinus()
nrow(ex$traits)
#> [1] 39
nrow(ex$trends)
#> [1] 321
```
