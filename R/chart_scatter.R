# R/chart_scatter.R ------------------------------------------------------------
# OWNER: Member A — Abela Chart 9, scatter chart: distribution of two variables.
#
# Course grounding
# - Cleveland & McGill (1984), Heer & Bostock (2010): both quantities are
#   encoded as position along a common scale, the most accurately decoded
#   elementary task; colour (hue) carries only the categorical region.
# - Ware (2012): the scatter is the hypothesis-forming view; brushing it hands
#   the selected countries to Charts 18 and 3 (linked views).
# - Cairo (2019): the message title reports the rank correlation and the
#   caption states how many countries had data (no hidden denominator).
#
# This chart is drawn with plotOutput(brush = ...) in app.R, so it stays a
# static ggplot (brushing needs Shiny's coordinate map, which plotly lacks).
# ------------------------------------------------------------------------------

plot_scatter <- function(d, x, y, cols, year) {
  d <- d[!is.na(d[[x]]) & !is.na(d[[y]]), , drop = FALSE]
  shiny::validate(
    shiny::need(x != y, "Choose two different variables for the scatter chart."),
    shiny::need(nrow(d) >= 3, "Too few countries with data for this year and region selection.")
  )

  rho <- suppressWarnings(stats::cor(d[[x]], d[[y]], method = "spearman"))
  title <- sprintf("%s: %s and %s show %s",
                   year, cap1(var_short[[x]]), var_short[[y]],
                   describe_assoc(rho))

  ggplot2::ggplot(d, ggplot2::aes(.data[[x]], .data[[y]])) +
    # overall linear trend as context, drawn first so points sit on top
    ggplot2::geom_smooth(method = "lm", formula = y ~ x, se = FALSE,
                         colour = "grey55", linewidth = 0.6, linetype = "dashed") +
    ggplot2::geom_point(ggplot2::aes(colour = region), size = 2.6, alpha = 0.85) +
    ggplot2::scale_colour_manual(values = cols, drop = FALSE) +
    scale_for(x, "x") +
    scale_for(y, "y") +
    ggplot2::labs(
      title    = wrap(title, 55),
      subtitle = wrap(sprintf("Spearman rank correlation = %.2f; dashed line = linear fit. Drag a box to select countries.", rho), 65),
      caption  = wrap(sprintf("n = %d countries with both values. %s", nrow(d), source_note), 80)
    ) +
    ggplot2::guides(colour = ggplot2::guide_legend(nrow = 4)) +
    theme_hpi()
}

# Text alternative for screen readers (renderPlot(alt = ...)), Week 9 WCAG
alt_scatter <- function(d, x, y, year) {
  d <- d[!is.na(d[[x]]) & !is.na(d[[y]]), , drop = FALSE]
  sprintf("Scatter chart for %s of %s against %s across %d countries, coloured by World Bank region.",
          year, var_short[[y]], var_short[[x]], nrow(d))
}
