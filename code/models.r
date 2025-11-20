here::i_am("code/models.R"
)

library(rvest)
library(dplyr)
library(tidyr)
library(ggplot2)
library(gtsummary)

url <- "https://www.basketball-reference.com/leagues/NBA_2026_per_minute.html"
page <- read_html(url)
tables <- page %>% html_nodes("table")
df <- tables[[1]] %>% html_table(fill = TRUE)

mod <- glm(
  PTS ~ Age,
  data = df
)

primary_regression_table <- 
  tbl_regression(mod) |>
  add_global_p()

summary(mod)

saveRDS(
  primary_regression_table,
  file = 
    here::here("output/primary_regression_table.rds"))
