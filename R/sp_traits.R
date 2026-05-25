#' Retrieve Sharkipedia trait data
#'
#' @param species Scientific name, species slug, species URL, or a character
#'   vector of any of the above.
#' @param cache If `TRUE`, use the in-session memoised cache.
#' @return A long-form tibble of trait observations with provenance columns.
#' @export
#' @examples
#' \dontrun{
#' library(dplyr)
#' traits <- sp_traits("Aetobatus narinari")
#' traits %>%
#'   filter(trait_name == "Linf") %>%
#'   summarise(mean_linf = mean(as.numeric(value), na.rm = TRUE))
#' }
sp_traits <- function(species, cache = TRUE) {
  species <- ensure_species_vector(species)

  if (length(species) == 1L) {
    return(fetch_species_traits(species[[1]], cache = cache))
  }

  purrr::map_dfr(
    species,
    function(sp) {
      fetch_species_traits(sp, cache = cache)
    },
    .id = "species_input"
  )
}

#' @keywords internal
fetch_species_traits <- function(species, cache = TRUE) {
  url <- resolve_species_url(species)
  retrieved_at <- Sys.time()
  fetch_fun <- get_fetch_page(cache)
  doc <- fetch_fun(url)

  species_name <- rvest::html_text2(rvest::html_element(doc, "h1.title"))
  raw <- parse_traits_tables(doc)
  cleaned <- clean_traits(
    raw,
    species = species_name,
    source_url = url,
    retrieved_at = retrieved_at
  )
  validate_traits(cleaned)
}
