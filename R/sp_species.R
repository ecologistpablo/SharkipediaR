#' Retrieve Sharkipedia species metadata
#'
#' @param species Scientific name, species slug, or species URL.
#' @param cache If `TRUE`, use the in-session memoised cache.
#' @return A one-row tibble with taxonomy and provenance columns.
#' @export
#' @examples
#' \dontrun{
#' sp_species("Carcharhinus acronotus")
#' }
sp_species <- function(species, cache = TRUE) {
  url <- resolve_species_url(species)
  retrieved_at <- Sys.time()
  fetch_fun <- get_fetch_page(cache)
  doc <- fetch_fun(url)

  meta <- parse_taxonomy(doc)
  meta$source_url <- url
  meta$retrieved_at <- as.POSIXct(retrieved_at, tz = "UTC")
  meta
}
