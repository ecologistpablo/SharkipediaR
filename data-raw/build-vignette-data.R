# Builds inst/extdata/carcharhinus_acronotus.rds for offline vignettes and examples.
suppressPackageStartupMessages(library(dplyr))
pkg_root <- if (file.exists("DESCRIPTION")) "." else ".."
fixture <- function(name) {
  file.path(pkg_root, "tests", "testthat", "fixtures", name)
}

doc <- xml2::read_html(fixture("carcharhinus_acronotus.html"), encoding = "UTF-8")
source_url <- "https://www.sharkipedia.org/species/carcharhinus-acronotus"
retrieved_at <- as.POSIXct("2026-05-25 12:00:00", tz = "UTC")

# Source helpers without full package load
source(file.path(pkg_root, "R", "constants.R"))
source(file.path(pkg_root, "R", "parse.R"))
source(file.path(pkg_root, "R", "clean.R"))
source(file.path(pkg_root, "R", "validate.R"))

species_name <- "Carcharhinus acronotus"

example_data <- list(
  species_meta = parse_taxonomy(doc) %>%
    dplyr::mutate(
      source_url = source_url,
      retrieved_at = retrieved_at
    ),
  traits = validate_traits(clean_traits(
    parse_traits_tables(doc),
    species = species_name,
    source_url = source_url,
    retrieved_at = retrieved_at
  )),
  trends = validate_trends(clean_trends(
    parse_trends_tables(doc),
    species = species_name,
    source_url = source_url,
    retrieved_at = retrieved_at
  )),
  references = {
    refs <- parse_references(doc)
    refs$species <- species_name
    refs$source_url <- source_url
    refs$retrieved_at <- retrieved_at
    refs
  },
  species_index = parse_species_index(
    xml2::read_html(fixture("species_index_page1.html"), encoding = "UTF-8")
  )
)

out_dir <- file.path(pkg_root, "inst", "extdata")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
saveRDS(example_data, file.path(out_dir, "carcharhinus_acronotus.rds"))
message("Wrote ", file.path(out_dir, "carcharhinus_acronotus.rds"))
