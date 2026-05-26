# sharkipediaR

<!-- badges: start -->
[![pkgdown site](https://img.shields.io/badge/pkgdown-site-blue)](https://ecologistpablo.github.io/SharkpediaR/)
<!-- badges: end -->

**sharkipediaR** is a tidyverse-oriented R client for [Sharkipedia](https://www.sharkipedia.org) — the open database of shark and ray life-history traits and population abundance trends ([Dulvy et al., 2022](https://www.nature.com/articles/s41597-022-01655-1)). The package downloads public species pages politely, parses embedded HTML tables and trend series, and returns reproducible tibbles ready for `dplyr` and **ggplot2** / **plotly**.

- **Site (vignettes & reference):** <https://ecologistpablo.github.io/SharkpediaR/>
- **Source:** <https://github.com/ecologistpablo/SharkpediaR>

---

## Installation

```r
# install.packages("devtools")
devtools::install_github("ecologistpablo/SharkpediaR")
```

**Suggested packages** for examples and vignettes: `dplyr`, `ggplot2`, `plotly`.

---

## Quick start

```r
library(sharkipediaR)
library(dplyr)

# One species (requires internet)
meta   <- sp_species("Carcharhinus acronotus")
traits <- sp_traits("Carcharhinus acronotus")
trends <- sp_trends("Carcharhinus acronotus")

# Offline example data (no network)
ex <- example_carcharhinus()
```

Every table includes **`source_url`** and **`retrieved_at`** for reproducible methods sections.

```r
traits %>%
  filter(trait_name == "Amat50") %>%
  summarise(mean_age = mean(as.numeric(value), na.rm = TRUE), .by = sex)
```

---

## Documentation

| Resource | Description |
|----------|-------------|
| [Getting started](https://ecologistpablo.github.io/SharkpediaR/articles/sharkipediar.html) | Install, overview, workflow |
| [Ecological workflows](https://ecologistpablo.github.io/SharkpediaR/articles/ecological-workflows.html) | Fisheries / conservation examples, interactive plots |
| [Architecture & functions](https://ecologistpablo.github.io/SharkpediaR/articles/architecture-and-functions.html) | Full pipeline and internal parsers |
| [Function reference](https://ecologistpablo.github.io/SharkpediaR/reference/index.html) | All exported functions |

In R: `utils::browseVignettes("sharkipediaR")`

**Note:** Vignettes appear under **Articles** in the pkgdown navbar (not on the GitHub README). The site is built with [pkgdown](https://pkgdown.r-lib.org/); see [Publishing](#publishing-the-website) below.

---

## Design

The package separates **retrieval → parsing → cleaning → validation**. It is a lightweight scientific client, not a bulk crawler. Requests are rate-limited and cached within a session (`memoise`).

---

## Function reference

### Discovery

#### `sp_species_urls(all_pages = FALSE, max_pages = NULL, cache = TRUE)`

Scrapes the public [species index](https://www.sharkipedia.org/species) and returns a deduplicated tibble.

| Argument | Description |
|----------|-------------|
| `all_pages` | If `TRUE`, walk all paginated index pages (~65). Default `FALSE` (first page only, polite). |
| `max_pages` | Cap pages when `all_pages = TRUE` (e.g. `max_pages = 3` while testing). |
| `cache` | Use in-session memoised HTTP cache. |

**Returns:** `species` (scientific name), `slug` (URL slug), `url` (full Sharkipedia URL).

```r
idx <- sp_species_urls()
idx <- sp_species_urls(all_pages = TRUE, max_pages = 5)
```

---

#### `sp_search(query, index = NULL, all_pages = FALSE, cache = TRUE)`

Case-insensitive substring search on scientific names and slugs.

| Argument | Description |
|----------|-------------|
| `query` | Character vector of search terms (e.g. `"Carcharhinus"`). |
| `index` | Optional tibble from `sp_species_urls()`. Pass a full index to avoid re-downloading. |
| `all_pages` | Used only if `index` is `NULL` — whether to build a full index first. |

**Returns:** Matching rows from the index (`species`, `slug`, `url`).

```r
sp_search("Carcharhinus")
idx <- sp_species_urls(all_pages = TRUE, max_pages = 10)
sp_search("rhincodon", index = idx)
```

---

### Species-level data

#### `sp_species(species, cache = TRUE)`

Taxonomy and provenance for one species.

| Argument | Description |
|----------|-------------|
| `species` | Scientific name (`"Carcharhinus acronotus"`), slug, or full species URL. |

**Returns:** One-row tibble: `species`, `superorder`, `subclass`, `order`, `family`, `source_url`, `retrieved_at`.

```r
sp_species("Carcharhinus acronotus")
```

---

#### `sp_traits(species, cache = TRUE)`

Life-history **trait** measurements in long format.

| Argument | Description |
|----------|-------------|
| `species` | One name/URL or a **character vector** for batch download (adds `species_input` column). |

**Returns:** Tibble with:

| Column | Description |
|--------|-------------|
| `trait_group` | Age, Length, Reproduction, Ecological Role, … |
| `trait_name` | e.g. `Amat50`, `Linf`, `Lmax-observed` |
| `value` | Reported value (character; use `as.numeric()` when needed) |
| `standard` | Units or category (e.g. `Year`, `cm`) |
| `value_type` | Often `mean`, `median`, … |
| `sex` | `Male`, `Female`, `Pooled`, … |
| `location` | Study or geographic location |
| `reference` | Sharkipedia reference ID |
| `source_url`, `retrieved_at` | Provenance |

```r
traits <- sp_traits("Carcharhinus acronotus")
traits <- sp_traits(c("Carcharhinus acronotus", "Alopias vulpinus"))
```

---

#### `sp_trends(species, cache = TRUE)`

Population **abundance trends** parsed from embedded chart data on species pages (long format: one row per year).

| Argument | Description |
|----------|-------------|
| `species` | One name/URL or character vector (batch). |

**Returns:** Tibble with:

| Column | Description |
|--------|-------------|
| `location` | Trend region / stock description |
| `unit` | e.g. `individual`, `kg` |
| `reference` | Source reference ID |
| `trend_id`, `trend_url` | Sharkipedia trend record |
| `year`, `value` | Time series observations |
| `species`, `source_url`, `retrieved_at` | Provenance |

```r
trends <- sp_trends("Carcharhinus acronotus")
trends %>%
  filter(trend_id == "3537") %>%
  ggplot(aes(year, value)) +
  geom_line()
```

---

#### `sp_references(species, cache = TRUE)`

Bibliographic **reference links** cited on the species page (from trait and trend tables).

**Returns:** `reference_id`, `reference_url`, `species`, `source_url`, `retrieved_at`.

```r
refs <- sp_references("Carcharhinus acronotus")
```

---

### Helpers

#### `example_carcharhinus()`

Returns a list of pre-parsed tibbles for *Carcharhinus acronotus* (`species_meta`, `traits`, `trends`, `references`, `species_index`) for examples, tests, and vignettes **without HTTP**.

```r
ex <- example_carcharhinus()
ex$traits
```

---

#### `fetch_page(url, quiet = TRUE)` *(advanced)*

Low-level HTTP + HTML retrieval. Returns an `xml2` document. Prefer `sp_*()` functions unless extending the package.

```r
doc <- fetch_page("https://www.sharkipedia.org/species/carcharhinus-acronotus")
```

---

## Typical workflows

**1. Find species → pull traits**

```r
hits <- sp_search("Galeocerdo")
traits <- sp_traits(hits$species[[1]])
```

**2. Red List / assessment prep (provenance)**

```r
trends <- sp_trends("Carcharhinus acronotus")
attr(trends, "source") # use source_url column in exports
write.csv(trends, "blacknose_trends.csv", row.names = FALSE)
```

**3. Comparative analysis (batch)**

```r
species_list <- c("Carcharhinus acronotus", "Carcharhinus limbatus")
all_traits <- sp_traits(species_list)
```

Use **`%>%`** pipes throughout; see vignettes for **plotly** interactive charts.

---

## Polite use

- Default index scrape: **one page** only.
- ~0.5 s minimum gap between requests (randomised jitter).
- In-session caching via `cache = TRUE` (default).
- Do not parallelise large scrapes without care; see `DEVELOPMENT.md` for design notes.

---

## Publishing the website

Vignettes are **not** shown on the GitHub repo README; they live on the pkgdown site under **Articles**.

```r
install.packages(c("pkgdown", "ggplot2", "plotly", "knitr", "rmarkdown"))
source("data-raw/build-vignette-data.R")
pkgdown::build_site()
pkgdown::deploy_to_branch(branch = "gh-pages")  # no git_user / repo_slug
```

Or: `Rscript scripts/deploy-pkgdown.R`

**If the site still looks old:** your first deploy may have pushed an **empty** `gh-pages` (see terminal error). Re-run deploy above; then hard-refresh (Cmd+Shift+R). Check `git ls-remote --heads origin gh-pages` — latest commit should be recent, not `Initializing gh-pages branch`.

**GitHub Pages:** Settings → Pages → branch **`gh-pages`**, folder **`/ (root)`**.

Vignettes: navbar **Articles**, not the home README.

---

## Citation

If you use Sharkipedia data, cite the database ([Dulvy et al., 2022](https://www.nature.com/articles/s41597-022-01655-1)) and record `source_url` / `retrieved_at` from this package.

```r
citation("sharkipediaR") # after install
```

---

## License

MIT © Pablo Fuenzalida. See [LICENSE](LICENSE).

---

## Development

Contributor / AI blueprint: [DEVELOPMENT.md](DEVELOPMENT.md).
