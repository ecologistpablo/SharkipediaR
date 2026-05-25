#' @keywords internal
rate_limit_pause <- function(min_gap = 0.5) {
  last <- .sharkipedia_env$last_request
  if (!is.null(last)) {
    elapsed <- as.numeric(difftime(Sys.time(), last, units = "secs"))
    if (elapsed < min_gap) {
      Sys.sleep(min_gap - elapsed + stats::runif(1, 0, 0.3))
    }
  }
  .sharkipedia_env$last_request <- Sys.time()
  invisible(NULL)
}

#' @keywords internal
species_name_to_slug <- function(name) {
  name <- stringr::str_squish(name)
  tolower(gsub("[[:space:]]+", "-", name, perl = TRUE))
}

#' @keywords internal
species_name_to_url <- function(name) {
  paste0(sharkipedia_base_url(), "/species/", species_name_to_slug(name))
}

#' @keywords internal
normalize_sharkipedia_url <- function(url) {
  if (!grepl("^https?://", url)) {
    if (grepl("^/species/", url)) {
      url <- paste0(sharkipedia_base_url(), url)
    } else {
      url <- species_name_to_url(url)
    }
  }
  url
}

#' @keywords internal
resolve_species_url <- function(x) {
  if (length(x) != 1L) {
    cli::cli_abort("{.arg species} must be length 1.")
  }
  if (grepl("^https?://", x) && grepl("/species/", x)) {
    return(normalize_sharkipedia_url(x))
  }
  species_name_to_url(x)
}

#' @keywords internal
ensure_species_vector <- function(x) {
  if (is.null(x) || !length(x)) {
    cli::cli_abort("{.arg species} must be a non-empty character vector.")
  }
  unique(stringr::str_squish(as.character(x)))
}

#' @keywords internal
read_html_fixture <- function(path) {
  xml2::read_html(path, encoding = "UTF-8")
}

#' @keywords internal
get_fetch_page <- function(cache = TRUE) {
  if (isTRUE(cache)) {
    return(fetch_page_memoised)
  }
  fetch_page
}
