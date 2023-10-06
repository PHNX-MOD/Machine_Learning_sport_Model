library(tidymodels)
library(skimr)
library(rsample)
library(purrr)

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


df_box_score_query <- 
"WITH TeamAvTeamB AS (
    SELECT
        FixtureKey,
        SUBSTR(FixtureKey, 1, LENGTH(FixtureKey) - 12) AS TeamAvTeamB
    FROM
        box_scores
)
SELECT DISTINCT
    TeamAvTeamB.FixtureKey AS FixtureKey, 
    TRIM(CASE
            WHEN Team = 1 THEN SUBSTR(TeamAvTeamB, 1, INSTR(TeamAvTeamB, 'v') - 1)
            WHEN Team = 2 THEN SUBSTR(TeamAvTeamB, INSTR(TeamAvTeamB, 'v') + 1)
            ELSE NULL -- Handle other cases if needed
        END) AS TeamName,
    Team, X2PM, X2PA, X3PM, X3PA, FTM, FTA, ORB, DRB, AST, STL, BLK,TOV,
    PF,
    ROUND((CAST(X2PM AS REAL) + CAST(X3PM AS REAL)) / (CAST(X2PA AS REAL) + CAST(X3PA AS REAL))*100,2) AS 'FG%',
    ROUND((CAST(X2PM AS REAL) / CAST(X3PA AS REAL))*100,2)  AS'3P%',
    ROUND((CAST(FTM AS REAL) / CAST(FTA AS REAL))*100,2)  AS'FT%'
FROM
    TeamAvTeamB
    JOIN box_scores ON TeamAvTeamB.FixtureKey = box_scores.FixtureKey;"


df_box_scores <- dbGetQuery(df_box_score_query, con)




dbExecute(con, createTemp2Table)
dbGetQuery(con, joinTemp1Temp2)

















