#!/usr/bin/env Rscript
# Reliable pkgdown deploy to gh-pages (run from package root)
pkg_root <- normalizePath(".", winslash = "/")
setwd(pkg_root)

if (!requireNamespace("pkgdown", quietly = TRUE)) {
  install.packages("pkgdown", repos = "https://cloud.r-project.org")
}

if (file.exists("data-raw/build-vignette-data.R")) {
  suppressPackageStartupMessages(library(dplyr))
  source("data-raw/build-vignette-data.R")
}

message("Building site into docs/ ...")
pkgdown::build_site(pkg = pkg_root, preview = FALSE)

message("Deploying docs/ to gh-pages (no extra args) ...")
pkgdown::deploy_to_branch(
  pkg = pkg_root,
  commit_message = sprintf("pkgdown site update %s", format(Sys.time(), "%Y-%m-%d")),
  branch = "gh-pages"
)

message("Done. Enable GitHub Pages: branch gh-pages, folder / (root).")
message("Site: https://ecologistpablo.github.io/SharkipediaR/")
message("Articles: .../articles/sharkipediar.html")
