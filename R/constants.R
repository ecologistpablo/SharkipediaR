#' @keywords internal
.sharkipedia_env <- new.env(parent = emptyenv())

#' @keywords internal
sharkipedia_base_url <- function() {
  "https://www.sharkipedia.org"
}

#' @keywords internal
sharkipedia_user_agent <- function() {
  version <- as.character(utils::packageVersion("sharkipediaR"))
  paste0(
    "sharkipediaR/", version,
    " (https://github.com/ecologistpablo/SharkipediaR; ecological research)"
  )
}
