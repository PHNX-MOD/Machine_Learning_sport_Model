# **Assessment of Basketball Model with a Focus on Quarter Performance**

The objective is to present the project which operates like a research paper, encompassing all stages of model development, starting from data acquisition and concluding with the presentation of the findings.
The paper deals with analysing the disparities between a traditional model and a model that relies on the outcomes influenced by various teams' performance in different quarters of a specific basketball league.

**IN PROGRESS(currently working): Refer section before [Authors](#Authors)

# Table of Contents
[About](#About) <br />
[Exploratory data analysis](#Exploratory-data-analysis) <br />
[Main Data](#Main-Data) <br />
[Authors](#Authors) <br />

## About
The aim is to create a machine-learning model using Python and R with front-end access using Shiny and Django frameworks. 
The overarching goal is to create a predictive model capable of unveiling the intricate relationship between various game-related features and the elusive outcomes of basketball matches. In pursuit of this objective, the algorithm is meticulously crafted using two of the most potent programming languages in data science and analysis, Python and R.

The algorithm's reach extends beyond its technical prowess, as it offers seamless access through both Shiny and Django frameworks, providing a user-friendly front-end interface that empowers enthusiasts, analysts, and decision-makers to harness the insights buried within the data.

As an initial step, the project delves into the rich repository of NCAA basketball data ( please refer [2.c Datasets contents](#Datasets-contents) ), serving as the foundation for an in-depth exploratory data analysis. This analysis not only unravels the intricacies of NCAA basketball but also lays the groundwork for the subsequent stages of model development and refinement. 

#### working files

Exploratory data analysis <br />
[main.R](https://phnx-mod.github.io/Machine_Learning_sport_Model/) <br />
[main.ipynb](https://github.com/PHNX-MOD/Machine_Learning_sport_Model/blob/main/main.ipynb)

#### Working Directories 
[Working App](https://vh3ewn-phnx0mod.shinyapps.io/cbbmodelrshiny/) <br />
https://github.com/PHNX-MOD/Machine_Learning_sport_Model/tree/main/CBBModelPyDjango

## Exploratory data analysis
The data((mydatabase.db) represents various fixture-level college basketball (NCAA Basketball / which is added to the database (mydatabase.db)) statistics from the past 2 years. 
The objective will be to build a model that is able to predict the winners for the fixtures on the SPECIFC DATE (**/**/****). Details of the dataset contents and goal is discussed in the section [2.c Datasets contents](#Datasets-contents)

### 2.a Data Preparation

The first step of any machine learning project is to analyse the raw data and use statistical methods to try and understand the meaning and relationships in the dataset. This requires that we check for any missing 
values and anomalies that would interfere with the either the splitting of the data and model building stage. And for this stage of the project only the 'box_scores' dataframe would be the most important as it contains the most relevant
and impactful stats that would help acheive the objective of predicting future results. Using libraries such as pandas and numpy in Python to manipulate these dataframes will be most efficient, while libraries such a skimr and tidymodels will be used in R. Writing all the csv data into a database using dbConnect in R, just as a practice to pull data from SQL
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
### 2.b Data Preprocessing
Instead of performing extensive data cleaning within SQL queries, the alternative code presented here in R and Python focuses on data preprocessing. Specifically, it addresses the task of splitting the columns in the df_box_score table, which are initially in the format **TeamA_v_TeamB**' into separate team names. This separation allows for more efficient and structured analysis of each team's aggregate statistics
```
=============================R code ========================================================

# ====================Method one splitString ===============================================

#df_box_scores is the table from box_scores SELECT * FROM box_scores;
dfBoxScores <-df_box_scores %>%rowwise()%>%
  mutate(
    SplittedString = strsplit(FixtureKey, " "),
    TeamAvTeamB = paste(unlist(SplittedString[-length(SplittedString)]), collapse = " ")
  )%>%
  mutate(TeamName = strsplit(TeamAvTeamB, "(?<!V)v", perl = TRUE)[[1]][Team])%>%
  mutate(TeamName = trimws(TeamName))%>%
  select(!TeamAvTeamB)%>%
  select(TeamName,FixtureKey,Team,X2PM,X2PA,X3PM,X3PA,FTM,FTA,ORB,DRB,AST,STL,BLK,TOV,PF)

# ====================Method two splitString ============================================

dfBoxScores2 <- df_box_scores %>%rowwise()%>%
  mutate(TeamAvTeamB = sub(" \\d{2}-\\w{3}-\\d{4}$", "", FixtureKey))%>%
  mutate(TeamName = strsplit(TeamAvTeamB, "(?<!V)v", perl = TRUE)[[1]][Team])%>%
  mutate(TeamName = trimws(TeamName))%>%
  select(!TeamAvTeamB)%>%
  select(TeamName,FixtureKey,Team,X2PM,X2PA,X3PM,X3PA,FTM,FTA,ORB,DRB,AST,STL,BLK,TOV,PF)

#============================Python ======================================================

#only missing of NA values in the dataframes is the handicap column in the df_test_fixtures_actuals
df_box_scores
df_fixture_info
df_test_fixtures
df_test_fixtures_actuals
df_test_fixtures_actuals.isna()
df_box_scores.describe()
df_box_scores_2 = pd.DataFrame()
df_box_scores_2['HomeTeam'] = df_box_scores['FixtureKey'].apply(lambda x:x.split(" v ")[0])
df_box_scores_2['AwayTeam'] = df_box_scores['FixtureKey'].apply(lambda x:x.split(" v ")[1])
df_box_scores_2['AwayTeam'] = df_box_scores_2['AwayTeam'].apply(lambda x:x.replace(x[-11:],""))
df_box_scores_2['Dates'] = df_box_scores['FixtureKey'].apply(lambda x: x.split(x[:-11])[1])
df_box_scores_2 = df_box_scores_2.set_index('Dates', drop=True)
for i in np.arange(2,len(df_box_scores.columns),1):
    df_box_scores_2[df_box_scores.columns[i]] = df_box_scores[df_box_scores.columns[i]].tolist()
df_box_scores_2['X2PM'].groupby(df_box_scores_2['HomeTeam']).mean()
df_box_scores_2['X2PM'].groupby(df_box_scores_2['AwayTeam']).mean()
```
### 2.c Datasets contents 
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

## Main Data
The cornerstone of our research lies in leveraging data obtained from the NBA API, which serves as the primary dataset for developing and refining our analytical model. Through meticulous analysis and interpretation of this data, we construct a robust model that encapsulates the intricate dynamics of basketball gameplay, facilitating insightful insights and informed decision-making within the realm of sports analytics.

### 3.a Dataset extraction

The NBA dataset is acquired using the nba-api library by installing it with the command !pip install nba_api in Python. The NBA API provides access to a vast pool of dataset. 
The endpoint used in the GetScoreBoard (getNBAScoreBoard.py) is ScoreboardV2 (nba_api/stats/endpoints/scoreboardv2.py).
The [getNBAScoreBoard.py](https://github.com/PHNX-MOD/Machine_Learning_sport_Model/blob/main/getNBAScoreBoard.py) file offers an overview of the data exploration necessary for modeling. <br />

The GetScoreBoard class in this file contains methods such as getDates(), which retrieves all NBA game dates for a specific year by passing the year as an argument to the class instance (e.g., GetScoreBoard('2018')). Using the list of dates obtained from getDates(), the getDayScore(gameDate) method facilitates the retrieval of all games played on a particular day by passing the date as an argument (e.g., getDayScore('2018-11-13')).<br />

Furthermore, the getScoreBoard() method utilizes getDayScore(gameDate) to iterate over all the dates from the specified year and retrieve all the necessary data.<br />

The scraped data is in JSON format, and the main interest lies in extracting the quarter scores of specific teams during an event.<br />

```
#import GetScoreBoard from getNBAScoreBoard.py
from getNBAScoreBoard import GetScoreBoard 


    # Example usage
    year = 2018  # Example year
    scoreboard = GetScoreBoard(year)

    # Call methods as needed
    dates = scoreboard.getDates()
    print("Game dates:", dates)

    gameDate = '2018-11-13'  # Example date
    day_score_df, load_scoreboard = scoreboard.getDayScore(gameDate)
    print("Day score DataFrame:", day_score_df)
    print("Loaded scoreboard:", load_scoreboard)

    scoreboard_df = scoreboard.getScoreBoard()
    print("Scoreboard DataFrame:", scoreboard_df)
```


## Authors 
 - Modith Hadya, MSc in Mechatronics, BTech in Automobile, Working as Systems Analyst in Pinnacle
 - Seán Mulvihill, Technological University Dublin, Bachelor of Science - BS (Hons), Physics Technology


## License
[MIT License](https://github.com/PHNX-MOD/Machine_Learning_sport_Model/blob/main/LICENSE)



