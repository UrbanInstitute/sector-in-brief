render_download <- function(tables){
  purrr::imap(
    tables,
    .f = function(table, name) {
      downloadHandler(
        filename = paste0(name, ".csv"),
        content = function(file) {
          write.csv(table, file)
        }
      )
    }
  )
}