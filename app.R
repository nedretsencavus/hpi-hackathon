# app.R ------------------------------------------------------------------------
# OWNER: Member B (App layout, reactivity, deployment)
# EPPS 6356 Assignment 7, Hackathon 2.0 — Happy Planet Index explorer
#
# Shiny auto-sources every file in R/ before this script runs:
#   R/theme.R          shared palette, labels, theme      (Coordinator)
#   R/chart_scatter.R  Abela Chart 9                      (Member A)
#   R/chart_bubble.R   Abela Chart 18                     (Member A)
#   R/chart_bar.R      Abela Chart 3                      (Member B)
#
# Assignment checklist implemented here
#   [x] >= 2 inputs that change the charts: year, regions, x, y, bubble size
#   [x] one reactive() feeding all three charts: hpi_view()
#   [x] interaction: brush on Chart 9 filters Chart 3 and highlights Chart 18;
#       hover tooltips on Chart 18; animated year slider
#   [x] message titles, axis units, source note, Okabe-Ito colours, bslib + thematic
# ------------------------------------------------------------------------------

library(shiny)
library(bslib)
library(thematic)
library(ggplot2)
library(plotly)
library(readr)
library(scales)

# ---- Data ---------------------------------------------------------------------
data_file <- "data/hpi_clean.csv"
using_mock <- !file.exists(data_file)
if (using_mock) data_file <- "dev/hpi_mock.csv"   # local development only
hpi <- read_csv(data_file, show_col_types = FALSE)

regions     <- sort(unique(stats::na.omit(hpi$region)))
region_cols <- region_palette(regions)
yr          <- range(hpi$year)

# Median HPI of ALL countries per year: the reference line on Chart 3
world_median <- tapply(hpi$hpi, hpi$year, stats::median, na.rm = TRUE)

thematic_shiny()   # ggplot2 + plotly inherit the bslib fonts and colours

# ---- UI -----------------------------------------------------------------------
ui <- page_sidebar(
  title = "Happy lives, lighter footprints? The Happy Planet Index, 2006-2025",
  theme = hpi_bs_theme(),
  fillable = FALSE,

  sidebar = sidebar(
    width = 310,
    sliderInput("year", "Year (press play to animate)",
                min = yr[1], max = yr[2], value = yr[2], step = 1, sep = "",
                animate = animationOptions(interval = 1500)),
    checkboxGroupInput("regions", "World Bank region", choices = regions, selected = regions),
    selectInput("x", "Chart 9: horizontal axis", choices = axis_choices, selected = "log_gdp_pc"),
    selectInput("y", "Chart 9: vertical axis",   choices = axis_choices, selected = "wellbeing"),
    radioButtons("size", "Chart 18: bubble area",
                 c("Population" = "population_m", "Ecological footprint" = "footprint")),
    actionButton("clear", "Clear selection", class = "btn-outline-primary btn-sm"),
    hr(),
    tags$small(
      tags$b("Data. "),
      "Happy Planet Index 2026, 2006-2025 public data set (Hot or Cool Institute), ",
      tags$a("happyplanetindex.org", href = "https://happyplanetindex.org/", target = "_blank"),
      "; GDP per capita (PPP, constant 2021 int'l $), population and regions: World Bank, ",
      tags$a("World Development Indicators", href = "https://databank.worldbank.org/source/world-development-indicators", target = "_blank"),
      "."
    )
  ),

  if (using_mock) div(class = "alert alert-danger", role = "alert",
                      tags$b("MOCK DATA."), " data/hpi_clean.csv is missing; this view uses dev/hpi_mock.csv. Do not deploy."),

  layout_columns(
    col_widths = c(6, 6, 12),
    card(
      full_screen = TRUE,
      card_header("Chart 9 · Scatter chart: how two variables are distributed together"),
      plotOutput("scatter", height = 440,
                 brush = brushOpts("scatter_brush", resetOnNew = FALSE, delay = 400))
    ),
    card(
      full_screen = TRUE,
      card_header("Chart 18 · Bubble chart: wealth, HPI score and a third variable"),
      plotlyOutput("bubble", height = 440),
      card_footer(tags$small("Bubble area is proportional to the chosen variable. Brushed countries stay coloured."))
    ),
    card(
      full_screen = TRUE,
      card_header("Chart 3 · Bar chart: comparing many countries on one score"),
      plotOutput("bar", height = 520),
      card_footer(tags$small(
        tags$b("Why Chart 3 (Abela's bar chart)? "),
        "The HPI is one score per country across more than 130 countries, Abela's case of comparison among many items with one variable each. ",
        "Bars compare lengths on a shared zero baseline, which readers judge accurately (Cleveland and McGill 1984), ",
        "and starting at zero keeps differences honest (Cairo 2019). Brush Chart 9 and this chart ranks your selection."
      ))
    )
  )
)

# ---- Server -------------------------------------------------------------------
server <- function(input, output, session) {

  # ONE reactive feeds Charts 9, 18 and 3, so they always show the same
  # countries for the same year (assignment requirement).
  hpi_view <- reactive({
    validate(need(length(input$regions) > 0, "Select at least one region."))
    hpi[hpi$year == input$year & hpi$region %in% input$regions, , drop = FALSE]
  })

  # Countries inside the brush on Chart 9 -> highlight in 18, rank in 3
  selected_iso <- reactive({
    d <- hpi_view()
    d <- d[!is.na(d[[input$x]]) & !is.na(d[[input$y]]), , drop = FALSE]
    brushedPoints(d, input$scatter_brush, xvar = input$x, yvar = input$y)$iso3
  })

  # A brush drawn on one pair of axes means nothing on another pair
  observeEvent(list(input$x, input$y, input$clear), session$resetBrush("scatter_brush"),
               ignoreInit = TRUE)

  output$scatter <- renderPlot(
    plot_scatter(hpi_view(), input$x, input$y, region_cols, input$year),
    res = 96,
    alt = reactive(alt_scatter(hpi_view(), input$x, input$y, input$year))
  )

  output$bubble <- renderPlotly(
    plotly_bubble(plot_bubble(hpi_view(), input$size, region_cols, input$year,
                              highlight = selected_iso()))
  )

  output$bar <- renderPlot(
    plot_bar(hpi_view(), region_cols, input$year,
             highlight = selected_iso(),
             world_median = world_median[[as.character(input$year)]]),
    res = 96,
    alt = reactive(alt_bar(hpi_view(), input$year, selected_iso()))
  )
}

shinyApp(ui, server)
