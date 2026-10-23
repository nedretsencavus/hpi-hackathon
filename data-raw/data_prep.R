# data-raw/data_prep.R ---------------------------------------------------------
# OWNER: Member A (Data). Run once, locally, from the repository root:
#   Rscript data-raw/data_prep.R
# Output: data/hpi_clean.csv (the ONLY file app.R reads).
#
# Sources (cite in app, README and website)
# 1. Happy Planet Index 2026, "2006-2025 public data set", Hot or Cool Institute.
#    https://happyplanetindex.org/wp-content/uploads/2026/07/Happy-Planet-Index-2006-2025-public-data-set.xlsx
#    Methodology: https://happyplanetindex.org/wp-content/uploads/2026/07/HPI-Methodology-paper.pdf
#    Download it by hand into data-raw/ (do NOT use a Kaggle or tutorial copy).
# 2. World Bank, World Development Indicators via the WDI package:
#    NY.GDP.PCAP.PP.KD  GDP per capita, PPP (constant 2021 international $)
#    SP.POP.TOTL        Population, total
#    plus World Bank region (grouping variable).
#
# Data-generating-process notes for the slides (Gitelman 2013, Week 2):
# - The 2026 edition switched the footprint component to the ECOLOGICAL
#   footprint (global hectares); older editions used carbon footprint, so do
#   not mix editions.
# - Wellbeing gaps in the Gallup World Poll were interpolated by the HPI team;
#   country counts dip in 2020-2021.
# - The HPI team excluded countries in years of peak conflict (Ethiopia
#   2021-22; Israel, Palestine, Russia, Ukraine 2022/23-2025): their absence
#   is a methodological choice, not missing data.
# ------------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(readxl); library(dplyr); library(tidyr); library(purrr)
  library(stringr); library(readr); library(janitor); library(WDI)
})

raw_path <- "data-raw/Happy-Planet-Index-2006-2025-public-data-set.xlsx"
if (!file.exists(raw_path)) stop("Download the HPI 2026 public data set into ", raw_path)

# 1. Find the HPI table(s) --------------------------------------------------
# The workbook has title rows above the header, so locate the header row by
# looking for a row holding both "Country" and an "HPI" cell.
sheets <- excel_sheets(raw_path)
message("Sheets in workbook: ", paste(sheets, collapse = " | "))

find_header_row <- function(path, sheet, max_scan = 40) {
  peek <- suppressMessages(read_excel(path, sheet = sheet, col_names = FALSE,
                                      n_max = max_scan, .name_repair = "minimal"))
  if (nrow(peek) == 0) return(NA_integer_)
  is_header <- apply(peek, 1, function(r) {
    r <- str_squish(tolower(as.character(r)))
    any(r %in% "country") && any(str_detect(r, "^hpi"), na.rm = TRUE)
  })
  if (any(is_header)) which(is_header)[1] else NA_integer_
}

read_hpi_sheet <- function(path, sheet) {
  h <- find_header_row(path, sheet)
  if (is.na(h)) return(NULL)
  suppressMessages(read_excel(path, sheet = sheet, skip = h - 1,
                              .name_repair = "unique_quiet")) |>
    clean_names() |>
    mutate(across(everything(), as.character))   # harmonise types across sheets
}

tabs <- set_names(sheets) |> map(\(s) tryCatch(read_hpi_sheet(raw_path, s), error = function(e) NULL)) |> compact()
if (length(tabs) == 0) stop("No sheet with a Country + HPI header found. Open the file and check.")
message("Sheets with an HPI table: ", paste(names(tabs), collapse = " | "))

has_year <- map_lgl(tabs, \(d) any(names(d) == "year"))
if (any(has_year)) {
  # Layout A: one long sheet with a year column -> take the largest one
  long <- tabs[has_year]
  hpi_raw <- long[[which.max(map_int(long, nrow))]]
} else {
  # Layout B: one sheet per year, sheet named like "2025"
  yr_tabs <- tabs[str_detect(names(tabs), "(19|20)\\d{2}")]
  if (length(yr_tabs) == 0) stop("No year column and no year-named sheets. Inspect the workbook.")
  hpi_raw <- imap(yr_tabs, \(d, s) mutate(d, year = str_extract(s, "(19|20)\\d{2}"))) |>
    bind_rows()
}

# 2. Pick columns by pattern (fails loudly with the names it saw) ----------
pick1 <- function(df, pattern, what) {
  hits <- str_subset(names(df), pattern)
  if (length(hits) != 1) {
    stop(sprintf("Column for %s matched %d names [%s].\nEdit the pattern. Names available:\n%s",
                 what, length(hits), paste(hits, collapse = ", "),
                 paste(names(df), collapse = ", ")))
  }
  hits
}

col_country <- pick1(hpi_raw, "^country$", "country")
col_year    <- pick1(hpi_raw, "^year$", "year")
col_hpi     <- pick1(hpi_raw, "^hpi$|^hpi_score$|^happy_planet_index$", "HPI score")
col_life    <- pick1(hpi_raw, "^life_exp", "life expectancy")
col_well    <- pick1(hpi_raw, "^life_satisfaction$", "wellbeing")
col_foot    <- pick1(hpi_raw, "^ecological_footprint$", "ecological footprint")
iso_hits    <- str_subset(names(hpi_raw), "^iso")

hpi <- hpi_raw |>
  transmute(
    country   = str_squish(.data[[col_country]]),
    iso3      = if (length(iso_hits) == 1) toupper(.data[[iso_hits]]) else NA_character_,
    year      = as.integer(parse_number(.data[[col_year]])),
    hpi       = parse_number(.data[[col_hpi]]),
    life_exp  = parse_number(.data[[col_life]]),
    wellbeing = parse_number(.data[[col_well]]),
    footprint = parse_number(.data[[col_foot]])
  ) |>
  filter(!is.na(country), !is.na(year), !is.na(hpi))

# Fall back to name matching only if the file has no ISO column
if (all(is.na(hpi$iso3))) {
  message("No ISO column found; matching country names with countrycode.")
  hpi$iso3 <- countrycode::countrycode(hpi$country, "country.name", "iso3c")
}

# 3. World Bank covariates ---------------------------------------------------
yrs <- range(hpi$year)
wb <- WDI(country = "all",
          indicator = c(gdp_pc = "NY.GDP.PCAP.PP.KD", population = "SP.POP.TOTL"),
          start = yrs[1], end = yrs[2], extra = TRUE) |>
  as_tibble()

wb_regions <- wb |>
  filter(!is.na(region), region != "", region != "Aggregates") |>
  distinct(iso3 = iso3c, region)

wb_values <- wb |>
  transmute(iso3 = iso3c, year = as.integer(year), gdp_pc, population)

# Taiwan is not a World Bank member: assign its region by hand (no GDP/pop)
manual_regions <- tibble(iso3 = "TWN", region = "East Asia & Pacific")
wb_regions <- bind_rows(wb_regions, anti_join(manual_regions, wb_regions, by = "iso3"))

clean <- hpi |>
  left_join(wb_values, by = c("iso3", "year")) |>
  left_join(wb_regions, by = "iso3") |>
  mutate(
    log_gdp_pc   = log10(gdp_pc),
    population_m = population / 1e6
  ) |>
  select(iso3, country, region, year, hpi, life_exp, wellbeing, footprint,         gdp_pc, log_gdp_pc, population_m) |>
  arrange(country, year)

# 4. Validation report: paste this output into the slides' data note --------
no_region <- clean |> filter(is.na(region)) |> distinct(country, iso3)
if (nrow(no_region) > 0) {
  warning("Countries without a region (add them to manual_regions):\n",
          paste(no_region$country, no_region$iso3, collapse = "\n"))
}
stopifnot(
  "HPI outside 0-100"        = all(between(clean$hpi, 0, 100)),
  "Wellbeing outside 0-10"   = all(between(clean$wellbeing, 0, 10), na.rm = TRUE),
  "Life expectancy implausible" = all(between(clean$life_exp, 10, 95), na.rm = TRUE),
  "Duplicate country-years"  = !anyDuplicated(clean[c("iso3", "year")])
)

message("\nCountries per year:")
print(count(clean, year), n = Inf)
message("\nMissing values by column:")
print(colSums(is.na(clean)))

dir.create("data", showWarnings = FALSE)
write_csv(clean, "data/hpi_clean.csv")
message("\nWrote data/hpi_clean.csv: ", nrow(clean), " rows, ",
        n_distinct(clean$iso3), " countries, ", yrs[1], "-", yrs[2])
