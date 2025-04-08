# Module for welcome page
welcomeUI <- bslib::nav_panel(
  title = "Welcome",
  htmltools::div(
    class = "bg-box__dot",
    htmltools::div(class = "box-title", welcome_title, welcome_subtitle)
  ),
  htmltools::br(),
  htmltools::div(
    class = "bg-box__white",
    htmltools::div(
      class = "flex-box__column",
      welcome_para_1,
      welcome_para_2,
      welcome_para_3,
      welcome_para_4,
      welcome_para_5
    )
  ),
  htmltools::div(
    class = "bg-box__white",
    htmltools::div(
      class = "flex-box__row",
      htmltools::img(class = "img", src = "urban-chart-icon.svg"),
      htmltools::div(
        class = "flex-box__column",
        welcome_visual_header,
        welcome_visual_para
      )
    )
  ),
  htmltools::div(
    class = "bg-box__white",
    htmltools::div(
      class = "flex-box__row",
      htmltools::div(
        class = "flex-box__column",
        welcome_download_header,
        welcome_download_para
      ),
      htmltools::img(class = "img", src = "urbn-download-icon.svg")
    )
  ),
  htmltools::br(),
  htmltools::div(
    class = "bg-box__grey",
    htmltools::div(
      class = "flex-box__row-align",
      credits,
      about
    )
  )
)