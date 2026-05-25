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
