#!/usr/bin/env Rscript
#
# rag_build_coho.R
#
# Build a ragnar DuckDB store from Skeena/Bulkley coho PDFs for literature search.
# Companion to rag_build.R (VCA parameter verification); this one targets the
# coho fisheries narrative used in 0050-executive-summary.Rmd and 0200-background.Rmd.
#
# Sources:
#   3 existing Zotero group-library items (Sharpe 2019, Sheffield n.d., Lough 1971)
#   5 recently-added DFO + PSF reports (Coho Response Team 1998, Skeena ISRP 2008,
#     Korman & English 2013 benchmarks, English 2013 time-series, Porter et al. 2014
#     habitat cards)
#
# Prerequisites:
#   - ragnar + Ollama (nomic-embed-text model pulled)
#
# Output:
#   data/rag/coho_refs.duckdb   (gitignored via data/rag/)
#
# Relates to fisheries-precision-neexdzii branch, NewGraphEnvironment/sred-2025-2026#14

library(ragnar)

zotero_dir <- path.expand("~/Zotero/storage")
store_path <- here::here("data", "rag", "coho_refs.duckdb")

# Citation-key stub -> Zotero attachment key (for items already synced locally).
# New uploads hit S3 directly via the Web API, and may or may not have synced
# back into the local Zotero storage folder yet — if a key is missing below,
# the script falls back to the /tmp/coho_pdfs path where the original downloads live.
zotero_pdfs <- c(
  sharpe2019_bulkley_morice     = "QQCZMA2X",
  sheffield_coho_rearing        = "FNAK5DN7",
  lough1971_moricetown_coho     = "CKSCTGKS",
  cohoResponseTeam1998          = "EMG7FMPR",
  walters_etal2008_skeena_isrp  = "UFWD3QHV",
  korman_english2013_benchmark  = "M576UMMU",
  english2013_timeseries        = "REX54D2I",
  porter_etal2014_habitat_cards = "B2CG8AE7"
)

fallback_pdfs <- c(
  cohoResponseTeam1998          = "/tmp/coho_pdfs/dfo_coho_response_team_1998.pdf",
  walters_etal2008_skeena_isrp  = "/tmp/coho_pdfs/dfo_skeena_isrp.pdf",
  korman_english2013_benchmark  = "/tmp/coho_pdfs/psf_benchmark_analysis_2021.pdf",
  english2013_timeseries        = "/tmp/coho_pdfs/psf_extended_timeseries_2021.pdf",
  porter_etal2014_habitat_cards = "/tmp/coho_pdfs/psf_habitat_report_cards_2021.pdf"
)

resolve_pdf <- function(key, attach_key) {
  dir_path <- file.path(zotero_dir, attach_key)
  if (dir.exists(dir_path)) {
    pdfs <- list.files(dir_path, pattern = "[.]pdf$", full.names = TRUE)
    if (length(pdfs) > 0) return(pdfs[1])
  }
  fallback <- fallback_pdfs[key]
  if (!is.na(fallback) && file.exists(fallback)) return(fallback)
  NA_character_
}

pdf_paths <- vapply(
  names(zotero_pdfs),
  function(k) resolve_pdf(k, zotero_pdfs[[k]]),
  character(1)
)

missing <- is.na(pdf_paths)
if (any(missing)) {
  message("MISSING PDFs: ", paste(names(zotero_pdfs)[missing], collapse = ", "))
}
pdf_paths <- pdf_paths[!missing]
message("Found ", length(pdf_paths), " / ", length(zotero_pdfs), " PDFs")

fs::dir_create(dirname(store_path))
if (file.exists(store_path)) {
  file.remove(store_path)
  wal <- paste0(store_path, ".wal")
  if (file.exists(wal)) file.remove(wal)
}

store <- ragnar_store_create(
  location = store_path,
  embed = embed_ollama(model = "nomic-embed-text"),
  overwrite = TRUE
)

message("Ingesting ", length(pdf_paths), " PDFs into ", store_path)
ragnar_store_ingest(store, pdf_paths, progress = TRUE)

n_chunks <- DBI::dbGetQuery(store@con, "SELECT COUNT(*) AS n FROM chunks")$n
n_origins <- DBI::dbGetQuery(store@con, "SELECT COUNT(DISTINCT origin) AS n FROM chunks")$n
DBI::dbDisconnect(store@con)

message("\nStore built: ", store_path)
message("Chunks: ", n_chunks)
message("Sources: ", n_origins)
