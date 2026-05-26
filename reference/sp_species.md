# Retrieve Sharkipedia species metadata

Retrieve Sharkipedia species metadata

## Usage

``` r
sp_species(species, cache = TRUE)
```

## Arguments

- species:

  Scientific name, species slug, or species URL.

- cache:

  If `TRUE`, use the in-session memoised cache.

## Value

A one-row tibble with taxonomy and provenance columns.

## Examples

``` r
if (FALSE) { # \dontrun{
sp_species("Carcharhinus acronotus")
} # }
```
