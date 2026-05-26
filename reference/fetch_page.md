# Fetch a Sharkipedia HTML page

Low-level retrieval layer. Handles rate limiting, retries, and a
responsible user agent. Parsing is handled separately.

## Usage

``` r
fetch_page(url, quiet = TRUE)
```

## Arguments

- url:

  Character URL, species slug, or scientific name.

- quiet:

  If `FALSE`, reports successful retrieval.

## Value

An `xml_document` from **xml2**.
