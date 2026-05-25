# SharkpediaR

I am recently unemployed, procrastinating writing the many papers I should be, and inspired by Sharks International to code more. I have also been wanting to build an R package for quite some time, it seems fun! I attended a Sharkipedia workshop during Sharks International, one of the requests that came up was an R Package. Here it is!

## Quick start

```r
# install.packages("devtools")
devtools::install_github("ecologistpablo/SharkpediaR")

library(sharkipediaR)
library(dplyr)

traits <- sp_traits("Carcharhinus acronotus")
trends <- sp_trends("Carcharhinus acronotus")
meta <- sp_species("Carcharhinus acronotus")
```

## Documentation (vignettes & pkgdown)

| Vignette | Contents |
|----------|----------|
| `vignettes/sharkipediar.Rmd` | Installation, overview, function index |
| `vignettes/ecological-workflows.Rmd` | Scientific workflows, **ggplot2** examples |
| `vignettes/architecture-and-functions.Rmd` | Every function in each `R/` script explained |

```r
# View vignettes locally
utils::browseVignettes("sharkipediaR")

# Build pkgdown site (requires pandoc + ggplot2)
pkgdown::build_site()
```

Before building the package, generate offline example data once:

```r
source("data-raw/build-vignette-data.R")
```

#25 May 2026, 10:15pm

# sharkipediaR — AI Development Blueprint

## Purpose

This document is intended for AI coding agents (Cursor, Claude Code workflows, ECC-style systems) and human collaborators building the `sharkipediaR` package.

The package goal is to provide a robust, reproducible, tidyverse-oriented R interface to publicly accessible Sharkipedia data.

The package should:

* scrape species-level information from Sharkipedia;
* expose trait and trend data through stable R functions;
* support ecological and fisheries workflows;
* integrate naturally with tidyverse pipelines;
* prioritise reproducibility and scientific usability;
* be scalable for future API or backend changes;
* support parallel retrieval safely and politely.

---

# High-Level Philosophy

This package is NOT:

* a bulk mirroring tool;
* an aggressive crawler;
* a browser automation project;
* a Selenium project;
* a JS rendering framework.

This package IS:

* a lightweight R client;
* a tidy data interface;
* a scientific reproducibility tool;
* an ecology/fisheries workflow package;
* a structured HTML parsing system.

The Sharkipedia website appears primarily server-rendered using Ruby on Rails + HTML.

Current evidence suggests:

* species pages contain directly embedded HTML tables;
* extensive JS execution is not required;
* `rvest` parsing is sufficient for most workflows.

Avoid unnecessary complexity.

---

# Primary User Personas

## Marine ecologists

Need:

* trait datasets;
* growth parameters;
* fisheries trends;
* reproducible extraction pipelines.

## Quantitative fisheries scientists

Need:

* structured biological traits;
* trend retrieval;
* batch extraction;
* reproducible metadata.

## Comparative ecology researchers

Need:

* species-level extraction;
* taxonomic metadata;
* tidy trait tables.

## Package developers

Need:

* stable interfaces;
* composable functions;
* clean return objects.

---

# Core Design Principles

## 1. Tidy-first

All user-facing outputs should return:

* tibble objects;
* long-form tidy structures where possible;
* consistent column naming.

Prefer:

* snake_case;
* explicit typing;
* explicit missing values.

---

## 2. Functional architecture

Separate:

* retrieval;
* parsing;
* cleaning;
* validation;
* formatting.

Avoid monolithic functions.

---

## 3. Robustness over cleverness

Website structure may evolve.

Prefer:

* semantic selectors;
* defensive parsing;
* validation checks;
* explicit warnings.

Avoid brittle positional selectors.

---

## 4. Polite scraping

The package must:

* rate limit requests;
* support caching;
* minimise repeated downloads;
* identify itself responsibly.

Never aggressively parallelise.

---

## 5. Scientific reproducibility

Every output should ideally include:

* source URL;
* retrieval timestamp;
* species name;
* citation/reference fields where available.

---

# Recommended Package Stack

## Core tidyverse

Required:

* dplyr
* purrr
* tidyr
* tibble
* stringr
* readr

---

## Scraping

Primary:

* rvest
* xml2
* httr2

Avoid RCurl unless absolutely required.

---

## Parallelisation

* furrr
* future
* progressr

Parallelisation must be optional and conservative.

---

## Reliability

* ratelimitr
* memoise
* cli
* rlang

---

## Package infrastructure

* usethis
* devtools
* roxygen2
* testthat
* pkgdown
* lintr
* styler

---

# Suggested Package Structure

```text
sharkipediaR/
├── R/
├── man/
├── tests/
├── vignettes/
├── data-raw/
├── inst/
├── DESCRIPTION
├── NAMESPACE
├── README.md
├── LICENSE
└── pkgdown.yml
```

---

# Initial User-Facing API

## Discovery functions

### `sp_search()`

Search species names.

Inputs:

* partial species names;
* common names;
* taxonomic groups.

Returns:

* tibble of matched species;
* URLs;
* taxonomy metadata.

---

### `sp_species_urls()`

Retrieve all known species URLs.

Should:

* scrape species index pages;
* deduplicate results;
* cache outputs.

---

# Species-level extraction

## `sp_species()`

Retrieve:

* taxonomy;
* metadata;
* external references.

Return one-row tibble.

---

## `sp_traits()`

Primary trait extraction function.

Inputs:

* species URL;
* scientific name;
* vector of species.

Outputs:

Long-form tibble.

Expected columns:

* species;
* trait_name;
* value;
* standard;
* value_type;
* sex;
* location;
* reference;
* source_url;
* retrieved_at.

---

## `sp_trends()`

Retrieve trend data.

Should support:

* species filtering;
* region filtering where available.

---

## `sp_references()`

Extract references/citations.

---

# Trait-Centric Workflows

The package should not only support species-centric workflows.

Users should also be able to retrieve:

* all species containing a trait;
* all observations for a trait;
* trend-centric extractions.

Potential functions:

## `sp_trait_catalogue()`

Return available traits.

---

## `sp_trait_data()`

Retrieve observations for a trait across species.

---

## `sp_trend_catalogue()`

Return available trends.

---

# Parsing Architecture

## IMPORTANT

Never combine:

* HTTP retrieval;
* HTML parsing;
* cleaning;
* formatting.

Each stage should be modular.

---

## Recommended architecture

### Retrieval

```r
fetch_page()
```

Responsibilities:

* request handling;
* retries;
* headers;
* rate limiting.

Returns:

* raw HTML document.

---

### Parsing

```r
parse_traits_table()
parse_taxonomy()
parse_references()
```

Responsibilities:

* HTML selector logic only.

---

### Cleaning

```r
clean_traits()
```

Responsibilities:

* typing;
* naming;
* standardisation.

---

### Validation

```r
validate_traits()
```

Responsibilities:

* required columns;
* missing data;
* malformed tables.

---

# Error Handling

Use:

* purrr::possibly()
* purrr::safely()
* cli warnings/messages
* structured condition handling

Never silently fail.

All scraping functions should gracefully handle:

* missing tables;
* malformed pages;
* HTTP failures;
* changed HTML structure.

---

# Parallelisation Strategy

Parallelisation should:

* be opt-in;
* use future/furrr;
* remain conservative.

Recommended defaults:

* sequential by default;
* optional multisession.

Never hammer the server.

Include randomised delays.

Example:

```r
Sys.sleep(runif(1, 0.5, 1.5))
```

---

# Caching Strategy

Strongly recommended.

Potential approaches:

* memoise;
* local RDS cache;
* pins integration later.

Cache:

* species index pages;
* species HTML;
* parsed tables.

---

# HTML Parsing Guidance

Prefer:

* semantic selectors;
* table headers;
* text-based anchors.

Avoid:

* deeply nested positional selectors;
* JS-derived selectors;
* brittle nth-child logic.

---

# Likely Website Technology

Current evidence suggests:

* Ruby on Rails backend;
* server-rendered HTML;
* Turbolinks/Turbo navigation;
* JS primarily for navigation enhancement.

Implications:

* rvest should suffice;
* browser automation should be avoided unless absolutely necessary.

---

# ECC / AI Workflow Integration

This repository should be optimised for AI-assisted development.

---

# Recommended AI Context Files

## `project_context.md`

Contains:

* package philosophy;
* coding conventions;
* package goals;
* dependency constraints.

---

## `selectors.md`

Tracks:

* known CSS selectors;
* page structures;
* fragile parsing areas.

---

## `website_notes.md`

Tracks:

* discovered routes;
* HTML structures;
* observed inconsistencies.

---

## `development_tasks.md`

Tracks:

* TODOs;
* parser stability;
* coverage gaps.

---

# AI Coding Instructions

When modifying package code:

## ALWAYS

* preserve tidyverse semantics;
* write small composable functions;
* separate parsing from cleaning;
* maintain explicit typing;
* add tests for selectors;
* prefer readability over cleverness.

---

## NEVER

* write giant monolithic scraping functions;
* hardcode fragile selectors unnecessarily;
* aggressively parallelise requests;
* use browser automation unless justified;
* silently suppress parsing failures.

---

# Testing Strategy

Use:

* testthat;
* snapshot tests where appropriate;
* selector validation tests.

Important test types:

## HTML structure tests

Ensure selectors still work.

---

## Parsing tests

Ensure:

* column names;
* typing;
* expected row structures.

---

## Regression tests

Store representative HTML fixtures.

Avoid relying entirely on live requests.

---

# Documentation Strategy

Use:

* roxygen2;
* pkgdown;
* long-form ecological examples.

Documentation should prioritise:

* reproducibility;
* ecological workflows;
* fisheries examples;
* tidyverse integration.

---

# Example Desired Workflow

```r
library(sharkipediaR)
library(dplyr)

traits <- sp_traits("Aetobatus narinari")

traits %>%
  filter(trait_name == "Linf") %>%
  summarise(mean_linf = mean(value, na.rm = TRUE))
```

---

# Potential Future Extensions

## Spatial workflows

Potential integration:

* sf
* terra

---

## Offline caching

Potential:

* pins
* arrow/parquet

---

## Taxonomic harmonisation

Potential:

* fishbase joins;
* WoRMS integration.

---

## API support

If Sharkipedia later exposes APIs:

* retain stable user-facing interfaces;
* swap backend retrieval layer only.

---

# Publication Goals

## Initial

* GitHub package;
* MIT licence;
* pkgdown site.

---

## Later

* CRAN readiness;
* CI/CD;
* stable release cycle.

---

# Recommended Immediate Tasks

## Phase 1

* create package skeleton;
* configure usethis;
* implement species URL scraping;
* implement species parser.

---

## Phase 2

* implement trait extraction;
* implement cleaning pipelines;
* implement tests.

---

## Phase 3

* parallel retrieval workflows;
* caching;
* pkgdown site.

---

## Phase 4

* trait-centric interfaces;
* trend extraction;
* advanced workflows.

---

# Existing Relevant Resources

## Sharkipedia website

Primary target.

Likely technologies:

* Ruby on Rails;
* HTML tables;
* JS-enhanced navigation.

---

## Sharkipedia GitHub repository

Use for:

* understanding HTML structure;
* discovering route patterns;
* identifying semantic structure;
* anticipating future changes.

Avoid tightly coupling parsing logic to implementation internals.

---

## Historical workshop

Reference:

[https://github.com/creeas/shaRk-workshop](https://github.com/creeas/shaRk-workshop)

Potential uses:

* understanding ecological workflows;
* naming conventions;
* user expectations.

---

# Final Architectural Principle

The package should feel like:

* a modern tidyverse client;
* a scientific data interface;
* a reproducible ecology toolkit.

Not:

* a brittle scraping script collection.
