# R/chart_bubble.R -------------------------------------------------------------
# OWNER: Member A — Abela Chart 18, bubble chart: relationship among three
# variables (x = GDP per capita, y = HPI score, bubble area = user's choice).
#
# Course grounding
# - Cleveland & McGill (1984): area is decoded far less accurately than
#   position, so the two variables that carry the argument (wealth, HPI) sit
#   on the position axes and the third, contextual variable takes area.
# - Tufte (2001) / Cairo (2019): scale_size_area() makes bubble AREA
#   proportional to the value (zero -> no bubble); scaling the radius would
#   inflate large values quadratically, a classic lie factor.
# - Hover tooltips (plotly::ggplotly) satisfy the assignment's interaction
#   requirement and give exact values the area encoding cannot.
# - Linked view: countries brushed on Chart 9 stay coloured; the rest fade.
# ------------------------------------------------------------------------------

plot_bubble <- function(d, size_var, cols, year, highlight = character(0)) {
  d <- d[!is.na(d$log_gdp_pc) & !is.na(d$hpi) & !is.na(d[[size_var]]), , drop = FALSE]
  shiny::validate(shiny::need(nrow(d) >= 3, "Too few countries with GDP, HPI and size data."))

  rho <- suppressWarnings(stats::cor(d$log_gdp_pc, d$hpi, method = "spearman"))
  size_txt <- if (size_var == "population_m") "Population (millions)" else "Ecological footprint (gha/person)"

  d$tip <- sprintf(
    "<b>%s</b> (%s)<br>HPI score: %.1f<br>GDP per capita: %s<br>Wellbeing: %.1f / 10<br>Life expectancy: %.1f yrs<br>Footprint: %.2f gha<br>Population: %s m",
    d$country, d$region, d$hpi, scales::label_dollar(accuracy = 1)(10^d$log_gdp_pc),
    d$wellbeing, d$life_exp, d$footprint, scales::label_comma(accuracy = 0.1)(d$population_m)
  )

  selecting <- length(highlight) > 0
  d$in_sel  <- if (selecting) d$iso3 %in% highlight else TRUE
  # draw large bubbles first so small ones are not hidden underneath
  d <- d[order(-d[[size_var]]), , drop = FALSE]

  p <- ggplot2::ggplot(d, ggplot2::aes(log_gdp_pc, hpi, size = .data[[size_var]], text = tip))
  if (selecting) {
    p <- p + ggplot2::geom_point(data = d[!d$in_sel, ], colour = muted_grey, alpha = 0.5)
  }
  p +
    ggplot2::geom_hline(yintercept = stats::median(d$hpi), linetype = "dotted", colour = "grey40") +
    ggplot2::annotate("text", x = stats::quantile(d$log_gdp_pc, 0.15), y = stats::median(d$hpi) + 1.5,
                      label = sprintf("Median HPI: %.1f", stats::median(d$hpi)),
                      size = 3, colour = "grey30") +
    ggplot2::geom_point(data = d[d$in_sel, ], ggplot2::aes(colour = region),
                        alpha = 0.7, stroke = 0.3) +
    ggplot2::scale_size_area(max_size = 12, guide = "none") +
    ggplot2::scale_colour_manual(values = cols, drop = FALSE) +
    scale_for("log_gdp_pc", "x") +
    ggplot2::scale_y_continuous(var_label[["hpi"]]) +
    ggplot2::labs(
      # size meaning also printed in the card footer (ggplotly drops captions)
      title = paste0(wrap(sprintf("%s: wealth and HPI score show %s", year, describe_assoc(rho)), 55, "<br>"),
                     sprintf("<br><sup>Bubble area = %s; hover for values</sup>", tolower(size_txt)))
    ) +
    theme_hpi()
}

# ggplotly hard-codes a font family on every text element; reset them all to
# the app font so Chart 18 matches Charts 9 and 3 (consistent theme)
fix_fonts <- function(x) {
  if (!is.list(x)) return(x)
  if ("family" %in% names(x)) x$family <- ui_font
  for (i in seq_along(x)) if (is.list(x[[i]])) x[[i]] <- fix_fonts(x[[i]])
  x
}

# ggplotly wrapper kept here so app.R stays thin
plotly_bubble <- function(p) {
  w <- plotly::plotly_build(plotly::ggplotly(p, tooltip = "text"))
  w$x$layout <- fix_fonts(w$x$layout)
  w |>
    plotly::layout(font = list(family = ui_font),
                   margin = list(t = 80),
                   legend = list(orientation = "h", y = -0.25, title = list(text = "")),
                   hoverlabel = list(align = "left", font = list(family = ui_font))) |>
    plotly::config(displaylogo = FALSE,
                   modeBarButtonsToRemove = c("lasso2d", "select2d", "autoScale2d"))
}
