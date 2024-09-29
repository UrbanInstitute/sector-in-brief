plotpanel_args <-
  tibble::tribble(
    ~title, ~plot_id, ~table_id, ~download_id,
    "Overall", "plot_overall", "table_overall", "dl_overall",
    "By Subsector", "plot_subsector", "table_subsector", "dl_subsector",
    "By Geography", "plot_geo", "table_geo", "dl_geo",
    "By Asset Size", "plot_size", "table_size", "dl_size",
  )