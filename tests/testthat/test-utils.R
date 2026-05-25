test_that("species_name_to_url builds canonical slugs", {
  expect_equal(
    species_name_to_url("Carcharhinus acronotus"),
    "https://www.sharkipedia.org/species/carcharhinus-acronotus"
  )
})

test_that("resolve_species_url accepts full URLs", {
  expect_equal(
    resolve_species_url("https://www.sharkipedia.org/species/carcharhinus-acronotus"),
    "https://www.sharkipedia.org/species/carcharhinus-acronotus"
  )
})
