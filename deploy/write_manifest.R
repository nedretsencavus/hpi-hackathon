# deploy/write_manifest.R ------------------------------------------------------
# OWNER: Member B. Run from the repository root AFTER data/hpi_clean.csv exists
# and the app runs locally:   Rscript deploy/write_manifest.R
#
# Posit Connect Cloud needs manifest.json (or renv.lock) next to app.R when
# publishing from GitHub. List the app files explicitly so dev/ (mock data)
# and data-raw/ (prep script + raw workbook) are NOT shipped or scanned.
# Re-run this whenever app code or package versions change, then commit.
# ------------------------------------------------------------------------------

stopifnot("Run Rscript data-raw/data_prep.R first" = file.exists("data/hpi_clean.csv"))

rsconnect::writeManifest(
  appDir        = ".",
  appFiles      = c("app.R", list.files("R", full.names = TRUE), "data/hpi_clean.csv")
)

m <- jsonlite::read_json("manifest.json")
message("manifest.json written. Files: ", paste(names(m$files), collapse = ", "))
message("Packages: ", length(m$packages))
