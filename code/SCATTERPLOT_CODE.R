# ---------------------------------------------------
# BBall Project Scatterplot Script
# Author: Cassandra Ortiz-Nelsen
# Instructions:
# 1. Open this script in R or RStudio.
# 2. Run all lines sequentially.
# 3. Optional: The scatterplot will be saved as 'scatterplot_output.png' in this folder.
# ---------------------------------------------------

# --- 0. Load required packages ---
library(dplyr)
library(ggplot2)
library(janitor)
library(rvest)

# --- 1. Create folder if it doesn't exist ---
if(!dir.exists("code")) dir.create("code")

# --- 2. Download raw HTML if not already saved ---
url <- "https://www.basketball-reference.com/leagues/NBA_2025_per_minute.html"
if (!file.exists("code/NBA_2025_per_minute_raw.html")) {
  download.file(url, destfile = "code/NBA_2025_per_minute_raw.html", mode = "wb")
}

# --- 3. Read HTML and extract table ---
html_file <- "code/NBA_2025_per_minute_raw.html"
page <- read_html(html_file)
table_node <- html_node(page, "table#per_minute_stats")
nba_pm_df <- html_table(table_node, fill = TRUE)

# --- 4. Remove repeated header rows ---
nba_pm_df <- nba_pm_df[trimws(nba_pm_df$Player) != "Player", ]

# --- 5. Clean column names ---
nba_pm_df <- janitor::clean_names(nba_pm_df)

# --- 6. Rename columns to descriptive names ---
new_names <- c(
  "rank", "player", "age", "team", "position",
  "games_played", "games_started", "minutes_per_game",
  "field_goals_made", "field_goals_attempted", "field_goal_pct",
  "three_point_made", "three_point_attempted", "three_point_pct",
  "two_point_made", "two_point_attempted", "two_point_pct",
  "effective_fg_pct", "free_throws_made", "free_throws_attempted",
  "free_throw_pct", "offensive_rebounds", "defensive_rebounds",
  "total_rebounds", "assists", "steals", "blocks", "turnovers",
  "personal_fouls", "points", "awards"
)
names(nba_pm_df) <- new_names

# --- 7. Convert numeric/stat columns ---
numeric_cols <- setdiff(names(nba_pm_df), c("player", "team", "position"))
nba_pm_df[numeric_cols] <- lapply(nba_pm_df[numeric_cols], function(x) as.numeric(gsub("%", "", x)))

# --- 8. Handle missing positions ---
nba_pm_df <- nba_pm_df %>%
  mutate(position = ifelse(is.na(position), "Unknown", position))

# --- 9. Create steal-to-foul ratio and top players ---
nba_pm_df <- nba_pm_df %>%
  mutate(steal_foul_ratio = ifelse(personal_fouls > 0, steals / personal_fouls, NA))

top_players <- nba_pm_df %>%
  filter(!is.na(steal_foul_ratio)) %>%
  arrange(desc(steal_foul_ratio)) %>%
  slice_head(n = 10)

top_players_subset <- top_players %>% slice(c(1,3,5))  # For labels on scatterplot

# --- 10. Create scatterplot ---
my_scatterplot <- ggplot(nba_pm_df, aes(x = personal_fouls, y = steal_foul_ratio, color = position)) +
  geom_point(alpha = 0.7, size = 2.5, position = position_jitter(width = 0.2, height = 0)) +
  geom_text(
    data = top_players_subset,
    aes(label = player),
    vjust = -0.8,
    size = 3,
    color = "black"
  ) +
  geom_smooth(aes(group = 1), method = "lm", se = FALSE, color = "red3", linetype = "dashed") +
  scale_color_manual(values = c(
    "G" = "hotpink",
    "F" = "#FFD700",
    "C" = "#1E90FF",
    "Unknown" = "gray50"
  )) +
  labs(
    title = "Steal-to-Foul Ratio (NBA 2025)",
    subtitle = "Higher values indicate high-risk, high-reward defenders",
    x = "Personal Fouls per Game",
    y = "Steals per Game",
    color = "Position"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "bottom",
    panel.grid.major = element_line(color = "gray80"),
    panel.grid.minor = element_line(color = "gray90"),
    plot.margin = margin(t = 20, r = 10, b = 10, l = 10)
  ) +
  coord_cartesian(clip = "off")

# --- 11. Optional: save scatterplot as PNG ---
png("output/scatterplot_output.png", width = 800, height = 600)
print(my_scatterplot)
dev.off()