# Retrieve reference links for a Sharkipedia species

Retrieve reference links for a Sharkipedia species

## Usage

``` r
sp_references(species, cache = TRUE)
```

## Arguments

- species:

  Scientific name, species slug, or species URL.

- cache:

  If `TRUE`, use the in-session memoised cache.

## Value

A tibble with `reference_id`, `reference_url`, `species`, `source_url`,
and `retrieved_at`.

## Examples

``` r
if (FALSE) { # \dontrun{
sp_references("Carcharhinus acronotus")
} # }
```
