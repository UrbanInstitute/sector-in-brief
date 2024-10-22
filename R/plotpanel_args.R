plotpanel_args <-
  tibble::tribble(
    ~title, ~plot_id, ~table_id, ~download_id, ~table_title_id,
    "Overall", "plot_overall", "table_overall", "dl_overall", "table_overall_title",
    "By Subsector", "plot_subsector", "table_subsector", "dl_subsector", "table_subsector_title",
    "By Geography", "plot_geo", "table_geo", "dl_geo", "table_geo_title",
    "By Asset Size", "plot_size", "table_size", "dl_size", "table_size_title",
  )