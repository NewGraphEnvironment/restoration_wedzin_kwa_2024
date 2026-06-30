# ensure a CRAN mirror is set (a bare Rscript has repos = "@CRAN@", which breaks
# available.packages() / install.packages() below)
if (identical(getOption("repos")[["CRAN"]], "@CRAN@") ||
      is.null(getOption("repos")[["CRAN"]])) {
  options(repos = c(CRAN = "https://cloud.r-project.org"))
}

# ensure pak is installed and up to date from CRAN (no popup)
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
} else {
  current <- packageVersion("pak")
  latest  <- package_version(available.packages()["pak", "Version"])
  if (current < latest) pak::pak("pak")
}

pkgs_cran <- c(
  'tidyverse',          # dplyr/ggplot2/tidyr/stringr/readr/purrr/tibble/lubridate/readxl/glue/cli/scales
  'knitr', 'bookdown', 'rmarkdown', 'pagedown',
  'sf', 'terra', 'stars', 'tmap', 'maptiles',   # spatial + mapping
  'DT', 'kableExtra',
  'leaflet',
  'here', 'fs', 'chk', 'janitor',               # utilities
  'fasstr', 'tidyhydat',                        # hydrology
  'RColorBrewer',                               # plotting
  'rstac',
  'ckanr',                                      # SKT API
  'desc',
  'RPostgres',
  'devtools'                                    # session info
)

pkgs_gh <- c(
  "newgraphenvironment/fresh",
  "newgraphenvironment/flooded",          # floodplain pipeline
  "newgraphenvironment/drift",            # LULC appendix
  "newgraphenvironment/link",             # network pipeline
  "newgraphenvironment/ngr",              # COG viewer / utils
  "newgraphenvironment/fwapgr",
  "newgraphenvironment/xciter",           # citations
  "newgraphenvironment/fpr",
  "newgraphenvironment/staticimports",    # run.R staticimports::import()
  "newgraphenvironment/fishbc@updated_data",
  "trafficonese/leaflet.extras",
  "nsgrantham/ggdark",                    # dark ggplot theme (archived from CRAN)
  "poissonconsulting/poisutils",
  "paleolimbot/rbbt"
)

pkgs_all <- c(pkgs_cran, pkgs_gh)


# install or upgrade all the packages with pak
# guarded so this file is safe to source standalone (no params object)
if (exists("params") && isTRUE(params$update_packages)) {
  lapply(pkgs_all,
         pak::pkg_install,
         ask = FALSE)
}

# load all the packages (strip @branch before basename - see fish_passage #150)
pkgs_ld <- c(pkgs_cran,
             basename(pkgs_gh) |> stringr::str_remove("@.*"))

lapply(pkgs_ld,
       require,
       character.only = TRUE)
