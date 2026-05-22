#' Truncate an aggregated breakdown table to the top-N groups.
#'
#' For geographic breakdowns at the national level, the second-level
#' group column can hold 900+ Metro/Micro Areas or 3000+ counties. ggiraph
#' renders one interactive path per group, so the un-truncated plot
#' chokes the browser and the legend is unreadable.
#'
#' This helper keeps the top N groups by total `value_col` across all
#' other dimensions (typically Year) and collapses the remainder into a
#' single "Other (k)" row, summing the value column. If the table already
#' has <= N groups it is returned unchanged.
#'
#' For proportion tables (sum_var / sum_var_2 * 100), pass the raw count
#' column as `value_col` so ranking is by magnitude, then pass the second
#' count column in `extra_sum_cols` so the "Other" row sums both counts
#' before the caller recomputes the proportion.
#'
#' @param table data.frame / tibble. Already aggregated.
#' @param group_col character. The column whose cardinality we are
#'   truncating (e.g., "Metro/Micro Area", "Census County").
#' @param value_col character. The column to rank groups by (summed
#'   across other dimensions).
#' @param n integer. How many top groups to keep. Default 15.
#' @param extra_sum_cols character vector. Other numeric columns that
#'   should be summed when collapsing into "Other". Non-numeric / non-
#'   grouping columns left out of this list will be dropped in the
#'   collapse.
#' @return tibble with the same columns as the input.
truncate_to_topn <- function(table,
                             group_col,
                             value_col,
                             n = 15,
                             extra_sum_cols = character()) {
  if (is.null(table) || nrow(table) == 0) return(table)
  if (!group_col %in% names(table)) return(table)
  groups <- unique(table[[group_col]])
  if (length(groups) <= n) return(table)

  totals <- table |>
    dplyr::group_by(.data[[group_col]]) |>
    dplyr::summarise(.total = sum(.data[[value_col]], na.rm = TRUE),
                     .groups = "drop") |>
    dplyr::arrange(dplyr::desc(.data$.total))
  top_groups <- totals[[group_col]][seq_len(n)]
  other_count <- length(groups) - n
  other_label <- sprintf("Other (%d)", other_count)

  sum_cols <- unique(c(value_col, extra_sum_cols))
  group_cols <- setdiff(names(table), sum_cols)

  relabeled <- table |>
    dplyr::mutate(
      !!group_col := dplyr::if_else(
        .data[[group_col]] %in% top_groups,
        as.character(.data[[group_col]]),
        other_label
      )
    )

  relabeled |>
    dplyr::group_by(dplyr::across(dplyr::all_of(group_cols))) |>
    dplyr::summarise(
      dplyr::across(dplyr::all_of(sum_cols), \(x) sum(x, na.rm = TRUE)),
      .groups = "drop"
    )
}
