library(here)
here::i_am("Code/render.R")
rmarkdown::render(
  input = here("report.Rmd"),
  output_file = here("report/report.html")
)