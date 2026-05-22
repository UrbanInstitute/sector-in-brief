# Paired with validate_inputs(): turns the structured (valid, errors)
# result into UI updates. Called from data_pipeline() on every
# UPDATE DATA click so stale messages from a prior click are cleared.

#' Render inline validation messages under filter cards.
#'
#' For each known filter key, sets `output$validation_<key>` to either
#' a styled message div (when an error is present) or NULL (clears any
#' prior message). Always touches every slot so stale errors from a
#' previous click don't linger.
#'
#' @param errors Named list from `validate_inputs()$errors`. Keys:
#'   geo, subsector, size.
#' @param output The Shiny `output` object for the data_server module.
render_validation_messages <- function(errors, output) {
  slots <- c("geo", "subsector", "size")
  for (key in slots) {
    local({
      msg <- errors[[key]]
      slot <- paste0("validation_", key)
      output[[slot]] <- shiny::renderUI({
        if (is.null(msg)) return(NULL)
        htmltools::div(class = "validation-msg", role = "alert", msg)
      })
    })
  }
  invisible()
}
