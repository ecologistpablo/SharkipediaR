[![ecologistpablo - SharkpediaR](https://img.shields.io/static/v1?label=ecologistpablo&message=SharkpediaR&color=blue&logo=github)](https://github.com/ecologistpablo/SharkpediaR)
[![pkgdown site](https://img.shields.io/badge/pkgdown-site-blue)](https://ecologistpablo.github.io/SharkpediaR/)
[![issues - SharkpediaR](https://img.shields.io/github/issues/ecologistpablo/SharkpediaR)](https://github.com/ecologistpablo/SharkpediaR/issues)
[![stars - SharkpediaR](https://img.shields.io/github/stars/ecologistpablo/SharkpediaR?style=social)](https://github.com/ecologistpablo/SharkpediaR)
[![forks - SharkpediaR](https://img.shields.io/github/forks/ecologistpablo/SharkpediaR?style=social)](https://github.com/ecologistpablo/SharkpediaR)
[![watchers - SharkpediaR](https://img.shields.io/github/watchers/ecologistpablo/SharkpediaR?style=social)](https://github.com/ecologistpablo/SharkpediaR)

main branch:
[![pkgdown](https://github.com/ecologistpablo/SharkpediaR/actions/workflows/pkgdown.yaml/badge.svg?branch=main)](https://github.com/ecologistpablo/SharkpediaR/actions/workflows/pkgdown.yaml)

<!-- badges: end -->

<img width="588" height="178" alt="Screenshot 2026-05-25 at 11 56 07 pm" src="https://github.com/user-attachments/assets/f65d1595-86c0-4bff-944c-0d7e13f460cc" />


<h1 align="center">sharkipediaR</h1>
<h4 align="center">An R package to access Sharkipedia life-history traits and population trends</h4>

<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#installation">Installation</a> •
  <a href="#key-functionalities">Key functionalities</a> •
  <a href="#design">Design</a> •
  <a href="#help-us">Help us</a> •
  <a href="#what-to-do-if-you-encounter-a-problem">Issues</a> •
  <a href="#how-to-contribute">Contributions</a> •
  <a href="#acknowledgements">Acknowledgements</a> •
  <a href="#data-accessibility">Data accessibility</a> •
  <a href="#licence">Licence</a>
</p>

<br>

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

<br>

## Installation

**sharkipediaR** requires R ≥ 4.1.

You will need **devtools** (or **remotes**) to install from GitHub:

```r
install.packages("devtools")
devtools::install_github("ecologistpablo/SharkpediaR")
```

The latest version can be installed with vignettes:

```r
devtools::install_github("ecologistpablo/SharkpediaR", build_vignettes = TRUE)
```

For tutorials and interactive plots, also install:

```r
install.packages(c("tidyverse", "plotly", "viridis", "scico"))
```

<br>

## Key functionalities

A modular pipeline (**fetch → parse → clean → validate**) keeps the code maintainable when Sharkipedia pages change. Most users only need the `sp_*()` functions:

| Task | Function | Potential use |
|------|----------|----------------|
| Species index | `sp_species_urls()`, `sp_search()` | Build species lists for comparative or regional meta-analyses. |
| Taxonomy | `sp_species()` | Attach higher taxonomic ranks when merging Sharkipedia data with other elasmobranch datasets. |
| Life-history traits | `sp_traits()` | Parameterise age-structured or demographic models from published trait values. |
| Population trends | `sp_trends()` | Plot or model abundance trajectories cited in stock assessments or conservation reviews. |
| Literature links | `sp_references()` | Trace each measurement back to the primary study for methods sections and citations. |
| Offline examples | `example_carcharhinus()`, `example_reid2011_trends()`, `example_white_shark_trends()` | Teach workshops or run CI without hitting the live website. |

**Quick start (online):**

```r
suppressPackageStartupMessages(library(tidyverse))
library(sharkipediaR)

meta   <- sp_species("Carcharhinus acronotus")
traits <- sp_traits("Carcharhinus acronotus")
trends <- sp_trends("Carcharhinus acronotus")
```

**Quick start (offline):**

```r
ex <- example_carcharhinus()
ex$traits %>% filter(trait_name == "Amat50")
```

Every table includes **`source_url`** and **`retrieved_at`** for reproducible methods sections.

<br>

## Design

**sharkipediaR** is a lightweight scientific client — not a bulk crawler. It reads the same public HTML pages you would open in a browser, with polite rate limits and in-session caching (`memoise`).

<p align="center">
  <img src="inst/images/sharkipedia-pipeline.svg" alt="sharkipediaR pipeline: Sharkipedia species pages flow through fetch, parse, clean, and sp_* functions into tidyverse analysis" width="960" style="max-width: 100%; height: auto;">
</p>

For argument lists, return columns, and worked examples per function, see the [Package architecture](https://ecologistpablo.github.io/SharkpediaR/articles/architecture-and-functions.html) vignette.

<br>

## Documentation

| Resource | Description |
|----------|-------------|
| [Getting started](https://ecologistpablo.github.io/SharkpediaR/articles/sharkipediar.html) | Install, overview, workflow |
| [Ecological workflows](https://ecologistpablo.github.io/SharkpediaR/articles/ecological-workflows.html) | Fisheries / conservation examples, interactive plots |
| [Architecture & functions](https://ecologistpablo.github.io/SharkpediaR/articles/architecture-and-functions.html) | Pipeline, full function reference, internal parsers |

In R: `utils::browseVignettes("sharkipediaR")`

Vignettes appear under **Articles** in the pkgdown navbar. The site is built with [pkgdown](https://pkgdown.r-lib.org/); see [DEVELOPMENT.md](DEVELOPMENT.md) for contributor notes.

<br>

## Help us

**sharkipediaR** is new, and we want it to serve everyone who uses [Sharkipedia](https://www.sharkipedia.org) in R.

If you work with shark and ray traits or trends, please consider helping:

- **Try the package** on species and references you know well — does the output match what you see on the website?
- **Suggest improvements** — new `sp_*()` helpers, clearer column names, or better defaults for common workflows ([open a feature request](https://github.com/ecologistpablo/SharkpediaR/issues/new))
- **Report bugs** with a minimal reproducible example (species name, function called, what you expected vs. what you got)
- **Share vignette ideas** — fisheries assessments, Red List prep, comparative trait analyses, or teaching examples you would like documented

You do not need to be an R package developer to help. Testing on real species pages and describing what works (or does not) is valuable.

<br>

## What to do if you encounter a problem

If you think you have found a bug or unexpected behaviour, post an issue [here](https://github.com/ecologistpablo/SharkpediaR/issues). Search existing issues first — someone may already have a workaround.

When you open a new issue, please:

- Describe the problem clearly
- Include a **reproducible example** (species name or URL, function, and R code)
- State what you expected vs. what happened
- Add screenshots or session info (`sessionInfo()`) if relevant

<br>

## How to Contribute

Contributions from the elasmobranch and R communities are welcome.

- Start a discussion with a [feature request](https://github.com/ecologistpablo/SharkpediaR/issues/new)
- For well-scoped changes, open a [pull request](https://github.com/ecologistpablo/SharkpediaR/pulls)

Please keep pull requests focused and match existing code style. See [DEVELOPMENT.md](DEVELOPMENT.md) for package layout.

<br>

## Acknowledgements

**sharkipediaR** is an independent R client; the **data and mission** belong to the [Sharkipedia](https://www.sharkipedia.org) team and contributors. We gratefully acknowledge everyone behind Sharkipedia ([About Sharkipedia](https://www.sharkipedia.org/about)).

Sharkipedia is an open-source research initiative to make published biological traits and population trends on sharks, rays, and chimaeras accessible to everyone — inspired by FishBase and modelled after the Coral Traits Database and the RAM Legacy Database. Its principles are: (1) web-based open access for all researchers, (2) expert quality control with traceability to original references, and (3) regular updates linked to IUCN Red List assessment workshops.

### Sharkipedia leadership

| Name |
|------|
| Dr. Christopher Mull |
| Dr. Nathan Pacoureau |
| Dr. Sebastián Pardo |
| Dr. Holly Kindsvater |
| Dr. Nicholas Dulvy |

### Software development (Sharkipedia)

| Name |
|------|
| Maximilian Haack |
| Ann Cascarano |

### Data contributors (Sharkipedia)

Our databases would not be possible without countless contributors, including:

Aaron Judah · Sean Renning · Simon Dedman · Maryam Nakhostin · aharry · lsaldana · Chris Mull · Brit Finucci · ajudah · egarcia

…and many others who enter and curate data on [sharkipedia.org](https://www.sharkipedia.org).

When you publish work using this package, please cite **Sharkipedia** ([Dulvy et al., 2022](https://www.nature.com/articles/s41597-022-01655-1)) and the **original studies** behind each trait or trend (`reference` column), and retain `source_url` / `retrieved_at` from **sharkipediaR** output.

<br>

## Data accessibility

- Trait and trend data: [Sharkipedia](https://www.sharkipedia.org)
- Species pages: [Species index](https://www.sharkipedia.org/species)
- References and exports: [References](https://www.sharkipedia.org/references) · [Data export](https://www.sharkipedia.org/data-export)
- API: [Sharkipedia API](https://www.sharkipedia.org/api)

**sharkipediaR** reads the same public HTML pages researchers view in a browser; it is not a bulk mirror of the database. For full exports, use Sharkipedia’s own tools where available.

<br>

## Licence

MIT © Pablo Fuenzalida. See [LICENSE](LICENSE).

**Citation — Sharkipedia database:**

> Dulvy, N.K. *et al.* (2022). The conservation status and distribution of sharks, rays, and chimaeras. *Scientific Data* **9**, 633. <https://www.nature.com/articles/s41597-022-01655-1>

**Citation — this R package:**

```r
citation("sharkipediaR")
```
