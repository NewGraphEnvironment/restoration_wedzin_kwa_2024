{
  staticimports::import()
  source('scripts/staticimports.R')
  my_news_to_appendix()

  rmarkdown::render_site(output_format = 'bookdown::gitbook',
                         encoding = 'UTF-8')
}

