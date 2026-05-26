# Retrieve Sharkipedia population trend data

Trend time series are embedded in server-rendered React props on species
pages and parsed into a long-format tibble.

## Usage

``` r
sp_trends(species, cache = TRUE)
```

## Arguments

- species:

  Scientific name, species slug, species URL, or a character vector of
  any of the above.

- cache:

  If `TRUE`, use the in-session memoised cache.

## Value

A long-form tibble with `year`, `value`, location metadata, and
provenance columns.

## Examples

``` r
if (FALSE) { # \dontrun{
sp_trends("Carcharhinus acronotus")
} # }
```
