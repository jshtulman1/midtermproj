library(knitr)
library(dplyr)
library(here)

here::i_am(
  "code/table1.R"
)

data <- read.csv(here::here("data/NBA_2025_per_minute_clean.csv"), sep = ",")

# filter out missing or empty positions
data <- data %>%
  filter(!is.na(position) & position != "")

# table 1: league averages by position
table1 <- data %>%
  group_by(position) %>%
  summarise(
    n_players = n(),
    avg_points = mean(points, na.rm = TRUE),
    avg_minutes = mean(minutes_per_game, na.rm = TRUE),
    avg_field_goal_pct = mean(field_goal_pct, na.rm = TRUE),
    avg_three_point_pct = mean(three_point_pct, na.rm = TRUE),
    avg_assists = mean(assists, na.rm = TRUE),
    avg_rebounds = mean(total_rebounds, na.rm = TRUE),
    avg_steals = mean(steals, na.rm = TRUE),
    avg_blocks = mean(blocks, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(across(c(avg_points, avg_minutes, avg_field_goal_pct, 
                  avg_three_point_pct, avg_assists, avg_rebounds, 
                  avg_steals, avg_blocks), ~round(., 2)))

# overall league averages
league_avg <- data %>%
  summarise(
    position = "League Average",
    n_players = n(),
    avg_points = mean(points, na.rm = TRUE),
    avg_minutes = mean(minutes_per_game, na.rm = TRUE),
    avg_field_goal_pct = mean(field_goal_pct, na.rm = TRUE),
    avg_three_point_pct = mean(three_point_pct, na.rm = TRUE),
    avg_assists = mean(assists, na.rm = TRUE),
    avg_rebounds = mean(total_rebounds, na.rm = TRUE),
    avg_steals = mean(steals, na.rm = TRUE),
    avg_blocks = mean(blocks, na.rm = TRUE)
  ) %>%
  mutate(across(c(avg_points, avg_minutes, avg_field_goal_pct, 
                  avg_three_point_pct, avg_assists, avg_rebounds, 
                  avg_steals, avg_blocks), ~round(., 2)))

# combines positions with league avgs
table1 <- bind_rows(table1, league_avg)

# top 10 players by points
top_players <- data %>%
  arrange(desc(points)) %>%
  head(10) %>%
  select(player, position, team, points, field_goal_pct, 
         assists, total_rebounds, minutes_per_game)

# top players by position
top_players_by_position <- data %>%
  group_by(position) %>%
  arrange(desc(points), .by_group = TRUE) %>%
  slice_head(n = 1) %>%
  ungroup() %>%
  select(player, position, team, points, field_goal_pct, 
         assists, total_rebounds, steals, blocks, minutes_per_game) %>%
  arrange(position, desc(points))


# output list with both tables
output <- list(
  position_averages = table1,
  top_players = top_players,
  top_players_by_position = top_players_by_position
)

# save
saveRDS(output, "output/table1.rds")

