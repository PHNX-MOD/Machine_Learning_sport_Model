# Machine Learning Sport model

# Table of Contents
[About](#About) <br />
[Exploratory data analysis](#Exploratory-data-analysis)

## About
The aim is to create a machine-learning model using Python and R with front-end access using Shiny and Django frameworks. 

## working files
[main.R](https://github.com/PHNX-MOD/Machine_Learning_sport_Model/blob/main/main.R) & [mainPython.ipynb](https://github.com/PHNX-MOD/Machine_Learning_sport_Model/blob/main/mainPython.ipynb)

## Working Directories 
https://github.com/PHNX-MOD/Machine_Learning_sport_Model/tree/main/CBBModelPyDjango
https://github.com/PHNX-MOD/Machine_Learning_sport_Model/tree/main/CBBModelRShiny

## Exploratory data analysis
The data((mydatabase.db) represents various fixture-level college basketball (NCAA Basketball / which is added to the database (mydatabase.db)) statistics from the past 2 years.
The objective will be to build a model that is able to predict the winners for the fixtures on the 25th of February, 2023. 

 Writing all the csv data into a database using dbConnect in R, just as a practice to pull data from SQl
 ```
con <- dbConnect(RSQLite::SQLite(), "mydatabase.db") #establishing a connection with DB
folder <- "." #present folder in which the csv files are present
csv_files <- list.files('.', pattern = "\\.csv$")  #listing all the csv files in the folder

#writing csv data into DB
for (csv_file in csv_files) {
  df <- read.csv(file.path(folder, csv_file))  
  table_name <- gsub("\\.csv$", "", csv_file)
  dbWriteTable(con, table_name, df)
}
dbDisconnect(con)

```
### Datasets conents 
Each of the fixtures are represented uniquely by a FixtureKey. This is in a format:
“<Team 1> v <Team 2> <Date>”
Please note, that if the game is played at the home of one of the teams (IsNeutralSite=0), then Team 1 will be
listed as the home team.

1. box scores.csv
Box scores are tables that represent the match statistics at a player/team level. This dataset in particular, is displaying the main basketball statistics for each fixture, at the team level. There will be data on:
• Number of shots made
• Number of shots attempted
• Number of rebounds
• Number of shots assisted
• Number of defensive steals forced
• Number of opponent shots blocked
• Number of turnovers committed
• Number of fouls committed

2. fixture information.csv
Additional information of each of the fixtures that may be useful. The TipOff time is listed in Eastern Time. 

3. test fixtures.csv
The set of FixtureKeys on the 25th of February, 2023, to predict the fixture outcomes for.

5. test fixtures actuals.csv
This data shows what actually happened for the fixtures to predict, as well as some additional betting information provided by bookmakers. (Guide on TeamHandicap: -7.0
would mean that the team was predicted to win by 7 points, and +3.5 would mean that the team was predicted to lose by 3.5 points.)


more details regarding the project are in readme.text file-->  https://github.com/PHNX-MOD/Regression_SB/blob/main/readme.txt
