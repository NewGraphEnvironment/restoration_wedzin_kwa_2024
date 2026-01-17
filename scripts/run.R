{
  staticimports::import()
  source('scripts/staticimports.R')
  # my_news_to_appendix() # removed - link to NEWS.md in methods instead (#105)

  rmarkdown::render_site(output_format = 'bookdown::gitbook',
                         encoding = 'UTF-8')
}

