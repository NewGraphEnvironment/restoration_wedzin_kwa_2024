# install.packages('pak')

pkgs_cran <- c(
  'tidyverse',
  'knitr',
  'bookdown',
  'rmarkdown',
  'pagedown',
  'RPostgres',
  'sf',
  'fasstr',
  'tidyhydat',
  'ggdark',
  'fishbc',
  'DT',
  'desc',
  'kableExtra',
  "rstac",
  "leaflet",
  "leafem"
)

pkgs_gh <- c(
  "trafficonese/leaflet.extras",
  "newgraphenvironment/fly",
  "newgraphenvironment/fresh",
  "newgraphenvironment/flooded",
  "newgraphenvironment/fpr",
  "newgraphenvironment/fishbc@updated_data",
  "poissonconsulting/readwritesqlite",
  "paleolimbot/rbbt"
)

pkgs_all <- c(pkgs_cran,
              pkgs_gh)


# install or upgrade all the packages with pak
if(params$update_packages){
  lapply(pkgs_all,
         pak::pkg_install,
         ask = FALSE)
}

# load all the packages
pkgs_ld <- c(pkgs_cran,
             sub("@.*", "", basename(pkgs_gh)))

lapply(pkgs_ld,
       require,
       character.only = TRUE)
