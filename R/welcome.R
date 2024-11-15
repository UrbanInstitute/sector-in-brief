# Welcome Page for sector in Brief
welcome <- bslib::nav_panel(
  title = "Welcome",
  htmltools::div(
    class = "welcome-banner",
    htmltools::div(
      class = "welcome-header",
     welcome_title,
     welcome_subtitle
    )
  ),
  htmltools::br(),
  htmltools::div(
    class = "banner-light",
    htmltools::div(
      class = "flex-box--column",
      welcome_para_1,
      welcome_para_2,
      welcome_para_3,
      welcome_para_4,
    )
  ),
  htmltools::div(
    class = "banner-light",
    htmltools::div(
      class = "flex-box--row",
      htmltools::div(
        class = "flex-box--column",
        welcome_visual_header,
        welcome_visual_para
      ), 
      htmltools::img(class = "img-box",
                     src = "visual_ss.png")
    )
  ),
  htmltools::div(
    class = "banner-light",
    htmltools::div(
      class = "flex-box--row",
      htmltools::div(
        class = "flex-box--column",
        welcome_download_header,
        welcome_download_para
      ),
      htmltools::img(class = "img-box",
                     src = "download_ss.png")
    )
  )
)