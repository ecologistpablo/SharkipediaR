# Search Sharkipedia species names

Matches partial scientific names against the species index. By default
this uses a cached index request; set `index` to a pre-built index from
[`sp_species_urls()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_species_urls.md)
to avoid repeated downloads.

## Usage

``` r
sp_search(query, index = NULL, all_pages = FALSE, cache = TRUE)
```

## Arguments

- query:

  Character vector of search terms (case-insensitive).

- index:

  Optional species index tibble from
  [`sp_species_urls()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_species_urls.md).
  For comprehensive matching, build the index once with
  `sp_species_urls(all_pages = TRUE)` and pass it here.

- all_pages:

  If `index` is `NULL`, whether to scan all index pages.

- cache:

  Passed to
  [`sp_species_urls()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_species_urls.md)
  when `index` is `NULL`.

## Value

A tibble of matching species with `species`, `slug`, and `url`.

## Examples

``` r
if (FALSE) { # \dontrun{
sp_search("Carcharhinus")
} # }
```
