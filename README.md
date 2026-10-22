# Happy Lives, Lighter Footprints? A Happy Planet Index Explorer

EPPS 6356 Data Visualization, Fall 2026 · Assignment 7, Hackathon 2.0 · Team [TEAM NAME]

A Shiny app showing three charts from Abela's *Chart Suggestions: A Thought-Starter* (2006), linked by one reactive data set:

| Abela no. | Chart | Question it answers | Owner |
|---|---|---|---|
| 9 | Scatter chart | How are two chosen variables distributed together? | Member A |
| 18 | Bubble chart | How do wealth, HPI score and population (or footprint) relate? | Member A |
| 3 | Bar chart (team's choice) | Which countries score highest and lowest, or within a brushed selection? | Member B |

- **Live app:** [Posit Connect Cloud link]
- **Website page:** [GitHub Pages link]
- **Slides:** [link]

## Data and citation

- Hot or Cool Institute. 2026. *Happy Planet Index 2026: 2006–2025 Public Data Set*. https://happyplanetindex.org/ (methodology: https://happyplanetindex.org/wp-content/uploads/2026/07/HPI-Methodology-paper.pdf).
- World Bank. 2026. *World Development Indicators*: GDP per capita, PPP (constant 2021 international $), NY.GDP.PCAP.PP.KD; Population, total, SP.POP.TOTL; region classification. Accessed via the R package `WDI`.

Raw workbook: `data-raw/`. Cleaning script: `data-raw/data_prep.R`. Clean file read by the app: `data/hpi_clean.csv`.

| Column | Meaning | Unit |
|---|---|---|
| iso3, country, region | ISO 3166 alpha-3 code, name, World Bank region | — |
| year | Data year | 2006–2025 |
| hpi | Happy Planet Index score | 0–100 |
| life_exp | Life expectancy at birth | years |
| wellbeing | Ladder of Life (Gallup World Poll) | 0–10 |
| footprint | Ecological footprint per person | global hectares |
| gdp_pc, log_gdp_pc | GDP per capita, PPP and its log10 | constant 2021 int'l $ |
| population_m | Population | millions |

## Run locally

```r
install.packages(c("shiny", "bslib", "thematic", "ggplot2", "plotly", "readr", "scales"))
shiny::runApp()
```

Without `data/hpi_clean.csv` the app runs on clearly labelled mock data (`dev/hpi_mock.csv`) and shows a red banner. Never deploy in that state.

## Repository layout

```
app.R                 UI + server (Member B)
R/theme.R             shared palette, labels, theme (Coordinator)
R/chart_scatter.R     Chart 9 (Member A)
R/chart_bubble.R      Chart 18 (Member A)
R/chart_bar.R         Chart 3 (Member B)
data-raw/data_prep.R  download -> clean -> data/hpi_clean.csv (Member A)
deploy/write_manifest.R  manifest.json for Connect Cloud (Member B)
website/              iframe page for the team site (Coordinator)
SYNERGY.md            synergy report (Coordinator)
AI_DISCLOSURE.md      generative AI disclosure (whole team)
```

## AI use

See `AI_DISCLOSURE.md`, as required by the course AI policy.
