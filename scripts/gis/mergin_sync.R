#!/usr/bin/env Rscript
#
# mergin_sync.R
#
# Sync the shared collaborative GIS project `newgraph/restoration_wedzin_kwa`
# (Mergin Maps) to/from a local working copy. This is the project's single
# shared spatial environment: we PULL it locally, run the analysis pipeline,
# burn the results back into it (the `update_gis = TRUE` copy step in
# scripts/floodplain_lcc/0*.R writes aquatic_network.gpkg, floodplain.gpkg,
# floodplain_landcover.gpkg, subbasins.gpkg into the project), then PUSH so the
# whole team can use the updated layers on desktop QGIS and in the field.
#
# Public-safe by design: drives the `mergin` CLI directly via system2() with
# auth from environment variables -- no private package dependencies.
#
# Auth (environment variables, e.g. in ~/.Renviron):
#   MERGIN_USERNAME, MERGIN_PASSWORD   (or MERGIN_AUTH token)
#   MERGIN_URL                         (optional; default https://app.merginmaps.com)
#
# Install the CLI once with: pip install mergin-client   (provides `mergin`)
#
# Usage:
#   Rscript scripts/gis/mergin_sync.R status   # show pending local/server changes
#   Rscript scripts/gis/mergin_sync.R pull     # download (first time) or pull updates
#   Rscript scripts/gis/mergin_sync.R push     # upload local changes (e.g. burned results)

# --- Config ---------------------------------------------------------------
mergin_project <- "newgraph/restoration_wedzin_kwa"          # workspace/project on the server
local_dir      <- rmarkdown::yaml_front_matter(
  here::here("index.Rmd"))$params$path_gis                   # ~/Projects/gis/restoration_wedzin_kwa
local_dir      <- path.expand(local_dir)

# Resolve the mergin binary (R's PATH may omit ~/.local/bin)
mergin_bin <- Sys.which("mergin")
if (!nzchar(mergin_bin)) mergin_bin <- path.expand("~/.local/bin/mergin")
if (!file.exists(mergin_bin)) {
  stop("mergin CLI not found. Install with: pip install mergin-client", call. = FALSE)
}

# Global CLI args: server URL if set (auth itself is read from MERGIN_* env vars)
global_args <- character(0)
if (nzchar(Sys.getenv("MERGIN_URL"))) {
  global_args <- c("--url", Sys.getenv("MERGIN_URL"))
}

action <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(action)) action <- "status"

run_mergin <- function(args, wd = NULL) {
  # mergin pull/push/status operate on the project in the working directory, so
  # cd into `wd` for those (download/clone take the path as an argument instead).
  if (!is.null(wd)) {
    old <- setwd(wd)
    on.exit(setwd(old), add = TRUE)
  }
  message("mergin ", paste(args, collapse = " "))
  status <- system2(mergin_bin, args = c(global_args, args), wait = TRUE)
  if (!identical(as.integer(status), 0L)) {
    stop("mergin command failed (exit ", status, ")", call. = FALSE)
  }
  invisible(status)
}

is_local_project <- dir.exists(file.path(local_dir, ".mergin"))

if (action == "pull") {
  if (is_local_project) {
    # Existing local copy -> fetch server changes
    run_mergin(c("pull"), wd = local_dir)
  } else {
    # First time -> download the whole project into local_dir. Run the CLI from
    # local_dir's parent (NOT the report repo) so mergin's client-log.txt/.cache
    # land outside version control. `download` takes local_dir as an absolute
    # path arg, so cwd only governs where the stray log is written.
    message("No local copy at ", local_dir, " -- downloading project (large, one-time)...")
    parent_dir <- dirname(local_dir)
    dir.create(parent_dir, recursive = TRUE, showWarnings = FALSE)
    run_mergin(c("download", mergin_project, local_dir), wd = parent_dir)
  }
  message("Pull complete: ", local_dir)

} else if (action == "push") {
  if (!is_local_project) {
    stop("No local Mergin project at ", local_dir, " -- run `pull` first.", call. = FALSE)
  }
  run_mergin(c("push"), wd = local_dir)
  message("Push complete -> ", mergin_project)

} else if (action == "status") {
  if (!is_local_project) {
    message("No local copy at ", local_dir, " (run `pull` to download).")
  } else {
    run_mergin(c("status"), wd = local_dir)
  }

} else {
  stop("Unknown action '", action, "'. Use one of: status, pull, push.", call. = FALSE)
}
