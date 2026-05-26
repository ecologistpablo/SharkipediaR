# Retrieve Sharkipedia trait data

Retrieve Sharkipedia trait data

## Usage

``` r
sp_traits(species, cache = TRUE)
```

## Arguments

- species:

  Scientific name, species slug, species URL, or a character vector of
  any of the above.

- cache:

  If `TRUE`, use the in-session memoised cache.

## Value

A long-form tibble of trait observations with provenance columns.

## Examples

``` r
if (FALSE) { # \dontrun{
library(dplyr)
traits <- sp_traits("Aetobatus narinari")
traits %>%
  filter(trait_name == "Linf") %>%
  summarise(mean_linf = mean(as.numeric(value), na.rm = TRUE))
} # }
```
