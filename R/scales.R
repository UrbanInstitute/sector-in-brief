# y-axis scales for the panel plots. Lock the lower bound at 0
# (all metrics are non-negative) with 10% headroom at the top so tick
# labels don't crowd the chart edge. Tick label format is
# metric-aware: dollar metrics get a "$1.2B" short-scale; counts get
# "1.2M" short-scale; the DAF proportion gets a "25%" percent label.

# Metric names that should render with a dollar prefix on the y-axis
# (matches the set used in tooltip_text.R; keep these two in sync).
.dollar_metrics <- c(
  "Total Assets",
  "Total Revenues",
  "Total Expenses",
  "Total Benefits",
  "Total Contributions",
  "Total Grants",
  "Total Value",
  "Total Government Grants",
  "Total Program-Related Investments"
)

#' Return a ggplot y-axis scale tuned to one metric.
#'
#' Routes to dollar / percent / count formatters based on `yvar`.
#' Pre-PR-C every plot used `scales::comma` regardless of metric,
#' producing tick labels like `$1,200,000,000` that pushed legends
#' off-screen on dollar panels. Short-scale labels keep them
#' compact and readable.
#'
#' @param yvar Metric column name (e.g. "Total Assets",
#'   "Number of Nonprofits", "Proportion with DAFs").
#' @return A `ggplot2::scale_y_continuous` object.
y_scale_for <- function(yvar) {
  labels <- if (identical(yvar, "Proportion with DAFs")) {
    # Values are already 0-100 (table_builder_proportion does the *100),
    # so scale = 1 in label_percent (default would multiply by 100 again).
    scales::label_percent(scale = 1, accuracy = 1)
  } else if (yvar %in% .dollar_metrics) {
    scales::label_dollar(scale_cut = scales::cut_short_scale())
  } else {
    scales::label_number(scale_cut = scales::cut_short_scale())
  }

  ggplot2::scale_y_continuous(
    limits = c(0, NA),
    expand = ggplot2::expansion(mult = 0.1),
    labels = labels
  )
}
