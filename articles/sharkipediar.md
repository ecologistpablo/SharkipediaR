# Getting started with sharkipediaR

## Why this package exists

[Sharkipedia](https://www.sharkipedia.org) is a curated, open database
of shark and ray life-history traits and population abundance time
series — the kind of comparative resource that underpins fisheries
assessment, extinction-risk analysis, and macroecology ([Dulvy et al.,
2022](https://www.nature.com/articles/s41597-022-01655-1)).
**sharkipediaR** brings those data into R as tidy tibbles so your
workflows look like any other modern ecological analysis: **`%>%`**
pipes, explicit provenance, ggplot-ready tables, and interactive
**plotly** charts in the ecological vignette.

The package is deliberately **not** a bulk mirror of the website. It is
a polite, reproducible client: rate-limited requests, in-session
caching, and HTML parsing separated from cleaning and validation.

## Installation

``` r

# install.packages("devtools")
devtools::install_github("ecologistpablo/SharkpediaR")
```

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
```

## A thirty-second workflow

With an internet connection, you can pull data for a single species in
three lines:

``` r

meta   <- sp_species("Carcharhinus acronotus")
traits <- sp_traits("Carcharhinus acronotus")
trends <- sp_trends("Carcharhinus acronotus")
```

Every user-facing table includes **`source_url`** and **`retrieved_at`**
so you can cite exactly what was downloaded and when — essential for Red
List workshops, stock assessments, and supplementary materials.

## Offline example data

Vignettes and `R CMD check` use a frozen example dataset so
documentation builds without hitting the live site:

``` r

ex <- example_carcharhinus()
names(ex)
#> [1] "species_meta"  "traits"        "trends"        "references"   
#> [5] "species_index"
```

| List element    | Description                                 |
|-----------------|---------------------------------------------|
| `species_meta`  | Taxonomy + provenance (one row)             |
| `traits`        | Long-format life-history trait measurements |
| `trends`        | Long-format population trend observations   |
| `references`    | Reference IDs linked from the species page  |
| `species_index` | Sample rows from the public species index   |

## Exported functions at a glance

| Function | Script | Purpose |
|----|----|----|
| [`sp_species_urls()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_species_urls.md) | `R/sp_species_urls.R` | Discover species names and URLs from the index |
| [`sp_search()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_search.md) | `R/sp_search.R` | Filter the index by partial scientific name |
| [`sp_species()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_species.md) | `R/sp_species.R` | Taxonomy metadata for one species |
| [`sp_traits()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_traits.md) | `R/sp_traits.R` | Life-history traits (long format) |
| [`sp_trends()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_trends.md) | `R/sp_trends.R` | Population trends (long format) |
| [`sp_references()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_references.md) | `R/sp_references.R` | Bibliographic reference links |
| [`fetch_page()`](https://ecologistpablo.github.io/SharkpediaR/reference/fetch_page.md) | `R/fetch.R` | Low-level HTML retrieval (advanced) |
| [`example_carcharhinus()`](https://ecologistpablo.github.io/SharkpediaR/reference/example_carcharhinus.md) | `R/example_data.R` | Offline example data |

Internal parsing and cleaning live in `R/parse.R`, `R/clean.R`, and
`R/validate.R` — see the **Architecture and function reference**
vignette.

## Where to go next

- **Ecological workflows** — trait summaries, interactive **plotly**
  trend plots, `%>%` workflows.
- **Architecture and function reference** — how every function in each
  script works, with pipeline examples.

## Building the pkgdown site

``` r

install.packages(c("pkgdown", "ggplot2", "plotly", "htmltools"))
pkgdown::build_site()
```

The site will include these vignettes under **Articles** automatically.
