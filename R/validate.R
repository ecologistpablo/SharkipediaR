#' @keywords internal
validate_traits <- function(df) {
  required <- c(
    "species",
    "trait_name",
    "value",
    "source_url",
    "retrieved_at"
  )
  missing_cols <- setdiff(required, names(df))
  if (length(missing_cols)) {
    cli::cli_abort(c(
      "x" = "Trait data is missing required columns.",
      "i" = "Missing: {.field {missing_cols}}"
    ))
  }

  if (!nrow(df)) {
    cli::cli_warn(c(
      "!" = "No trait rows were parsed.",
      "i" = "The species page may have changed or contain no trait tables."
    ))
  }

  df
}

#' @keywords internal
validate_trends <- function(df) {
  required <- c(
    "species",
    "year",
    "value",
    "source_url",
    "retrieved_at"
  )
  missing_cols <- setdiff(required, names(df))
  if (length(missing_cols)) {
    cli::cli_abort(c(
      "x" = "Trend data is missing required columns.",
      "i" = "Missing: {.field {missing_cols}}"
    ))
  }

  if (!nrow(df)) {
    cli::cli_warn(c(
      "!" = "No trend observations were parsed.",
      "i" = "The species page may have changed or contain no embedded trend data."
    ))
  }

  df
}
