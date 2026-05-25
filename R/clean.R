#' @keywords internal
standardize_trait_columns <- function(df) {
  lookup <- c(
    Name = "trait_name",
    Value = "value",
    Standard = "standard",
    ValueType = "value_type",
    Sex = "sex",
    Location = "location",
    Reference = "reference"
  )

  present <- intersect(names(df), names(lookup))
  if (!length(present)) {
    return(df)
  }

  rename_map <- lookup[present]
  names(df)[match(present, names(df))] <- unname(rename_map)
  df
}

#' Clean parsed trait tables
#' @keywords internal
clean_traits <- function(df, species, source_url, retrieved_at = Sys.time()) {
  if (!nrow(df)) {
    return(
      tibble::tibble(
        species = character(),
        trait_group = character(),
        trait_name = character(),
        value = character(),
        standard = character(),
        value_type = character(),
        sex = character(),
        location = character(),
        reference = character(),
        source_url = character(),
        retrieved_at = as.POSIXct(character())
      )
    )
  }

  df <- standardize_trait_columns(df)

  if ("trait_name" %in% names(df)) {
    df$trait_name <- stringr::str_squish(df$trait_name)
  }
  if ("reference" %in% names(df)) {
    df$reference <- stringr::str_squish(df$reference)
    df$reference <- sub("^/references/", "", df$reference)
  }

  dplyr::mutate(
    df,
    species = species,
    source_url = source_url,
    retrieved_at = as.POSIXct(retrieved_at, tz = "UTC"),
    dplyr::across(
      c(
        trait_group,
        trait_name,
        value,
        standard,
        value_type,
        sex,
        location,
        reference
      ),
      ~ {
        x <- stringr::str_squish(as.character(.x))
        dplyr::na_if(x, "")
      }
    )
  )
}

#' Clean parsed trend observations
#' @keywords internal
clean_trends <- function(df, species, source_url, retrieved_at = Sys.time()) {
  if (!nrow(df)) {
    return(
      tibble::tibble(
        species = character(),
        location = character(),
        unit = character(),
        reference = character(),
        trend_id = character(),
        trend_url = character(),
        year = integer(),
        value = double(),
        source_url = character(),
        retrieved_at = as.POSIXct(character())
      )
    )
  }

  dplyr::mutate(
    df,
    species = species,
    source_url = source_url,
    retrieved_at = as.POSIXct(retrieved_at, tz = "UTC"),
    year = as.integer(year),
    dplyr::across(
      c(location, unit, reference, trend_id, trend_url),
      ~ dplyr::na_if(stringr::str_squish(as.character(.x)), "")
    )
  )
}
