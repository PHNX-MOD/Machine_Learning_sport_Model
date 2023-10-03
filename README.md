# Machine Learning Sport model

# Table of Contents
[1.About](#About) <br />
[2.Exploratory data analysis](#Exploratory-data-analysis)

## 1.About
The aim is to create a machine-learning model using Python and R with front-end access using Shiny and Django frameworks. 
The overarching goal is to create a predictive model capable of unveiling the intricate relationship between various game-related features and the elusive outcomes of basketball matches. In pursuit of this objective, the algorithm is meticulously crafted using two of the most potent programming languages in data science and analysis, Python and R.

The algorithm's reach extends beyond its technical prowess, as it offers seamless access through both Shiny and Django frameworks, providing a user-friendly front-end interface that empowers enthusiasts, analysts, and decision-makers to harness the insights buried within the data.

As an initial step, the project delves into the rich repository of NCAA basketball data, serving as the foundation for an in-depth exploratory data analysis. This analysis not only unravels the intricacies of NCAA basketball but also lays the groundwork for the subsequent stages of model development and refinement.

#### working files

Exploratory data analysis <br />
[main.R](https://github.com/PHNX-MOD/Machine_Learning_sport_Model/blob/main/main.R) <br />
[main.ipynb](https://github.com/PHNX-MOD/Machine_Learning_sport_Model/blob/main/main.ipynb)

#### Working Directories 
https://github.com/PHNX-MOD/Machine_Learning_sport_Model/tree/main/CBBModelPyDjango
https://github.com/PHNX-MOD/Machine_Learning_sport_Model/tree/main/CBBModelRShiny

## 2.Exploratory data analysis
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
Writing all the csv data into a database using dbConnect in python, 
```
# Folder containing the CSV files
folder = "."

# Get a list of the CSV files in the folder
csv_files = [f for f in os.listdir(folder) if f.endswith(".csv")]

# Connect to the database
db_connection = sqlite3.connect('mydatabase.db')

for csv_file in csv_files:
    df = pd.read_csv(os.path.join(folder, csv_file))   # Read the CSV file into a DataFrame   
    table_name = os.path.splitext(csv_file)[0]         # Extract the table name from the CSV file name    
    df.to_sql(table_name, db_connection, if_exists='replace', index=False)  # Write the DataFrame to the SQLite database

db_connection.close()

```
Lot of cleaning is done in the SQL query instead of dplyr or Pandas. The alternate code is added here in R(dplyr)
```
# ====================Method one splitString ===============================================
#df_box_scores is the table from box_scores SELECT * FROM box_scores;
dfBoxScores <-df_box_scores %>%rowwise()%>%
  mutate(
    SplittedString = strsplit(FixtureKey, " "),
    TeamAvTeamB = paste(unlist(SplittedString[-length(SplittedString)]), collapse = " ")
  )%>%
  mutate(TeamName = strsplit(TeamAvTeamB, "(?<!V)v", perl = TRUE)[[1]][Team])%>%
  select(!TeamAvTeamB)%>%
  select(TeamName,FixtureKey,Team,X2PM,X2PA,X3PM,X3PA,FTM,FTA,ORB,DRB,AST,STL,BLK,TOV,PF)

# ====================Methods two splitString ============================================

dfBoxScores <- df_box_scores %>%rowwise()%>%
  mutate(TeamAvTeamB = sub(" \\d{2}-\\w{3}-\\d{4}$", "", FixtureKey))%>%
  mutate(TeamName = strsplit(TeamAvTeamB, "(?<!V)v", perl = TRUE)[[1]][Team])%>%
  select(!TeamAvTeamB)%>%
  select(TeamName,FixtureKey,Team,X2PM,X2PA,X3PM,X3PA,FTM,FTA,ORB,DRB,AST,STL,BLK,TOV,PF)
```




#### 2.a Datasets contents 
Each of the fixtures are represented uniquely by a FixtureKey. This is in a format:
“<Team 1> v <Team 2> <Date>”
Please note, that if the game is played at the home of one of the teams (IsNeutralSite=0), then Team 1 will be
listed as the home team.

1. box scores.csv
Box scores are tables that represent the match statistics at a player/team level. This dataset in particular, is displaying the main basketball statistics for each fixture, at the team level. There will be data on:<br />
• Number of shots made<br/>
• Number of shots attempted <br />
• Number of rebounds <br />
• Number of shots assisted <br />
• Number of defensive steals forced <br />
• Number of opponent shots blocked <br />
• Number of turnovers committed <br />
• Number of fouls committed <br />

2. fixture information.csv
Additional information of each of the fixtures that may be useful. The TipOff time is listed in Eastern Time. 

3. test fixtures.csv
The set of FixtureKeys on the 25th of February, 2023, to predict the fixture outcomes for.

5. test fixtures actuals.csv
This data shows what actually happened for the fixtures to predict, as well as some additional betting information provided by bookmakers. (Guide on TeamHandicap: -7.0
would mean that the team was predicted to win by 7 points, and +3.5 would mean that the team was predicted to lose by 3.5 points.)

#### 2.b Data Preparation
The first step of any machine learning project is to analyse the raw data and use statistical methods to try and understand the meaning and relationships in the dataset. This requires that we check for any missing 
values and anomalies that would prevent us from using all methods at our disposal. And for this stage of the project only the 'box_scores' dataframe would be the most important as it contains the most relevant
and impactful stats that would help acheive the objective of predicting future results. Using libraries such as pandas and numpy in Python to manipulate these dataframes will be most efficient, while libraries such a skimr and tidymodels will be used in R.


more details regarding the project are in readme.text file-->  https://github.com/PHNX-MOD/Regression_SB/blob/main/readme.txt
