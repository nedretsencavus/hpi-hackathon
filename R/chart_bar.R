# R/chart_bar.R ----------------------------------------------------------------
# OWNER: Member B — Abela Chart 3, bar chart: comparison among many items,
# one variable per item (countries ranked by HPI score).
#
# Why Chart 3 suits these data (also shown in the app's card footer):
# - The HPI is one score per country across 130+ countries: Abela's
#   "comparison > among items > one variable per item > many categories".
# - Horizontal bars leave room for long country names.
# - Cleveland & McGill (1984): bar ends are compared by position/length on a
#   common, aligned baseline, the second-best elementary perceptual task.
# - Cairo (2019): bars encode length, so the axis MUST start at zero; a
#   truncated bar axis exaggerates differences. expand_limits(x = 0) and no
#   coord limits guarantee that.
# - Context line: the dashed rule is the median of ALL countries that year,
#   so a selected subset is never read without its reference (Tufte, macro/micro).
# - Linked view: when countries are brushed on Chart 9 this chart ranks
#   exactly those; otherwise it shows the 10 highest and 10 lowest.
# ------------------------------------------------------------------------------

plot_bar <- function(d, cols, year, highlight = character(0), world_median = NULL) {
  d <- d[!is.na(d$hpi), , drop = FALSE]
  shiny::validate(shiny::need(nrow(d) >= 1, "No countries with an HPI score for this selection."))

  if (length(highlight) > 0) {
    d <- d[d$iso3 %in% highlight, , drop = FALSE]
    d <- utils::head(d[order(-d$hpi), , drop = FALSE], 20)   # 20 bars stay legible
    scope <- sprintf("%d selected countr%s", nrow(d), if (nrow(d) == 1) "y" else "ies")
    sub   <- if (sum(highlight %in% d$iso3) < length(highlight)) "Top 20 of the selection shown." else "Countries selected on the scatter chart."
  } else {
    d <- d[order(-d$hpi), , drop = FALSE]
    d <- if (nrow(d) > 20) rbind(utils::head(d, 10), utils::tail(d, 10)) else d
    scope <- "the 10 highest and 10 lowest scorers"
    sub   <- "Brush the scatter chart to rank your own selection."
  }

  top <- d[which.max(d$hpi), ]
  low <- d[which.min(d$hpi), ]
  title <- if (length(highlight) > 0) {
    sprintf("%s: %s leads the %s on the HPI (%.1f)", year, top$country, scope, top$hpi)
  } else {
    sprintf("%s: %s tops the HPI at %.1f; %s ranks lowest at %.1f",
            year, top$country, top$hpi, low$country, low$hpi)
  }
  d$country <- stats::reorder(d$country, d$hpi)

  p <- ggplot2::ggplot(d, ggplot2::aes(hpi, country)) +
    ggplot2::geom_col(ggplot2::aes(fill = region), width = 0.72) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%.1f", hpi)),
                       hjust = -0.15, size = 3.3, colour = "grey20") +
    ggplot2::scale_fill_manual(values = cols, drop = FALSE) +
    ggplot2::scale_x_continuous(var_label[["hpi"]],
                                expand = ggplot2::expansion(mult = c(0, 0.08))) +
    ggplot2::expand_limits(x = 0) +
    ggplot2::guides(fill = ggplot2::guide_legend(nrow = 2)) +
    ggplot2::labs(y = NULL, title = wrap(title, 90), subtitle = sub,
                  caption = paste0("Bars start at zero. Dashed line = median of all countries in ",
                                   year, ".\n", source_note)) +
    theme_hpi() +
    ggplot2::theme(panel.grid.major.y = ggplot2::element_blank())

  if (!is.null(world_median)) {
    p <- p + ggplot2::geom_vline(xintercept = world_median, linetype = "dashed", colour = "grey40")
  }
  p
}

alt_bar <- function(d, year, highlight = character(0)) {
  n <- if (length(highlight) > 0) sum(d$iso3 %in% highlight) else min(20, sum(!is.na(d$hpi)))
  sprintf("Horizontal bar chart ranking %d countries by Happy Planet Index score in %s.", n, year)
}
