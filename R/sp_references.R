#' Retrieve reference links for a Sharkipedia species
#'
#' @param species Scientific name, species slug, or species URL.
#' @param cache If `TRUE`, use the in-session memoised cache.
#' @return A tibble with `reference_id`, `reference_url`, `species`,
#'   `source_url`, and `retrieved_at`.
#' @export
#' @examples
#' \dontrun{
#' sp_references("Carcharhinus acronotus")
#' }
sp_references <- function(species, cache = TRUE) {
  url <- resolve_species_url(species)
  retrieved_at <- Sys.time()
  fetch_fun <- get_fetch_page(cache)
  doc <- fetch_fun(url)

  species_name <- rvest::html_text2(rvest::html_element(doc, "h1.title"))
  refs <- parse_references(doc)

  refs$species <- species_name
  refs$source_url <- url
  refs$retrieved_at <- as.POSIXct(retrieved_at, tz = "UTC")
  refs
}
