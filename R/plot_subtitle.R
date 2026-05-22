# Compose the per-plot subtitle from the active second-group variable.
# Strips "Census " from official names ("Census State" → "By State")
# and rewrites "Metro/Micro Area" to the more readable "By Metro Area".

#' Build the plot subtitle for a breakdown view.
#'
#' @param groupby_var Second-group column name, or NULL for overall.
#' @param selected_groups Accepted for signature compatibility; not
#'   currently used in the output.
#' @return A character scalar (empty string for the overall view).
plot_subtitle <- function(groupby_var, selected_groups) {
  subtitle <- ""
  if (is.null(groupby_var)) {
    subtitle <- ""
  } else {
    if (groupby_var == "Metro/Micro Area") {
      subtitle <- "By Metro Area"
    } else {
      subtitle <- paste("By ", groupby_var)
      subtitle <- gsub("Census ", "", subtitle)
    }
  }
  return(subtitle)
}