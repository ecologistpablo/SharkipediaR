# Ecological workflows with Sharkipedia data

``` r

library(sharkipediaR)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(plotly)

ex <- example_carcharhinus()
traits <- ex$traits
trends <- ex$trends
meta <- ex$species_meta

theme_shark <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold", size = 13),
      plot.subtitle = element_text(colour = "grey30", size = 10),
      strip.text = element_text(face = "bold")
    )
}

# Wrap ggplot objects for interactive tooltips in HTML vignettes / pkgdown
as_interactive <- function(p) {
  plotly::ggplotly(p, tooltip = "all") %>%
    plotly::layout(hovermode = "closest")
}
```

## The scientific case

Chondrichthyans are among the most threatened vertebrate lineages.
Comparative traits (maturity, growth, fecundity) and standardized
abundance trends are the currency of:

- **Extinction-risk assessment** (IUCN Red List criteria tied to
  population reduction),
- **Data-limited fisheries methods** (life-history priors for $`r`$,
  $`F_{MSY}`$, generation time),
- **Macroecology** (allometric and life-history invariants across
  species).

Sharkipedia centralizes those measurements with traceable references.
**sharkipediaR** lets you treat Sharkipedia like any other data API in R
— filter, summarize, and plot with familiar **`%>%`** pipes and
interactive **plotly** charts in this vignette.

Throughout this vignette we use
**[`example_carcharhinus()`](https://ecologistpablo.github.io/SharkpediaR/reference/example_carcharhinus.md)**
(blacknose shark, *Carcharhinus acronotus*), a data-rich coastal species
with both traits and Northwest Atlantic trends. Live extraction is
identical — swap in
[`sp_traits()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_traits.md)
/
[`sp_trends()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_trends.md)
when you are online.

------------------------------------------------------------------------

## `sp_species()` — taxonomy for comparative frameworks

**File:** `R/sp_species.R`

[`sp_species()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_species.md)
returns a **one-row tibble** with taxonomic ranks parsed from the
species page header, plus provenance.

**Pipeline:** `resolve_species_url()` →
[`fetch_page()`](https://ecologistpablo.github.io/SharkpediaR/reference/fetch_page.md)
→
[`parse_taxonomy()`](https://ecologistpablo.github.io/SharkpediaR/reference/parse_taxonomy.md)
→ add `source_url` and `retrieved_at`.

``` r

meta
#> # A tibble: 1 × 7
#>   species        superorder subclass order family source_url retrieved_at       
#>   <chr>          <chr>      <chr>    <chr> <chr>  <chr>      <dttm>             
#> 1 Carcharhinus … Galeomorp… Elasmob… Carc… Carch… https://w… 2026-05-25 12:00:00
```

Use this to join trait or trend tables to order/family for comparative
plots across many species (after a batch
[`sp_traits()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_traits.md)
call).

**Live equivalent:**

``` r

sp_species("Carcharhinus acronotus")
```

------------------------------------------------------------------------

## `sp_traits()` — life-history measurements in long format

**File:** `R/sp_traits.R`

[`sp_traits()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_traits.md)
is the workhorse for ecology. It returns one row per **measurement**
with columns:

| Column | Meaning |
|----|----|
| `trait_group` | Sharkipedia grouping (Age, Length, Reproduction, …) |
| `trait_name` | Trait label (e.g. `Amat50`, `Linf`) |
| `value` | Reported value (character; coerce with [`as.numeric()`](https://rdrr.io/r/base/numeric.html) when appropriate) |
| `standard` | Units or category (e.g. `Year`, `cm`) |
| `value_type` | Often `mean`, `median`, etc. |
| `sex` | `Male`, `Female`, `Pooled`, … |
| `location` | Geographic or study location |
| `reference` | Sharkipedia reference ID |
| `source_url`, `retrieved_at` | Reproducibility |

**Pipeline:**
[`fetch_page()`](https://ecologistpablo.github.io/SharkpediaR/reference/fetch_page.md)
→
[`parse_traits_tables()`](https://ecologistpablo.github.io/SharkpediaR/reference/parse_traits_tables.md)
→
[`clean_traits()`](https://ecologistpablo.github.io/SharkpediaR/reference/clean_traits.md)
→ `validate_traits()`.

### How many traits, and from which groups?

``` r

traits %>%
  count(trait_group, sort = TRUE)
#> # A tibble: 5 × 2
#>   trait_group         n
#>   <chr>           <int>
#> 1 Reproduction       17
#> 2 Length             15
#> 3 Relationships       4
#> 4 Ecological Role     2
#> 5 Age                 1
```

### Plot 1 — Age at 50% maturity by sex

A classic input for generation length and demographic models: **age at
50% maturity (`Amat50`)** by sex.

``` r

amat50 <- traits %>%
  filter(trait_name == "Amat50") %>%
  mutate(value_num = as.numeric(value))

p_amat50 <- ggplot(amat50, aes(
  x = sex, y = value_num, fill = sex,
  text = paste0(
    "Reference: ", reference,
    "<br>Location: ", location,
    "<br>Value: ", value_num, " years"
  )
)) +
  geom_col(width = 0.6, alpha = 0.85) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Age at 50% maturity — Carcharhinus acronotus",
    subtitle = "Hover for Sharkipedia reference and location",
    x = NULL,
    y = "Age (years)",
    fill = "Sex",
    caption = meta$source_url[[1]]
  ) +
  theme_shark() +
  theme(legend.position = "none")

as_interactive(p_amat50)
```

Each bar is traceable to a **`reference`** ID on Sharkipedia — exactly
what you want in a methods paragraph.

### Plot 2 — Distribution of numeric traits across groups

``` r

numeric_traits <- traits %>%
  mutate(value_num = suppressWarnings(as.numeric(value))) %>%
  filter(!is.na(value_num), trait_group %in% c("Age", "Length", "Reproduction"))

p_traits <- ggplot(numeric_traits, aes(
  x = trait_group, y = value_num, fill = trait_group,
  text = paste0(
    trait_name, " (", sex, ")",
    "<br>", value_num, " ", standard,
    "<br>", location
  )
)) +
  geom_boxplot(outlier.shape = 21, alpha = 0.7) +
  scale_y_continuous(trans = "log10", labels = scales::label_number()) +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    title = "Numeric life-history measurements by trait group",
    subtitle = "Hover points for trait name, sex, and location",
    x = NULL,
    y = "Reported value (log scale)",
    fill = "Group",
    caption = "Example data: example_carcharhinus()"
  ) +
  theme_shark() +
  theme(legend.position = "none")

as_interactive(p_traits)
```

### dplyr workflow — matching the README blueprint

``` r

# With live data:
# traits_live <- sp_traits("Aetobatus narinari")

traits %>%
  filter(trait_name == "Linf") %>%
  summarise(
    n = n(),
    mean_linf = mean(as.numeric(value), na.rm = TRUE),
    .by = sex
  )
```

**Batch species:** pass a character vector;
[`sp_traits()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_traits.md)
row-binds results and adds `species_input`.

``` r

sp_traits(c("Carcharhinus acronotus", "Alopias vulpinus"))
```

------------------------------------------------------------------------

## `sp_trends()` — population trajectories for assessment & Red List thinking

**File:** `R/sp_trends.R`

Trend data are embedded in species pages as JSON inside
`data-react-props` (server-rendered).
[`parse_trends_tables()`](https://ecologistpablo.github.io/SharkpediaR/reference/parse_trends_tables.md)
expands each trend to long format: **`year`**, **`value`**,
**`location`**, **`unit`**, **`reference`**, **`trend_id`**.

**Pipeline:**
[`fetch_page()`](https://ecologistpablo.github.io/SharkpediaR/reference/fetch_page.md)
→
[`parse_trends_tables()`](https://ecologistpablo.github.io/SharkpediaR/reference/parse_trends_tables.md)
→
[`clean_trends()`](https://ecologistpablo.github.io/SharkpediaR/reference/clean_trends.md)
→ `validate_trends()`.

``` r

trends %>%
  distinct(location, unit, reference, trend_id) %>%
  arrange(location)
#> # A tibble: 8 × 4
#>   location                                      unit       reference    trend_id
#>   <chr>                                         <chr>      <chr>        <chr>   
#> 1 Brownsville, TX to the Florida Keys, FL (USA) individual Pollackunpu… 3540    
#> 2 North Carolina to Brownsville (USA)           individual peterson2017 3537    
#> 3 North Gulf of Mexico                          individual sedar2011a   3543    
#> 4 North Gulf of Mexico                          kg         sedar2011a   3544    
#> 5 North Gulf of Mexico (USA)                    individual Pollackunpu… 3538    
#> 6 North Gulf of Mexico (USA)                    individual Pollackunpu… 3539    
#> 7 Northwest Atlantic                            individual SEDAR2011    3541    
#> 8 Northwest Atlantic                            kg         SEDAR2011    3542
```

### Plot 3 — Standardized index through time (single series)

Many Sharkipedia trends are **standardized indices** or relative
abundances — ideal for showing directional change when absolute scale
varies by survey.

``` r

one_trend <- trends %>%
  filter(trend_id == "3537")

p_trend <- ggplot(one_trend, aes(
  x = year, y = value,
  text = paste0(
    "Year: ", year,
    "<br>Index: ", round(value, 3),
    "<br>Reference: ", reference,
    "<br>", location
  )
)) +
  geom_line(linewidth = 0.9, colour = "#1f4e79") +
  geom_point(size = 1.8, colour = "#1f4e79") +
  labs(
    title = "Population trend — North Carolina to Brownsville (USA)",
    subtitle = "Hover points for year, index value, and reference",
    x = "Year",
    y = "Index value",
    caption = one_trend$trend_url[[1]]
  ) +
  theme_shark()

as_interactive(p_trend)
```

In a Red List or ERAs context, you would align such series to time
windows required by criteria A2/A4, document the **`reference`**, and
keep the **`retrieved_at`** stamp from
[`sp_trends()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_trends.md).

### Plot 4 — Multiple locations, faceted

``` r

trend_summary <- trends %>%
  group_by(location, unit, trend_id) %>%
  summarise(
    n_years = n(),
    year_min = min(year),
    year_max = max(year),
    .groups = "drop"
  ) %>%
  filter(n_years >= 10) %>%
  slice_head(n = 6)

plot_df <- trends %>%
  semi_join(trend_summary, by = "trend_id")

p_facet <- ggplot(plot_df, aes(
  x = year, y = value,
  colour = location,
  text = paste0(
    location,
    "<br>Year: ", year,
    "<br>Value: ", round(value, 3),
    "<br>Reference: ", reference,
    "<br>Unit: ", unit
  )
)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.2, alpha = 0.7) +
  labs(
    title = "Multiple abundance trends for one species",
    subtitle = "Interactive: zoom, pan, and hover for metadata",
    x = "Year",
    y = "Value (units vary by series)",
    colour = "Location",
    caption = meta$source_url[[1]]
  ) +
  theme_shark() +
  theme(legend.position = "bottom")

as_interactive(p_facet)
```

**Live extraction:**

``` r

sp_trends("Carcharhinus acronotus")
```

------------------------------------------------------------------------

## `sp_references()` — linking data to the literature graph

**File:** `R/sp_references.R`

Collects unique `/references/...` links from trait and trend tables on
the species page.

``` r

ex$references %>%
  slice_head(n = 8)
#> # A tibble: 8 × 5
#>   reference_id      reference_url         species source_url retrieved_at       
#>   <chr>             <chr>                 <chr>   <chr>      <dttm>             
#> 1 clementi2021      https://www.sharkipe… Carcha… https://w… 2026-05-25 12:00:00
#> 2 driggers2004a     https://www.sharkipe… Carcha… https://w… 2026-05-25 12:00:00
#> 3 trinidadcruz1997  https://www.sharkipe… Carcha… https://w… 2026-05-25 12:00:00
#> 4 uribemartinez1993 https://www.sharkipe… Carcha… https://w… 2026-05-25 12:00:00
#> 5 peterson2017      https://www.sharkipe… Carcha… https://w… 2026-05-25 12:00:00
#> 6 pollackunpubl1    https://www.sharkipe… Carcha… https://w… 2026-05-25 12:00:00
#> 7 pollackunpubl2    https://www.sharkipe… Carcha… https://w… 2026-05-25 12:00:00
#> 8 sedar2011         https://www.sharkipe… Carcha… https://w… 2026-05-25 12:00:00
```

Join `traits$reference` to `references$reference_id` for bibliographic
workflows (DOI lookup, `bibtex` keys).

------------------------------------------------------------------------

## Discovery: `sp_species_urls()` and `sp_search()`

Before batch analysis, discover what Sharkipedia hosts:

``` r

ex$species_index %>%
  slice_head(n = 6)
#> # A tibble: 6 × 3
#>   species              slug                              url                    
#>   <chr>                <chr>                             <chr>                  
#> 1 Rajella leopardus    rajella-leopardus                 https://www.sharkipedi…
#> 2 Gymnura lessae       gymnura-lessae                    https://www.sharkipedi…
#> 3 Styracura schmardae  html-i-styracura-schmardae-i-html https://www.sharkipedi…
#> 4 Dipturus lamillai    dipturus-lamillai                 https://www.sharkipedi…
#> 5 Bathyraja murrayi    bathyraja-marrayi                 https://www.sharkipedi…
#> 6 Tetronarce nobiliana tetronarce-nobiliana              https://www.sharkipedi…
```

**[`sp_species_urls()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_species_urls.md)**
(`R/sp_species_urls.R`):

- Default: first index page only (polite).
- `all_pages = TRUE`: walks pagination (65+ pages) — use `max_pages` to
  cap load during development.

**[`sp_search()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_search.md)**
(`R/sp_search.R`):

- Case-insensitive substring match on `species` or `slug`.
- Pass a pre-built `index` to avoid re-downloading the full catalogue.

``` r

idx <- sp_species_urls(all_pages = TRUE, max_pages = 5)
sp_search("Carcharhinus", index = idx)
```

------------------------------------------------------------------------

## Reproducibility checklist (workshop-ready)

1.  Record `packageVersion("sharkipediaR")` and
    [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html).
2.  Store `source_url` and `retrieved_at` from every `sp_*()` call.
3.  Archive raw outputs with `write_csv()` or
    [`saveRDS()`](https://rdrr.io/r/base/readRDS.html).
4.  Prefer building a species list once with
    [`sp_species_urls()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_species_urls.md)
    rather than repeated index scrapes.

``` r

sessionInfo()
#> R version 4.6.0 (2026-04-24)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.4 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
#>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
#>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
#> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
#> 
#> time zone: UTC
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] plotly_4.12.0      scales_1.4.0       ggplot2_4.0.3      tidyr_1.3.2       
#> [5] dplyr_1.2.1        sharkipediaR_0.1.0
#> 
#> loaded via a namespace (and not attached):
#>  [1] gtable_0.3.6       jsonlite_2.0.0     compiler_4.6.0     tidyselect_1.2.1  
#>  [5] jquerylib_0.1.4    systemfonts_1.3.2  textshaping_1.0.5  yaml_2.3.12       
#>  [9] fastmap_1.2.0      R6_2.6.1           labeling_0.4.3     generics_0.1.4    
#> [13] knitr_1.51         htmlwidgets_1.6.4  tibble_3.3.1       desc_1.4.3        
#> [17] RColorBrewer_1.1-3 bslib_0.11.0       pillar_1.11.1      rlang_1.2.0       
#> [21] utf8_1.2.6         cachem_1.1.0       xfun_0.57          S7_0.2.2          
#> [25] fs_2.1.0           sass_0.4.10        lazyeval_0.2.3     otel_0.2.0        
#> [29] viridisLite_0.4.3  cli_3.6.6          withr_3.0.2        pkgdown_2.2.0     
#> [33] magrittr_2.0.5     crosstalk_1.2.2    digest_0.6.39      grid_4.6.0        
#> [37] lifecycle_1.0.5    vctrs_0.7.3        data.table_1.18.4  evaluate_1.0.5    
#> [41] glue_1.8.1         farver_2.1.2       ragg_1.5.2         httr_1.4.8        
#> [45] rmarkdown_2.31     purrr_1.2.2        tools_4.6.0        pkgconfig_2.0.3   
#> [49] htmltools_0.5.9
packageVersion("sharkipediaR")
#> [1] '0.1.0'
```

------------------------------------------------------------------------

## What is next in your analysis?

- Combine trait imputation with trends for data-poor relatives (Robin
  Hood / comparative approaches in the Dulvy tradition).
- Scale to many species with **conservative** rate limits (sequential
  [`sp_traits()`](https://ecologistpablo.github.io/SharkpediaR/reference/sp_traits.md)
  loops; parallel only with care).
- Watch for Phase 4 functions (`sp_trait_catalogue()`, trait-centric
  queries) in future releases.

For implementation details of every internal function, see the
**Architecture and function reference** vignette.
