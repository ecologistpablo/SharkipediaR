# Retrieve Sharkipedia species URLs

Scrapes the public species index and returns a deduplicated tibble of
species names and URLs. Requests are rate-limited and cached by default.

## Usage

``` r
sp_species_urls(all_pages = FALSE, max_pages = NULL, cache = TRUE)
```

## Arguments

- all_pages:

  If `TRUE`, retrieve all paginated index pages. Defaults to the first
  page only to remain polite.

- max_pages:

  Optional cap on pages retrieved when `all_pages = TRUE`.

- cache:

  If `TRUE`, use the in-session memoised cache.

## Value

A tibble with columns `species`, `slug`, and `url`.

## Examples

``` r
if (FALSE) { # \dontrun{
sp_species_urls()
sp_species_urls(all_pages = TRUE, max_pages = 2)
} # }
```
