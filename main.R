library(tidymodels)
library(skimr)
library(rsample)

starwars

skim(starwars)
view(starwars)

datareg <- starwars%>%select(height, mass, gender)

# we need to sample our data i,e split into test and train, so we use R sample

datareg_split <- initial_split(datareg)
datareg_train <- training(datareg_split)
datareg_test <- testing(datareg_split)



library(RSQLite)


con <- dbConnect(RSQLite::SQLite(), "mydatabase.db")
dbDisconnect(con)


#Data Preparation
# Load the datasets (box_scores.csv, fixture_information.csv, 
# test_fixtures.csv) into R using functions like read.csv or 
# any suitable function based on the file format.

#connect to DB and pull the datasets 
df_box_scores <- dbGetQuery(con, "SELECT * FROM box_scores")
df_fixture_information <- dbGetQuery(con, "SELECT * FROM fixture_information")
df_test_fixtures <- dbGetQuery(con, "SELECT * FROM test_fixtures")
df_test_fixtures_actuals <- dbGetQuery(con, "SELECT * FROM test_fixtures_actuals")

skim(df_box_scores)
skim(df_fixture_information)
skim(df_test_fixtures)
skim(df_test_fixtures_actuals)

FixtureKey <- "LIPSCO v A PEAY 14-Jan-2023"

splitfun = unlist(strsplit(df_box_scores$FixtureKey[1], " "))
team_names <- paste(unlist(strsplit(df_box_scores$FixtureKey[1], " "))[1:4], collapse = " ")
date <- unlist(strsplit(df_box_scores$FixtureKey[1], " "))[5]


dfBoxScoresHead <- head(df_box_scores, 5)

df_box_scores %>%rowwise() %>%
  mutate(TeamAvTeamB = paste(unlist(strsplit(as.character(FixtureKey), " "))[1:4], collapse = " "))%>%
  mutate(TeamName = strsplit(trimws(gsub("(?i)v", ",", TeamAvTeamB)), ",")[[1]][Team])%>%
  select(!TeamAvTeamB)%>%
  select(TeamName,FixtureKey,Team,X2PM,X2PA,X3PM,X3PA,FTM,FTA,ORB,DRB,AST,STL,BLK,TOV,PF)


# input_string <- "LIPSCO v A PEAY 14-Jan-2023"
# # Split the string at "v" (case-insensitive) and remove leading/trailing spaces
# split_string <- trimws(gsub("(?i)v", ",", input_string))
# 
# # Split the result at the comma to get the team names
# team_names <- strsplit(split_string, ",")[[1]]
# 
# 
# strsplit(trimws(gsub("(?i)v", ",", input_string)), ",")[[1]][1]
# 
# 
# 
# 
# 
# split_string <- unlist(strsplit(input_string, " "))
# 
# # Extract the team names and date
# team_names <- paste(split_string[1:4], collapse = " ")
# date <- split_string[5]
# 
# 
# 
