#' Search Sharkipedia species names
#'
#' Matches partial scientific names against the species index. By default this
#' uses a cached index request; set `index` to a pre-built index from
#' [sp_species_urls()] to avoid repeated downloads.
#'
#' @param query Character vector of search terms (case-insensitive).
#' @param index Optional species index tibble from [sp_species_urls()]. For
#'   comprehensive matching, build the index once with
#'   `sp_species_urls(all_pages = TRUE)` and pass it here.
#' @param all_pages If `index` is `NULL`, whether to scan all index pages.
#' @param cache Passed to [sp_species_urls()] when `index` is `NULL`.
#' @return A tibble of matching species with `species`, `slug`, and `url`.
#' @export
#' @examples
#' \dontrun{
#' sp_search("Carcharhinus")
#' }
sp_search <- function(query, index = NULL, all_pages = FALSE, cache = TRUE) {
  query <- ensure_species_vector(query)

  if (is.null(index)) {
    index <- sp_species_urls(all_pages = all_pages, cache = cache)
  }

  patterns <- tolower(query)
  matches <- purrr::map(
    patterns,
    function(pattern) {
      index %>%
        dplyr::filter(
          grepl(pattern, tolower(.data$species), fixed = TRUE) |
            grepl(pattern, tolower(.data$slug), fixed = TRUE)
        )
    }
  )

  dplyr::bind_rows(matches) %>%
    dplyr::distinct(.data$url, .keep_all = TRUE)
}
