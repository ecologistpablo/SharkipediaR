[![ecologistpablo - SharkpediaR](https://img.shields.io/static/v1?label=ecologistpablo&message=SharkpediaR&color=blue&logo=github)](https://github.com/ecologistpablo/SharkpediaR)
[![pkgdown site](https://img.shields.io/badge/pkgdown-site-blue)](https://ecologistpablo.github.io/SharkpediaR/)
[![issues - SharkpediaR](https://img.shields.io/github/issues/ecologistpablo/SharkpediaR)](https://github.com/ecologistpablo/SharkpediaR/issues)
[![stars - SharkpediaR](https://img.shields.io/github/stars/ecologistpablo/SharkpediaR?style=social)](https://github.com/ecologistpablo/SharkpediaR)
[![forks - SharkpediaR](https://img.shields.io/github/forks/ecologistpablo/SharkpediaR?style=social)](https://github.com/ecologistpablo/SharkpediaR)
[![watchers - SharkpediaR](https://img.shields.io/github/watchers/ecologistpablo/SharkpediaR?style=social)](https://github.com/ecologistpablo/SharkpediaR)

main branch:
[![pkgdown](https://github.com/ecologistpablo/SharkpediaR/actions/workflows/pkgdown.yaml/badge.svg?branch=main)](https://github.com/ecologistpablo/SharkpediaR/actions/workflows/pkgdown.yaml)

<!-- badges: end -->

<!-- Add hero images / example plots here when ready -->

<h1 align="center">sharkipediaR</h1>
<h4 align="center">An R package to access Sharkipedia life-history traits and population trends</h4>

<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#installation">Installation</a> •
  <a href="#key-functionalities">Key functionalities</a> •
  <a href="#help-us">Help us</a> •
  <a href="#what-to-do-if-you-encounter-a-problem">Issues</a> •
  <a href="#how-to-contribute">Contributions</a> •
  <a href="#acknowledgements">Acknowledgements</a> •
  <a href="#data-accessibility">Data accessibility</a> •
  <a href="#licence">Licence</a>
</p>

<<<<<<< HEAD
<br>
=======
- **Site (vignettes & reference):** <https://ecologistpablo.github.io/SharkipediaR/>
>>>>>>> b640a4d3443d9913feded1a47f9af86e98b0fda9

## Overview

**sharkipediaR** is a tidyverse-oriented R client for [Sharkipedia](https://www.sharkipedia.org) — the open database of shark, ray, and chimaera **life-history traits** and **population abundance trends** ([Dulvy et al., 2022](https://www.nature.com/articles/s41597-022-01655-1)). The package downloads public species pages politely, parses embedded HTML tables and trend series, and returns reproducible tibbles ready for analysis and plotting.

It includes functions for:

- Discovering species and searching the [species index](https://www.sharkipedia.org/species)
- Pulling taxonomy and provenance for a species (`sp_species()`)
- Extracting long-format **trait** tables (age at maturity, lengths, reproduction, …) (`sp_traits()`)
- Extracting **population trend** time series linked to literature references (`sp_trends()`)
- Listing **references** cited on species pages (`sp_references()`)
- Working **offline** with bundled example data for tutorials, tests, and CI

Every table includes **`source_url`** and **`retrieved_at`** so your workflows stay traceable to Sharkipedia and the original studies.

**Documentation:** <https://ecologistpablo.github.io/SharkpediaR/>

## Installation

**sharkipediaR** requires R ≥ 4.1.

You will need **devtools** (or **remotes**) to install from GitHub:

```r
<<<<<<< HEAD
install.packages("devtools")
=======
# install.packages("devtools")
devtools::install_github("ecologistpablo/SharkipediaR")
>>>>>>> b640a4d3443d9913feded1a47f9af86e98b0fda9
```

The latest version can be installed with vignettes:

```r
devtools::install_github("ecologistpablo/SharkpediaR", build_vignettes = TRUE)
```

For tutorials and interactive plots, also install:

```r
install.packages(c("tidyverse", "plotly", "viridis", "scico"))
```

## Key functionalities

A modular pipeline (**fetch → parse → clean → validate**) keeps the code maintainable when Sharkipedia pages change. Most users only need the `sp_*()` functions:

| Task | Function |
|------|----------|
| Species index | `sp_species_urls()`, `sp_search()` |
| Taxonomy | `sp_species()` |
| Life-history traits | `sp_traits()` |
| Population trends | `sp_trends()` |
| Literature links | `sp_references()` |
| Offline examples | `example_carcharhinus()`, `example_reid2011_trends()`, `example_white_shark_trends()` |

**Quick start (online):**

```r
suppressPackageStartupMessages(library(tidyverse))
library(sharkipediaR)

meta   <- sp_species("Carcharhinus acronotus")
traits <- sp_traits("Carcharhinus acronotus")
trends <- sp_trends("Carcharhinus acronotus")
```

<<<<<<< HEAD
**Quick start (offline):**
=======
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
| [Getting started](https://ecologistpablo.github.io/SharkipediaR/articles/sharkipediar.html) | Install, overview, workflow |
| [Ecological workflows](https://ecologistpablo.github.io/SharkipediaR/articles/ecological-workflows.html) | Fisheries / conservation examples, interactive plots |
| [Architecture & functions](https://ecologistpablo.github.io/SharkipediaR/articles/architecture-and-functions.html) | Full pipeline and internal parsers |
| [Function reference](https://ecologistpablo.github.io/SharkipediaR/reference/index.html) | All exported functions |

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
>>>>>>> b640a4d3443d9913feded1a47f9af86e98b0fda9

```r
ex <- example_carcharhinus()
```

**Tutorials** on the pkgdown site (navbar: **Tutorials**):

| Tutorial | Topic |
|----------|--------|
| [Getting started](https://ecologistpablo.github.io/SharkpediaR/articles/sharkipediar.html) | Install, first commands, offline data |
| [Ecological workflows](https://ecologistpablo.github.io/SharkpediaR/articles/ecological-workflows.html) | Reid et al. (2011) NSW trends, global white shark comparison |
| [Package architecture](https://ecologistpablo.github.io/SharkpediaR/articles/architecture-and-functions.html) | What each function does and how to use it |

In R:

```r
utils::browseVignettes("sharkipediaR")
```

**Polite use:** default index scrape is the first page only; requests are rate-limited and cached within a session. Do not run large parallel scrapes against Sharkipedia. See [DEVELOPMENT.md](DEVELOPMENT.md) for contributor notes.

## Help us

**sharkipediaR** is new, and we want it to serve everyone who uses [Sharkipedia](https://www.sharkipedia.org) in R.

If you work with shark and ray traits or trends, please consider helping:

- **Try the package** on species and references you know well — does the output match what you see on the website?
- **Suggest improvements** — new `sp_*()` helpers, clearer column names, or better defaults for common workflows ([open a feature request](https://github.com/ecologistpablo/SharkpediaR/issues/new))
- **Report bugs** with a minimal reproducible example (species name, function called, what you expected vs. what you got)
- **Share vignette ideas** — fisheries assessments, Red List prep, comparative trait analyses, or teaching examples you would like documented

You do not need to be an R package developer to help. Testing on real species pages and describing what works (or does not) is valuable.

## What to do if you encounter a problem

If you think you have found a bug or unexpected behaviour, post an issue [here](https://github.com/ecologistpablo/SharkpediaR/issues). Search existing issues first — someone may already have a workaround.

When you open a new issue, please:

- Describe the problem clearly
- Include a **reproducible example** (species name or URL, function, and R code)
- State what you expected vs. what happened
- Add screenshots or session info (`sessionInfo()`) if relevant

## How to Contribute

Contributions from the elasmobranch and R communities are welcome.

- Start a discussion with a [feature request](https://github.com/ecologistpablo/SharkpediaR/issues/new)
- For well-scoped changes, open a [pull request](https://github.com/ecologistpablo/SharkpediaR/pulls)

<<<<<<< HEAD
Please keep pull requests focused and match existing code style. See [DEVELOPMENT.md](DEVELOPMENT.md) for package layout.

## Acknowledgements

**sharkipediaR** is an independent R client; the **data and mission** belong to the [Sharkipedia](https://www.sharkipedia.org) team and contributors. We gratefully acknowledge everyone behind Sharkipedia ([About Sharkipedia](https://www.sharkipedia.org/about)).

Sharkipedia is an open-source research initiative to make published biological traits and population trends on sharks, rays, and chimaeras accessible to everyone — inspired by FishBase and modelled after the Coral Traits Database and the RAM Legacy Database. Its principles are: (1) web-based open access for all researchers, (2) expert quality control with traceability to original references, and (3) regular updates linked to IUCN Red List assessment workshops.

### Sharkipedia leadership

| | |
|---|---|
| **Dr. Christopher Mull** 
| **Dr. Nathan Pacoureau** 
| **Dr. Sebastián Pardo** 
| **Dr. Holly Kindsvater** 
| **Dr. Nicholas Dulvy** 

### Software development (Sharkipedia)

| | |
|---|---|
| **Maximilian Haack** 
| **Ann Cascarano** 

### Data contributors (Sharkipedia)
=======
## Citation
>>>>>>> b640a4d3443d9913feded1a47f9af86e98b0fda9

Our databases would not be possible without countless contributors, including:

Aaron Judah · Sean Renning · Simon Dedman · Maryam Nakhostin · aharry · lsaldana · Chris Mull · Brit Finucci · ajudah · egarcia

…and many others who enter and curate data on [sharkipedia.org](https://www.sharkipedia.org).

### This R package

**Pablo Fuenzalida** ([@ecologistpablo](https://github.com/ecologistpablo)) — unrequested package author and maintainer.

When you publish work using this package, please cite **Sharkipedia** ([Dulvy et al., 2022](https://www.nature.com/articles/s41597-022-01655-1)) and the **original studies** behind each trait or trend (`reference` column), and retain `source_url` / `retrieved_at` from **sharkipediaR** output.

## Data accessibility

- Trait and trend data: [Sharkipedia](https://www.sharkipedia.org)
- Species pages: [Species index](https://www.sharkipedia.org/species)
- References and exports: [References](https://www.sharkipedia.org/references) · [Data export](https://www.sharkipedia.org/data-export)
- API: [Sharkipedia API](https://www.sharkipedia.org/api)

**sharkipediaR** reads the same public HTML pages researchers view in a browser; it is not a bulk mirror of the database. For full exports, use Sharkipedia’s own tools where available.

## Licence

MIT © Pablo Fuenzalida. See [LICENSE](LICENSE).

**Citation — Sharkipedia database:**

> Dulvy, N.K. *et al.* (2022). The conservation status and distribution of sharks, rays, and chimaeras. *Scientific Data* **9**, 633. <https://www.nature.com/articles/s41597-022-01655-1>

**Citation — this R package:**

```r
citation("sharkipediaR")
```
