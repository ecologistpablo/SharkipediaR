#' Retrieve Sharkipedia population trend data
#'
#' Trend time series are embedded in server-rendered React props on species
#' pages and parsed into a long-format tibble.
#'
#' @param species Scientific name, species slug, species URL, or a character
#'   vector of any of the above.
#' @param cache If `TRUE`, use the in-session memoised cache.
#' @return A long-form tibble with `year`, `value`, location metadata, and
#'   provenance columns.
#' @export
#' @examples
#' \dontrun{
#' sp_trends("Carcharhinus acronotus")
#' }
sp_trends <- function(species, cache = TRUE) {
  species <- ensure_species_vector(species)

  if (length(species) == 1L) {
    return(fetch_species_trends(species[[1]], cache = cache))
  }

  purrr::map_dfr(
    species,
    function(sp) {
      fetch_species_trends(sp, cache = cache)
    },
    .id = "species_input"
  )
}

#' @keywords internal
fetch_species_trends <- function(species, cache = TRUE) {
  url <- resolve_species_url(species)
  retrieved_at <- Sys.time()
  fetch_fun <- get_fetch_page(cache)
  doc <- fetch_fun(url)

  species_name <- rvest::html_text2(rvest::html_element(doc, "h1.title"))
  raw <- parse_trends_tables(doc)
  cleaned <- clean_trends(
    raw,
    species = species_name,
    source_url = url,
    retrieved_at = retrieved_at
  )
  validate_trends(cleaned)
}
