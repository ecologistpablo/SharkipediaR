#' Example Sharkipedia data for *Carcharhinus acronotus*
#'
#' Returns cached trait, trend, taxonomy, and reference tables parsed from a
#' real Sharkipedia species page. Used in vignettes and examples so
#' documentation can be built without live HTTP requests.
#'
#' @return A list with elements `species_meta`, `traits`, `trends`,
#'   `references`, and `species_index` (all tibbles).
#' @export
#' @examples
#' ex <- example_carcharhinus()
#' nrow(ex$traits)
#' nrow(ex$trends)
example_carcharhinus <- function() {
  path <- system.file("extdata", "carcharhinus_acronotus.rds", package = "sharkipediaR")
  if (!nzchar(path)) {
    cli::cli_abort(c(
      "x" = "Example data file not found.",
      "i" = "Run {.code data-raw/build-vignette-data.R} before building the package."
    ))
  }
  readRDS(path)
}

#' NSW Shark Meshing trends from Reid et al. (2011)
#'
#' Cached output of [sp_trends()] for species linked to reference
#' `reid2011` on [Sharkipedia](https://www.sharkipedia.org/references/reid2011).
#' Used in the ecological workflows vignette.
#'
#' @return A tibble of trend observations (year, value, species, location, …).
#' @export
example_reid2011_trends <- function() {
  path <- system.file("extdata", "reid2011_nsw_trends.rds", package = "sharkipediaR")
  if (!nzchar(path)) {
    cli::cli_abort("Example file reid2011_nsw_trends.rds not found.")
  }
  readRDS(path)
}

#' All cached trend series for white shark (*Carcharodon carcharias*)
#'
#' @return A tibble of trend observations from multiple populations.
#' @export
example_white_shark_trends <- function() {
  path <- system.file("extdata", "white_shark_all_trends.rds", package = "sharkipediaR")
  if (!nzchar(path)) {
    cli::cli_abort("Example file white_shark_all_trends.rds not found.")
  }
  readRDS(path)
}
