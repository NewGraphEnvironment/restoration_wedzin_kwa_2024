#!/usr/bin/env Rscript
#
# rag_build.R
#
# Build a ragnar DuckDB store from Zotero PDFs for literature search.
# Chunks PDFs, embeds via Ollama nomic-embed-text, indexes for BM25 + semantic search.
#
# Prerequisites:
#   - R packages: ragnar, DBI
#   - Ollama running with nomic-embed-text model pulled:
#       ollama serve   (if not already running)
#       ollama pull nomic-embed-text
#   - Zotero with PDFs attached to references
#
# Usage:
#   Rscript scripts/rag_build.R
#
# Output:
#   data/rag/vca_refs.duckdb   (gitignored)
#
# Relates to #123, cred#22, flooded#28
# Relates to NewGraphEnvironment/sred-2025-2026#14

library(ragnar)

# --- Configuration ---
zotero_dir <- path.expand("~/Zotero/storage")
store_path <- here::here("data", "rag", "vca_refs.duckdb")

# Zotero attachment keys for PDFs in our reference set.
# Found via:
#   sqlite3 "file:$HOME/Zotero/zotero.sqlite?mode=ro&immutable=1" "
#   SELECT idv2.value AS citationKey, ia.path, i2.key AS attachKey
#   FROM items i ... WHERE ia.contentType = 'application/pdf' ..."
#
# Map: citationKey -> attachKey (for traceability)
pdf_keys <- c(
  bair_etal2021       = "9PHQPE4I",
  beechie_etal2005    = "S6VURKKS",
  beechie_etal2010    = "RP6YYK4Q",
  cluer_thorne2014    = "5NXAZYJ2",
  fogel_etal2022      = "CDSVRG7N",
  hall_etal2007        = "W6LD4RRG",
  hauer_etal2016      = "S9FD5HRU",
  katz_etal2017       = "6K38RIEW",
  nagel_etal2014      = "TFBBPKGI",
  obrien_etal2019     = "DB2KINSQ",
  pollock_etal2014    = "UFWBXRJF",
  rapp_abbe2003       = "DCU5FHHU",
  rosenfeld_etal2008  = "VXSD95DA",
  sommer_etal2001     = "6L4KVSAK",
  wheaton_etal2019    = "SHK5CAFX"
)

# --- Find PDFs ---
pdf_paths <- character()
for (key in pdf_keys) {
  dir_path <- file.path(zotero_dir, key)
  if (dir.exists(dir_path)) {
    pdfs <- list.files(dir_path, pattern = "[.]pdf$", full.names = TRUE)
    if (length(pdfs) > 0) pdf_paths <- c(pdf_paths, pdfs[1])
  } else {
    message("  MISSING: ", names(pdf_keys)[pdf_keys == key], " (", key, ")")
  }
}

message("Found ", length(pdf_paths), " / ", length(pdf_keys), " PDFs")

# --- Build store ---
fs::dir_create(dirname(store_path))

# Remove stale store if exists
if (file.exists(store_path)) {
  file.remove(store_path)
  # Clean up any WAL/tmp files
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

# --- Verify ---
n_chunks <- DBI::dbGetQuery(store@con, "SELECT COUNT(*) AS n FROM chunks")$n
n_origins <- DBI::dbGetQuery(store@con, "SELECT COUNT(DISTINCT origin) AS n FROM chunks")$n

# Close cleanly
DBI::dbDisconnect(store@con)

message("\nStore built: ", store_path)
message("Chunks: ", n_chunks)
message("Sources: ", n_origins)
