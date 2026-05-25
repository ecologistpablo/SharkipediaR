fixture_path <- function(name) {
  testthat::test_path("fixtures", name)
}

test_that("parse_species_index extracts species links", {
  doc <- read_html_fixture(fixture_path("species_index_page1.html"))
  out <- parse_species_index(doc)

  expect_s3_class(out, "tbl_df")
  expect_true(nrow(out) >= 10)
  expect_true(all(c("species", "slug", "url") %in% names(out)))
  expect_true(all(grepl("^https://www\\.sharkipedia\\.org/species/", out$url)))
})

test_that("parse_taxonomy returns expected fields", {
  doc <- read_html_fixture(fixture_path("carcharhinus_acronotus.html"))
  out <- parse_taxonomy(doc)

  expect_equal(out$species[[1]], "Carcharhinus acronotus")
  expect_equal(out$order[[1]], "Carcharhiniformes")
  expect_equal(out$family[[1]], "Carcharhinidae")
})

test_that("parse_traits_tables returns long trait rows", {
  doc <- read_html_fixture(fixture_path("carcharhinus_acronotus.html"))
  raw <- parse_traits_tables(doc)
  cleaned <- clean_traits(
    raw,
    species = "Carcharhinus acronotus",
    source_url = "https://www.sharkipedia.org/species/carcharhinus-acronotus",
    retrieved_at = as.POSIXct("2026-05-25", tz = "UTC")
  )
  validated <- validate_traits(cleaned)

  expect_gt(nrow(validated), 0)
  expect_true("Amat50" %in% validated$trait_name)
  expect_true(all(c("trait_group", "reference", "source_url") %in% names(validated)))
})

test_that("parse_trends_tables returns yearly observations", {
  doc <- read_html_fixture(fixture_path("carcharhinus_acronotus.html"))
  raw <- parse_trends_tables(doc)
  cleaned <- clean_trends(
    raw,
    species = "Carcharhinus acronotus",
    source_url = "https://www.sharkipedia.org/species/carcharhinus-acronotus",
    retrieved_at = as.POSIXct("2026-05-25", tz = "UTC")
  )
  validated <- validate_trends(cleaned)

  expect_gt(nrow(validated), 0)
  expect_type(validated$year, "integer")
  expect_type(validated$value, "double")
  expect_true(any(!is.na(validated$trend_id)))
})

test_that("parse_references deduplicates reference links", {
  doc <- read_html_fixture(fixture_path("carcharhinus_acronotus.html"))
  refs <- parse_references(doc)

  expect_gt(nrow(refs), 0)
  expect_true(all(c("reference_id", "reference_url") %in% names(refs)))
  expect_equal(anyDuplicated(refs$reference_id), 0L)
})
