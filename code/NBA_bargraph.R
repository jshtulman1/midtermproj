# Load required libraries
library(rvest)
library(dplyr)
library(tidyr)
library(ggplot2)
url <- "https://www.basketball-reference.com/leagues/NBA_2026_per_minute.html"
page <- read_html(url)
tables <- page %>% html_nodes("table")
df <- tables[[1]] %>% html_table(fill = TRUE)
df_clean <- df %>%
  # Convert columns to numeric
  mutate(
    `3P` = as.numeric(`3P`),
    `2P` = as.numeric(`2P`),
    FT = as.numeric(FT),
    Pos = as.factor(Pos)
  ) %>%
  # Filter out rows without a position
  filter(!is.na(Pos))

# Checking filter 
head(df_clean)

avg_by_pos <- df_clean %>%
  mutate(
    Pos = trimws(Pos)  
  ) %>%
  group_by(Pos) %>%
  summarise(
    avg_3P = mean(`3P`, na.rm = TRUE),
    avg_2P = mean(`2P`, na.rm = TRUE),
    avg_FT = mean(FT, na.rm = TRUE)
  ) %>%
  pivot_longer(
    cols = starts_with("avg_"),
    names_to = "shot_type",
    values_to = "points_per_36"
  ) %>%
  mutate(
    shot_type = recode(shot_type,
                       avg_3P = "3 Point",
                       avg_2P = "2 Point",
                       avg_FT = "Free Throw")
  )

# Plot
bargraph <- ggplot(avg_by_pos, aes(x = Pos, y = points_per_36, fill = shot_type)) +
  geom_col(position = "dodge") +
  labs(
    title = "Average Points per 36 Minutes by Position and Shot Type",
    x = "Position",
    y = "Points per 36 Minutes",
    fill = "Shot Type",
    caption = "PG = Point Guard, SG = Shooting Guard, SF = Small Forward, PF = Power Forward, C = Center"
  ) +
  scale_y_continuous(expand = c(0,0)) + 
  theme_light()

saveRDS(
  bargraph,
  file = 
    here::here("output/bargraph.rds"))

bargraph
