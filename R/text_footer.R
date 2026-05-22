# Site-wide footer ("We want your Feedback" link to the Qualtrics
# survey). Attached to bslib::page_navbar's `footer` arg in app.R.
text_footer <- htmltools::div(
  class = "footer",
  htmltools::HTML("We want your <a href='https://urban.co1.qualtrics.com/jfe/form/SV_2fRHTFJxNzD4GcS' style='color:#ffffff; font-weight:700px;'>Feedback.</a>")
)
