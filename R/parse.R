#' @keywords internal
link_text_or_href <- function(node) {
  txt <- rvest::html_text2(node)
  if (nzchar(txt)) {
    return(stringr::str_squish(txt))
  }
  href <- rvest::html_attr(node, "href")
  if (is.na(href)) {
    return(NA_character_)
  }
  stringr::str_squish(basename(href))
}

#' Parse species links from an index page
#' @param doc `xml_document` from a `/species` index page.
#' @return Tibble with `species`, `slug`, and `url`.
#' @keywords internal
parse_species_index <- function(doc) {
  nodes <- rvest::html_elements(doc, "a[href^='/species/']")
  if (!length(nodes)) {
    return(
      tibble::tibble(
        species = character(),
        slug = character(),
        url = character()
      )
    )
  }

  href <- rvest::html_attr(nodes, "href")
  text <- rvest::html_text2(nodes)

  tibble::tibble(
    species = text,
    slug = sub("^/species/", "", href),
    url = paste0(sharkipedia_base_url(), href)
  ) %>%
    dplyr::filter(!grepl("\\.csv$", .data$slug)) %>%
    dplyr::distinct(.data$url, .keep_all = TRUE)
}

#' @keywords internal
parse_index_last_page <- function(doc) {
  links <- rvest::html_elements(doc, ".pagination-link")
  if (!length(links)) {
    return(1L)
  }
  pages <- suppressWarnings(as.integer(rvest::html_text2(links)))
  pages <- pages[!is.na(pages)]
  if (!length(pages)) {
    return(1L)
  }
  max(pages, na.rm = TRUE)
}

#' Parse taxonomy metadata from a species page
#' @keywords internal
parse_taxonomy <- function(doc) {
  species <- rvest::html_text2(rvest::html_element(doc, "h1.title"))

  tax_ps <- rvest::html_elements(
    doc,
    "div.columns > div.column:first-child > p"
  )
  tax_text <- rvest::html_text2(tax_ps)

  extract_field <- function(label) {
    match <- tax_text[startsWith(tax_text, paste0(label, ":"))]
    if (!length(match)) {
      return(NA_character_)
    }
    sub(paste0("^", label, ":\\s*"), "", match[[1]])
  }

  tibble::tibble(
    species = species,
    superorder = extract_field("Superorder"),
    subclass = extract_field("Subclass"),
    order = extract_field("Order"),
    family = extract_field("Family")
  )
}

#' @keywords internal
trait_table_headers <- function(table_node) {
  rvest::html_text2(rvest::html_elements(table_node, "thead th"))
}

#' @keywords internal
is_trait_table <- function(table_node) {
  "Name" %in% trait_table_headers(table_node)
}

#' @keywords internal
preceding_trait_group <- function(table_node) {
  h4 <- xml2::xml_find_first(
    table_node,
    "preceding::h4[contains(@class, 'subtitle')][1]"
  )
  if (length(h4) == 0L || is.na(h4)) {
    return(NA_character_)
  }
  stringr::str_squish(xml2::xml_text(h4))
}

#' Parse trait tables from a species page
#' @keywords internal
parse_traits_tables <- function(doc) {
  tables <- rvest::html_elements(doc, "table.table")
  if (!length(tables)) {
    return(tibble::tibble())
  }

  parsed <- purrr::map(
    tables,
    function(tbl) {
      if (!is_trait_table(tbl)) {
        return(NULL)
      }

      df <- rvest::html_table(tbl, convert = FALSE, fill = TRUE)
      if (!nrow(df)) {
        return(NULL)
      }

      df$trait_group <- preceding_trait_group(tbl)
      df
    }
  )

  parsed <- purrr::compact(parsed)
  if (!length(parsed)) {
    return(tibble::tibble())
  }

  dplyr::bind_rows(parsed)
}

#' @keywords internal
decode_react_props <- function(props) {
  if (is.na(props) || !nzchar(props)) {
    return(NULL)
  }
  props <- gsub("&quot;", "\"", props, fixed = TRUE)
  props <- gsub("&#39;", "'", props, fixed = TRUE)
  jsonlite::fromJSON(props, simplifyVector = TRUE)
}

#' Parse trend rows embedded in React props
#' @keywords internal
parse_trends_tables <- function(doc) {
  trend_table <- xml2::xml_find_first(
    doc,
    "//h3[contains(normalize-space(.), 'Trends')]/following::table[1]"
  )

  if (length(trend_table) == 0L || is.na(trend_table)) {
    return(tibble::tibble())
  }

  rows <- xml2::xml_find_all(trend_table, ".//tbody/tr")
  if (!length(rows)) {
    return(tibble::tibble())
  }

  purrr::map_dfr(rows, function(row) {
    location <- xml2::xml_text(xml2::xml_find_first(row, "./td[1]"))
    unit <- xml2::xml_text(xml2::xml_find_first(row, "./td[3]"))

    ref_node <- xml2::xml_find_first(row, "./td[4]//a")
    reference <- NA_character_
    if (length(ref_node) && !is.na(ref_node)) {
      reference <- stringr::str_squish(xml2::xml_text(ref_node))
      href <- xml2::xml_attr(ref_node, "href")
      if (!nzchar(reference) && !is.na(href)) {
        reference <- sub("^/references/", "", href)
      }
    }

    details_node <- xml2::xml_find_first(row, ".//a[contains(@href, '/trends/')]")
    trend_url <- if (length(details_node) && !is.na(details_node)) {
      paste0(sharkipedia_base_url(), xml2::xml_attr(details_node, "href"))
    } else {
      NA_character_
    }
    trend_id <- if (!is.na(trend_url)) {
      sub(".*/trends/", "", trend_url)
    } else {
      NA_character_
    }

    chart <- xml2::xml_find_first(row, ".//div[@data-react-props]")
    props <- if (length(chart) && !is.na(chart)) {
      xml2::xml_attr(chart, "data-react-props")
    } else {
      NA_character_
    }

    payload <- decode_react_props(props)
    if (is.null(payload) || is.null(payload$observations)) {
      return(tibble::tibble())
    }

    obs <- payload$observations
    if (is.matrix(obs)) {
      years <- as.character(obs[, 1])
      values <- suppressWarnings(as.numeric(obs[, 2]))
    } else {
      years <- as.character(obs[[1]])
      values <- suppressWarnings(as.numeric(obs[[2]]))
    }

    tibble::tibble(
      location = stringr::str_squish(location),
      unit = stringr::str_squish(unit),
      reference = reference,
      trend_id = trend_id,
      trend_url = trend_url,
      year = years,
      value = values
    )
  })
}

#' Parse bibliographic references listed on a species page
#' @keywords internal
parse_references <- function(doc) {
  refs <- unique(c(
    rvest::html_attr(
      rvest::html_elements(doc, "table.table a[href^='/references/']"),
      "href"
    ),
    rvest::html_attr(
      rvest::html_elements(doc, "table.is-fullwidth a[href^='/references/']"),
      "href"
    )
  ))

  refs <- refs[!is.na(refs)]
  if (!length(refs)) {
    return(
      tibble::tibble(
        reference_id = character(),
        reference_url = character()
      )
    )
  }

  tibble::tibble(
    reference_id = sub("^/references/", "", refs),
    reference_url = paste0(sharkipedia_base_url(), refs)
  ) %>%
    dplyr::distinct()
}
