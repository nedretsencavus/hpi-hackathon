# R/theme.R --------------------------------------------------------------------
# OWNER: Coordinator (committed once in the scaffold; nobody else edits it)
# Shared look for all three charts so the app reads as one system.
# Shiny auto-sources every file in R/ before app.R runs (Shiny >= 1.5).
#
# Course grounding
# - Wickham, ggplot2 (Week 7): one role-based theme layered onto every plot.
# - Tufte (Week 5): minor gridlines and chart borders removed (data-ink).
# - Cairo, How Charts Lie (Week 3): every chart carries a source note and
#   states its denominator (n countries with data).
# - Week 9 accessibility: Okabe-Ito qualitative palette, distinguishable under
#   the common forms of colour-vision deficiency; yellow placed last because
#   it has the weakest contrast on white.
# ------------------------------------------------------------------------------

okabe_ito <- c("#0072B2", "#E69F00", "#009E73", "#D55E00",
               "#56B4E9", "#CC79A7", "#000000", "#F0E442")

# Colour per region, assigned once from the data so all charts agree
region_palette <- function(regions) {
  regions <- sort(unique(regions))
  stopifnot("More regions than palette colours" = length(regions) <= length(okabe_ito))
  stats::setNames(okabe_ito[seq_along(regions)], regions)
}

muted_grey <- "#C9CED6"   # non-selected countries when a brush is active

# Variables a user may place on an axis (label shown in the UI -> column)
axis_choices <- c(
  "GDP per capita, PPP (log scale)"         = "log_gdp_pc",
  "Wellbeing, Ladder of Life (0-10)"        = "wellbeing",
  "Life expectancy at birth (years)"        = "life_exp",
  "Ecological footprint (gha per person)"   = "footprint",
  "Happy Planet Index score (0-100)"        = "hpi"
)

# Axis titles with units (assignment: "labelled axes with units")
var_label <- c(
  log_gdp_pc   = "GDP per capita, PPP (constant 2021 international $, log scale)",
  wellbeing    = "Wellbeing: Ladder of Life (0-10)",
  life_exp     = "Life expectancy at birth (years)",
  footprint    = "Ecological footprint (global hectares per person)",
  hpi          = "Happy Planet Index score (0-100)",
  population_m = "Population (millions)"
)

# Short names used inside message titles
var_short <- c(
  log_gdp_pc = "GDP per capita", wellbeing = "wellbeing",
  life_exp = "life expectancy", footprint = "ecological footprint",
  hpi = "HPI score", population_m = "population"
)

# Short note printed on every chart; the full citation sits in the app sidebar
source_note <- "Source: Happy Planet Index 2026 (Hot or Cool Institute); World Bank WDI."

# svg/ggplot titles do not wrap themselves: break long message titles so they
# fit a half-width card instead of running off the edge
wrap <- function(s, width = 60, sep = "\n") paste(strwrap(s, width), collapse = sep)

# plotly ignores ggplot font families, so the bubble chart sets this explicitly
ui_font <- "system-ui, -apple-system, 'Segoe UI', Roboto, Arial, sans-serif"

# Position scale that relabels the log10 GDP column back into dollars, so the
# brush works in linear space while readers see dollar values (Cairo: the log
# transform is disclosed in the axis title, not hidden).
scale_for <- function(var, axis = c("x", "y")) {
  axis <- match.arg(axis)
  fun <- if (axis == "x") ggplot2::scale_x_continuous else ggplot2::scale_y_continuous
  if (var == "log_gdp_pc") {
    fun(var_label[[var]],
        breaks = log10(c(1e3, 3e3, 1e4, 3e4, 1e5)),
        labels = scales::label_dollar()(c(1e3, 3e3, 1e4, 3e4, 1e5)))
  } else {
    fun(var_label[[var]])
  }
}

theme_hpi <- function(base_size = 11) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title.position = "plot",
      plot.title    = ggplot2::element_text(face = "bold", size = base_size + 2),
      plot.subtitle = ggplot2::element_text(colour = "grey30"),
      plot.caption  = ggplot2::element_text(hjust = 0, colour = "grey35", size = base_size - 3),
      panel.grid.minor = ggplot2::element_blank(),
      axis.text        = ggplot2::element_text(size = base_size - 1, colour = "grey25"),
      axis.title       = ggplot2::element_text(size = base_size),
      legend.position  = "bottom",
      legend.title     = ggplot2::element_blank(),
      legend.text      = ggplot2::element_text(size = base_size - 3)
    )
}

cap1 <- function(s) paste0(toupper(substring(s, 1, 1)), substring(s, 2))

# Plain-language strength of a rank correlation, for message titles
describe_assoc <- function(rho) {
  if (is.na(rho)) return("no measurable association")
  strength <- as.character(cut(abs(rho), c(-Inf, 0.1, 0.3, 0.5, Inf),
                               labels = c("no clear", "a weak", "a moderate", "a strong")))
  if (strength == "no clear") return("no clear association")
  paste(strength, if (rho > 0) "positive" else "negative", "association")
}

# Shared bslib theme (assignment: consistent theme via bslib + thematic)
hpi_bs_theme <- function() {
  bslib::bs_theme(
    version   = 5,
    bg        = "#FFFFFF",
    fg        = "#1F2933",
    primary   = "#0072B2",
    base_font = bslib::font_collection("system-ui", "-apple-system", "Segoe UI",
                                       "Roboto", "Helvetica Neue", "Arial", "sans-serif")
  )
}
