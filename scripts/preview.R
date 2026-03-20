# Setup for chapter previews
# Wraps bookdown::preview_chapter() so individual chapters render without
# a full book build.
#
# Usage (from R console or Rscript):
#   source('scripts/setup.R')
#   preview("0050-executive-summary.Rmd")

preview <- function(chapter, output_dir = "docs") {
  # Use a dedicated environment so params can be set for packages.R
  # then removed before knitting (bookdown injects its own from YAML)
  e <- new.env(parent = globalenv())

  e$params <- list(
    repo_url = 'https://github.com/NewGraphEnvironment/restoration_wedzin_kwa_2024/',
    report_url = 'https://newgraphenvironment.github.io/restoration_wedzin_kwa_2024',
    update_bib = FALSE,
    update_packages = FALSE,
    update_gis = FALSE
  )

  source('scripts/packages.R', local = e)
  source('scripts/staticimports.R', local = e)
  source('scripts/functions.R', local = e)
  source('scripts/tables.R', local = e)

  e$gitbook_on <- TRUE
  e$photo_width <- "100%"
  e$font_set <- 11
  e$gis_update <- FALSE

  # Remove params so bookdown can inject from YAML without conflict
  rm("params", envir = e)

  bookdown::preview_chapter(
    chapter,
    output_dir = output_dir,
    envir = e
  )
}
