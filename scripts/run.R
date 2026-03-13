{
  staticimports::import()
  source('scripts/staticimports.R')
  # my_news_to_appendix() # removed - link to NEWS.md in methods instead (#105)

  rmarkdown::render_site(output_format = 'bookdown::gitbook',
                         encoding = 'UTF-8')

  # Render standalone executive summary PDF
  rmarkdown::render(
    "_executive_summary_pdf.Rmd",
    output_format = pagedown::html_paged(
      css = c("default-fonts", "default-page", "default"),
      self_contained = TRUE
    ),
    output_file = "executive_summary.html",
    output_dir = ".",
    quiet = TRUE
  )
  pagedown::chrome_print("executive_summary.html", output = "docs/executive_summary.pdf")
  unlink("executive_summary.html")
}

