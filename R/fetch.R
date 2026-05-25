#' Fetch a Sharkipedia HTML page
#'
#' Low-level retrieval layer. Handles rate limiting, retries, and a
#' responsible user agent. Parsing is handled separately.
#'
#' @param url Character URL, species slug, or scientific name.
#' @param quiet If `FALSE`, reports successful retrieval.
#' @return An `xml_document` from **xml2**.
#' @export
fetch_page <- function(url, quiet = TRUE) {
  url <- normalize_sharkipedia_url(url)
  rate_limit_pause()

  req <- httr2::request(url) %>%
    httr2::req_user_agent(sharkipedia_user_agent()) %>%
    httr2::req_retry(max_tries = 3, max_seconds = 60) %>%
    httr2::req_error(is_error = function(resp) FALSE)

  resp <- httr2::req_perform(req)
  status <- httr2::resp_status(resp)

  if (status >= 400L) {
    cli::cli_abort(c(
      "x" = "HTTP {status} when requesting {.url {url}}.",
      "i" = "The page may be missing or Sharkipedia may be unavailable."
    ))
  }

  if (!quiet) {
    cli::cli_inform("Retrieved {.url {url}}.")
  }

  httr2::resp_body_html(resp)
}

#' @keywords internal
fetch_page_memoised <- memoise::memoise(fetch_page)
