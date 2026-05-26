# Package architecture and function reference

``` r

library(sharkipediaR)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

vignette_fixture <- function(name) {
  path <- system.file("fixtures", name, package = "sharkipediaR")
  if (!nzchar(path)) {
    cli::cli_abort("Fixture not found: {name}")
  }
  path
}

doc <- xml2::read_html(vignette_fixture("carcharhinus_acronotus.html"))
index_doc <- xml2::read_html(vignette_fixture("species_index_page1.html"))
source_url <- "https://www.sharkipedia.org/species/carcharhinus-acronotus"
retrieved_at <- as.POSIXct("2026-05-25 12:00:00", tz = "UTC")
```

### Design philosophy

**sharkipediaR** follows a strict pipeline:

    HTTP retrieval  →  HTML parsing  →  cleaning  →  validation  →  user-facing tibble
    (fetch.R)         (parse.R)        (clean.R)     (validate.R)   (sp_*.R)

No step is allowed to “do everything.” That separation keeps the package
maintainable when Sharkipedia’s HTML evolves.

![Data flow for
sp_traits()](architecture-and-functions_files/figure-html/diagram-1.png)

Data flow for sp_traits()

------------------------------------------------------------------------

## `R/constants.R`

| Object / function | Role |
|----|----|
| `.sharkipedia_env` | Package-private environment storing last request time for rate limiting |
| `sharkipedia_base_url()` | Returns `https://www.sharkipedia.org` |
| `sharkipedia_user_agent()` | Identifies the client in HTTP headers (version + project URL) |

These are internal but underpin polite scraping.

------------------------------------------------------------------------

## `R/utils.R`

### `rate_limit_pause(min_gap = 0.5)`

Waits until at least `min_gap` seconds have elapsed since the last
request, plus a small random jitter (`runif(0, 0.3)`). Called
automatically by
[`fetch_page()`](https://ecologistpablo.github.io/SharkpediaR/reference/fetch_page.md).

### `species_name_to_slug(name)`

Converts `"Carcharhinus acronotus"` → `"carcharhinus-acronotus"`
(lowercase, spaces to hyphens).

### `species_name_to_url(name)`

Builds the full species page URL from a scientific name.

``` r

sharkipediaR:::species_name_to_url("Carcharhinus acronotus")
#> [1] "https://www.sharkipedia.org/species/carcharhinus-acronotus"
```

### `normalize_sharkipedia_url(url)`

Accepts:

- full URLs,
- relative paths (`/species/...`),
- bare scientific names.

### `resolve_species_url(x)`

Length-1 resolver used by all `sp_*()` functions. Errors if
`length(x) != 1`.

### `ensure_species_vector(x)`

Trims, de-duplicates, and validates a character vector for batch
functions.

### `read_html_fixture(path)`

Reads local HTML for tests (internal).

### `get_fetch_page(cache = TRUE)`

Returns either `fetch_page` or memoised `fetch_page_memoised` depending
on the `cache` argument passed to user functions.

------------------------------------------------------------------------

## `R/fetch.R`

### `fetch_page(url, quiet = TRUE)` — **exported**

**Responsibilities only:** HTTP, rate limit, retries, return
`xml_document`.

| Step | Implementation |
|----|----|
| URL normalisation | `normalize_sharkipedia_url()` |
| Politeness | `rate_limit_pause()` |
| Request | [`httr2::request()`](https://httr2.r-lib.org/reference/request.html) + user agent + `req_retry(max_tries = 3)` |
| Error handling | Abort on status ≥ 400 with `cli` message |
| Body | [`httr2::resp_body_html()`](https://httr2.r-lib.org/reference/resp_body_raw.html) → **xml2** document |

``` r

doc_live <- fetch_page("Carcharhinus acronotus", quiet = FALSE)
class(doc_live)
```

### `fetch_page_memoised`

`memoise::memoise(fetch_page)` — identical URLs in one R session return
the cached document without a new HTTP call.

------------------------------------------------------------------------

## `R/parse.R`

Parsing functions **never** perform HTTP. They only read `xml_document`
objects.

### `parse_species_index(doc)`

**Used by:**
[`sp_species_urls()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_species_urls.md)

- Selector: `a[href^='/species/']`
- Excludes CSV export links (`*.csv` slugs)
- Returns `species`, `slug`, `url`

``` r

idx <- sharkipediaR:::parse_species_index(index_doc)
head(idx, 4)
#> # A tibble: 4 × 3
#>   species             slug                              url                     
#>   <chr>               <chr>                             <chr>                   
#> 1 Rajella leopardus   rajella-leopardus                 https://www.sharkipedia…
#> 2 Gymnura lessae      gymnura-lessae                    https://www.sharkipedia…
#> 3 Styracura schmardae html-i-styracura-schmardae-i-html https://www.sharkipedia…
#> 4 Dipturus lamillai   dipturus-lamillai                 https://www.sharkipedia…
```

### `parse_index_last_page(doc)`

Reads Bulma pagination links (`.pagination-link`) and returns the
maximum page number — used when `sp_species_urls(all_pages = TRUE)`.

### `parse_taxonomy(doc)`

**Used by:**
[`sp_species()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_species.md)

- Species name: `h1.title`
- Ranks: `div.columns > div.column:first-child > p` with labels
  `Superorder:`, `Subclass:`, `Order:`, `Family:`

``` r

sharkipediaR:::parse_taxonomy(doc)
#> # A tibble: 1 × 5
#>   species                superorder   subclass       order             family   
#>   <chr>                  <chr>        <chr>          <chr>             <chr>    
#> 1 Carcharhinus acronotus Galeomorphii Elasmobranchii Carcharhiniformes Carcharh…
```

### Trait table helpers

| Function | Role |
|----|----|
| `trait_table_headers()` | Reads `<thead><th>` text |
| `is_trait_table()` | `TRUE` if headers include `"Name"` |
| `preceding_trait_group()` | XPath `preceding::h4[contains(@class,'subtitle')][1]` for trait class |

### `parse_traits_tables(doc)`

**Used by:**
[`sp_traits()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_traits.md)
via `fetch_species_traits()`

1.  Find all `table.table` elements.
2.  Keep tables whose headers match Sharkipedia’s trait schema.
3.  [`rvest::html_table()`](https://rvest.tidyverse.org/reference/html_table.html)
    for body rows.
4.  Attach `trait_group` from the nearest preceding `h4`.

``` r

raw_traits <- sharkipediaR:::parse_traits_tables(doc)
names(raw_traits)
#> [1] "Name"        "Value"       "Standard"    "ValueType"   "Sex"        
#> [6] "Location"    "Reference"   "trait_group"
head(raw_traits, 3)
#> # A tibble: 3 × 8
#>   Name             Value Standard ValueType Sex   Location Reference trait_group
#>   <chr>            <chr> <chr>    <chr>     <chr> <chr>    <chr>     <chr>      
#> 1 Direct Predation Medi… Effect … mean      Pool… Caribbe… clementi… Ecological…
#> 2 Direct Predation Medi… Strengt… mean      Pool… Caribbe… clementi… Ecological…
#> 3 Amat50           4.3   Year     mean      Male  South C… driggers… Age
```

Note: column names are still **PascalCase** (`Name`, `Value`, …) at this
stage.

### `decode_react_props(props)`

Decodes HTML entities in `data-react-props` JSON and parses with
**jsonlite**. Internal helper for trends.

### `parse_trends_tables(doc)`

**Used by:**
[`sp_trends()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_trends.md)

1.  Locate the first table after the `h3` heading containing `"Trends"`.
2.  For each `<tr>`:
    - `location`, `unit`, `reference` from table cells
    - `trend_id` / `trend_url` from the “Details” link
    - `observations` matrix from `div[data-react-props]`
3.  Expand to one row per **year × value**.

``` r

raw_trends <- sharkipediaR:::parse_trends_tables(doc)
raw_trends %>%
  count(location, trend_id) %>%
  head(5)
#> # A tibble: 5 × 3
#>   location                                      trend_id     n
#>   <chr>                                         <chr>    <int>
#> 1 Brownsville, TX to the Florida Keys, FL (USA) 3540        23
#> 2 North Carolina to Brownsville (USA)           3537        26
#> 3 North Gulf of Mexico                          3543        60
#> 4 North Gulf of Mexico                          3544        60
#> 5 North Gulf of Mexico (USA)                    3538        22
```

### `parse_references(doc)`

Collects unique `a[href^='/references/']` from trait and trend tables.

``` r

sharkipediaR:::parse_references(doc) %>% head(5)
#> # A tibble: 5 × 2
#>   reference_id      reference_url                                           
#>   <chr>             <chr>                                                   
#> 1 clementi2021      https://www.sharkipedia.org/references/clementi2021     
#> 2 driggers2004a     https://www.sharkipedia.org/references/driggers2004a    
#> 3 trinidadcruz1997  https://www.sharkipedia.org/references/trinidadcruz1997 
#> 4 uribemartinez1993 https://www.sharkipedia.org/references/uribemartinez1993
#> 5 peterson2017      https://www.sharkipedia.org/references/peterson2017
```

### `link_text_or_href(node)`

Utility for anchor text vs. `href` basename (internal).

------------------------------------------------------------------------

## `R/clean.R`

Cleaning standardises names, types, and provenance.

### `standardize_trait_columns(df)`

Maps Sharkipedia headers to snake_case:

| HTML      | R column   |
|-----------|------------|
| Name      | trait_name |
| Value     | value      |
| Standard  | standard   |
| ValueType | value_type |
| Sex       | sex        |
| Location  | location   |
| Reference | reference  |

### `clean_traits(df, species, source_url, retrieved_at)`

- Renames columns via `standardize_trait_columns()`
- Adds `species`, `source_url`, `retrieved_at` (UTC POSIXct)
- `str_squish()` + `na_if("", .)` on character fields
- Strips `/references/` prefixes from `reference`

``` r

traits_clean <- sharkipediaR:::clean_traits(
  raw_traits,
  species = "Carcharhinus acronotus",
  source_url = source_url,
  retrieved_at = retrieved_at
)
names(traits_clean)
#>  [1] "trait_name"   "value"        "standard"     "value_type"   "sex"         
#>  [6] "location"     "reference"    "trait_group"  "species"      "source_url"  
#> [11] "retrieved_at"
```

### `clean_trends(df, species, source_url, retrieved_at)`

- Coerces `year` to integer, keeps `value` as double
- Adds species and provenance columns
- Squashes whitespace on metadata fields

``` r

trends_clean <- sharkipediaR:::clean_trends(
  raw_trends,
  species = "Carcharhinus acronotus",
  source_url = source_url,
  retrieved_at = retrieved_at
)
summary(trends_clean$year)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>    1950    1970    1989    1986    2001    2018
```

------------------------------------------------------------------------

## `R/validate.R`

Validation is the last gate before data reach the user.

### `validate_traits(df)`

- **Required columns:** `species`, `trait_name`, `value`, `source_url`,
  `retrieved_at`
- **Warns** (does not error) on zero rows — page structure may have
  changed

### `validate_trends(df)`

- **Required columns:** `species`, `year`, `value`, `source_url`,
  `retrieved_at`
- Same empty-data warning pattern

``` r

sharkipediaR:::validate_traits(traits_clean) %>% nrow()
#> [1] 39
sharkipediaR:::validate_trends(trends_clean) %>% nrow()
#> [1] 321
```

------------------------------------------------------------------------

## `R/sp_species_urls.R`

### `sp_species_urls(all_pages = FALSE, max_pages = NULL, cache = TRUE)`

| Argument            | Behaviour                                      |
|---------------------|------------------------------------------------|
| `all_pages = FALSE` | Only page 1 of `?all=true` index (~20 species) |
| `all_pages = TRUE`  | Reads pagination from page 1, loops all pages  |
| `max_pages`         | Caps pagination when exploring                 |
| `cache`             | Uses memoised `fetch_page`                     |

Returns deduplicated tibble: `species`, `slug`, `url`.

``` r

sp_species_urls()
sp_species_urls(all_pages = TRUE, max_pages = 3)
```

------------------------------------------------------------------------

## `R/sp_search.R`

### `sp_search(query, index = NULL, all_pages = FALSE, cache = TRUE)`

1.  Normalises `query` via `ensure_species_vector()`.
2.  Builds or accepts `index` tibble.
3.  `grepl(..., fixed = TRUE)` on lowercased `species` and `slug`.
4.  `distinct(url)`.

Best practice: `idx <- sp_species_urls(all_pages = TRUE)` once, then
`sp_search("rhincodon", index = idx)`.

------------------------------------------------------------------------

## `R/sp_species.R`

### `sp_species(species, cache = TRUE)`

End-user taxonomy extractor. Returns **one row**:

`species`, `superorder`, `subclass`, `order`, `family`, `source_url`,
`retrieved_at`

``` r

ex <- example_carcharhinus()
ex$species_meta
#> # A tibble: 1 × 7
#>   species        superorder subclass order family source_url retrieved_at       
#>   <chr>          <chr>      <chr>    <chr> <chr>  <chr>      <dttm>             
#> 1 Carcharhinus … Galeomorp… Elasmob… Carc… Carch… https://w… 2026-05-25 12:00:00
```

------------------------------------------------------------------------

## `R/sp_traits.R`

### `sp_traits(species, cache = TRUE)`

Public API for traits.

- **One species:** calls `fetch_species_traits()`.
- **Many species:**
  [`purrr::map_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html)
  with column `species_input`.

### `fetch_species_traits(species, cache = TRUE)` — internal

Orchestrates the full trait pipeline documented above.

``` r

# Equivalent to fetch_species_traits() without HTTP:
traits_clean <- sharkipediaR:::validate_traits(traits_clean)
nrow(traits_clean)
#> [1] 39
```

------------------------------------------------------------------------

## `R/sp_trends.R`

### `sp_trends(species, cache = TRUE)`

Public API for population trends (long format).

### `fetch_species_trends(species, cache = TRUE)` — internal

Same pattern as traits: fetch → parse → clean → validate.

``` r

nrow(trends_clean)
#> [1] 321
```

------------------------------------------------------------------------

## `R/sp_references.R`

### `sp_references(species, cache = TRUE)`

Fetches species page, runs
[`parse_references()`](https://ecologistpablo.github.io/SharkpediaR/reference/parse_references.md),
adds `species`, `source_url`, `retrieved_at`.

Use to build a reference lookup table before joining to traits/trends.

------------------------------------------------------------------------

## `R/example_data.R`

### `example_carcharhinus()` — **exported**

Loads `inst/extdata/carcharhinus_acronotus.rds` — a list with pre-parsed
components used in all vignettes.

Rebuild after fixture updates:

``` r

source("data-raw/build-vignette-data.R")
```

------------------------------------------------------------------------

## End-to-end manual pipeline (advanced users)

Reproduce
[`sp_traits()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_traits.md)
without calling it:

``` r

url <- sharkipediaR:::species_name_to_url("Carcharhinus acronotus")
# doc <- fetch_page(url)   # live
# raw <- parse_traits_tables(doc)
# out <- validate_traits(clean_traits(raw, "Carcharhinus acronotus", url))
# Identical structure to example_carcharhinus()$traits
```

This is the extension point if Sharkipedia adds a JSON API later: swap
[`fetch_page()`](https://ecologistpablo.github.io/SharkpediaR/reference/fetch_page.md) +
`parse_*()` implementations while keeping
[`sp_traits()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_traits.md)
stable.

------------------------------------------------------------------------

## Testing and pkgdown

- **Unit tests** use HTML fixtures in `tests/testthat/fixtures/` (no
  network).
- **Vignettes** use
  [`example_carcharhinus()`](https://ecologistpablo.github.io/SharkpediaR/reference/example_carcharhinus.md)
  for plots and tables.
- **pkgdown** picks up vignettes automatically after
  [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html).

See **Getting started** and **Ecological workflows** for ggplot
demonstrations and scientific motivation.
