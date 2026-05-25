#' Retrieve Sharkipedia species URLs
#'
#' Scrapes the public species index and returns a deduplicated tibble of
#' species names and URLs. Requests are rate-limited and cached by default.
#'
#' @param all_pages If `TRUE`, retrieve all paginated index pages. Defaults to
#'   the first page only to remain polite.
#' @param max_pages Optional cap on pages retrieved when `all_pages = TRUE`.
#' @param cache If `TRUE`, use the in-session memoised cache.
#' @return A tibble with columns `species`, `slug`, and `url`.
#' @export
#' @examples
#' \dontrun{
#' sp_species_urls()
#' sp_species_urls(all_pages = TRUE, max_pages = 2)
#' }
sp_species_urls <- function(all_pages = FALSE, max_pages = NULL, cache = TRUE) {
  fetch_fun <- get_fetch_page(cache)
  last_page <- 1L

  if (isTRUE(all_pages)) {
    first_url <- paste0(sharkipedia_base_url(), "/species?all=true&page=1")
    first_doc <- fetch_fun(first_url)
    last_page <- parse_index_last_page(first_doc)
    if (!is.null(max_pages)) {
      last_page <- min(last_page, as.integer(max_pages))
    }
  }

  pages <- seq_len(last_page)
  results <- purrr::map(
    pages,
    function(page) {
      query <- if (isTRUE(all_pages) || page > 1L) {
        paste0("?all=true&page=", page)
      } else {
        "?all=true&page=1"
      }
      url <- paste0(sharkipedia_base_url(), "/species", query)
      doc <- fetch_fun(url)
      parse_species_index(doc)
    }
  )

  dplyr::bind_rows(results) %>%
    dplyr::distinct(.data$url, .keep_all = TRUE)
}
