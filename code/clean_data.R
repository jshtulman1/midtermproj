# Load packages
library(dplyr)
library(ggplot2)
library(janitor)
library(rvest)

# Create folder if it doesn't exist
if(!dir.exists("data")) dir.create("data")

# Set global chunk options
knitr::opts_chunk$set(
  echo = FALSE,       # hide all code
  results = 'hide',   # hide all printed output
  message = FALSE,    # hide package messages
  warning = FALSE     # hide warnings
)

#URL for NBA 2025 per-minute stats
url <- "https://www.basketball-reference.com/leagues/NBA_2025_per_minute.html"
#Download raw HTML only if it doesn't already exist
if (!file.exists("data/NBA_2025_per_minute_raw.html")) {
  download.file(url, destfile = "data/NBA_2025_per_minute_raw.html", mode = "wb")
}

#Read HTML
html_file <- "data/NBA_2025_per_minute_raw.html"
page <- read_html(html_file)
table_node <- html_node(page, "table#per_minute_stats")
nba_pm_df <- html_table(table_node, fill = TRUE)
#Remove repeated header rows safely
nba_pm_df <- nba_pm_df[trimws(nba_pm_df$Player) != "Player", ]
#Clean column names
nba_pm_df <- janitor::clean_names(nba_pm_df)

#Rename to descriptive names
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

#Convert numeric/stat columns safely (exclude player, team, position)
numeric_cols <- setdiff(names(nba_pm_df), c("player", "team", "position"))
nba_pm_df[numeric_cols] <- lapply(nba_pm_df[numeric_cols], function(x) {
  as.numeric(gsub("%", "", x))
})

#Check first few rows of key columns
print(head(nba_pm_df$player))
print(head(nba_pm_df$team))
print(head(nba_pm_df$position))
#Check structure
str(nba_pm_df)

#Save cleaned CSV without printing "writing" message
invisible(write.csv(nba_pm_df, "data/NBA_2025_per_minute_clean.csv", row.names = FALSE))