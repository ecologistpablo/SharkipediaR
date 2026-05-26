# Rebuild inst/extdata/reid2011_nsw_trends.rds and white_shark_all_trends.rds
# Requires network. Run: Rscript data-raw/build-ecological-examples.R

suppressPackageStartupMessages({
  library(dplyr)
  library(purrr)
  library(pkgload)
})
pkgload::load_all(".")

species_reid <- c(
  "Carcharias taurus",
  "Carcharodon carcharias",
  "Galeocerdo cuvier",
  "Heterodontus portusjacksoni",
  "Notorynchus cepedianus",
  "Sphyrna zygaena",
  "Squatina australis"
)

message("Fetching trends (this takes ~30s) ...")
trends <- map_dfr(species_reid, function(sp) {
  rate_limit_pause()
  sp_trends(sp, cache = FALSE)
})

reid <- trends %>% filter(reference == "reid2011")
white <- sp_trends("Carcharodon carcharias", cache = FALSE)

out_dir <- "inst/extdata"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
saveRDS(reid, file.path(out_dir, "reid2011_nsw_trends.rds"))
saveRDS(white, file.path(out_dir, "white_shark_all_trends.rds"))
message("Wrote reid2011_nsw_trends.rds (", nrow(reid), " rows)")
message("Wrote white_shark_all_trends.rds (", nrow(white), " rows)")
