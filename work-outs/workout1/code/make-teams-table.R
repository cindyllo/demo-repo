### Data Preparation: Make Teams Table for NBA 2018
### This R-script will manipulate the file `nba2018.csv` by processing the data to prepare it for our ranking analysis.
### Input: `nba2018.csv`
### Output: `nba2018-teams.csv`
library(readr)
library(dplyr)
input_file <- "../data/nba2018.csv"
output_file <- "../data/nba2018-teams.csv"

nba2018_tbl <- read_csv(input_file, 
                        col_types = list(
                          position = col_factor(
                            levels = c("C", "PF", "PG", "SF", "SG"))))

nba2018_tbl$experience[nba2018_tbl$experience == "R"] = "0"
nba2018_tbl$experience <- as.integer(nba2018_tbl$experience)

nba2018_tbl$salary <- salary/1000000

levels(nba2018_tbl$position) <- c("center", "power_fwd", "point_guard", "small_fwd", "shoot_guard")

nba2018_tbl <- mutate(nba2018_tbl,
                      missed_fg = field_goals_atts - field_goals)

nba2018_tbl <- mutate(nba2018_tbl,
                      missed_ft = points1_atts - points1_atts)

nba2018_tbl <- mutate(nba2018_tbl,
                      rebounds = total_rebounds)

PTS <- nba2018_tbl$points
REB <- nba2018_tbl$rebounds
AST <- nba2018_tbl$assists
STL <- nba2018_tbl$steals
BLK <- nba2018_tbl$blocks
MissedFG <- nba2018_tbl$missed_fg
MissedFT <- nba2018_tbl$missed_ft
TO <- nba2018_tbl$turnovers
GP <- nba2018_tbl$games
efficiency <-  (PTS + REB + AST + STL + BLK - MissedFG - MissedFT - TO) / GP
nba2018_tbl <- mutate(nba2018_tbl,
                      efficiency = efficiency)

sink("../output/efficiency-summary.txt")
summary(nba2018_tbl$efficiency)
sink()

# To keep the data up to 2 decimal digits
nba2018_tbl$efficiency <- as.numeric(format(round(nba2018_tbl$efficiency, 2), nsmall = 2))
nba2018_tbl$salary <- as.numeric(format(round(nba2018_tbl$salary, 2), nsmall = 2))
teams <- select(nba2018_tbl,
                team,
                experience,
                salary,
                points3,
                points2,
                points1,
                points,
                off_rebounds,
                def_rebounds,
                assists,
                steals,
                blocks,
                turnovers,
                fouls,
                efficiency)

sink("../data/teams-summary.txt")
summary(teams)
sink()

write_csv(teams, path = "../data/nba2018-teams.csv")
