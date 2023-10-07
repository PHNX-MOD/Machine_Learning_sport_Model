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
        bs.FixtureKey,
        SUBSTR(bs.FixtureKey, 1, LENGTH(bs.FixtureKey) - 12) AS TeamAvTeamB
    FROM
        box_scores AS bs
)

-- Query 1 as a CTE
, Query1 AS (
    SELECT DISTINCT
        TRIM(CASE
                WHEN bs.Team = 1 THEN SUBSTR(TeamAvTeamB, 1, INSTR(TeamAvTeamB, 'v') - 1)
                WHEN bs.Team = 2 THEN SUBSTR(TeamAvTeamB, INSTR(TeamAvTeamB, 'v') + 1)
                ELSE NULL
            END) AS TeamName,  
        AVG(bs.ORB) AS ORBAvg,
        AVG(bs.DRB) AS DRBAvg,
        AVG(bs.STL) AS STLAvg,
        AVG(bs.BLK) AS BLKAvg,
        AVG(bs.PF) AS PFAvg
        
    FROM
        TeamAvTeamB AS ta
    JOIN box_scores AS bs ON ta.FixtureKey = bs.FixtureKey
    GROUP BY
        TeamName
)

-- Query 2 as a CTE
, Query2 AS (
    SELECT
        bs.FixtureKey,
        TRIM(CASE
                WHEN bs.Team = 1 THEN SUBSTR(TeamAvTeamB, 1, INSTR(TeamAvTeamB, 'v') - 1)
                WHEN bs.Team = 2 THEN SUBSTR(TeamAvTeamB, INSTR(TeamAvTeamB, 'v') + 1)
                ELSE NULL
            END) AS TeamName,
        TRIM(CASE
                WHEN bs.Team = 2 THEN SUBSTR(TeamAvTeamB, 1, INSTR(TeamAvTeamB, 'v') - 1)
                WHEN bs.Team = 1 THEN SUBSTR(TeamAvTeamB, INSTR(TeamAvTeamB, 'v') + 1)
                ELSE NULL
            END) AS Oppnent,
            CASE
              WHEN bs.Team = 1 THEN 'Yes'
              WHEN bs.TeaM = 2 THEN 'No'
              ELSE NULL
              END AS HomeTeamAdv,
        bs.Team, bs.X2PM, bs.X2PA, bs.X3PM, bs.X3PA, bs.FTM, bs.FTA, bs.ORB, bs.DRB, bs.AST, bs.STL, bs.BLK, bs.TOV,
        bs.PF,
        ROUND((CAST(bs.X2PM AS REAL) + CAST(bs.X3PM AS REAL)) / (CAST(bs.X2PA AS REAL) + CAST(bs.X3PA AS REAL))*100,2) AS 'FG%',
        ROUND((CAST(bs.X2PM AS REAL) / CAST(bs.X3PA AS REAL))*100,2)  AS '3P%',
        ROUND((CAST(bs.FTM AS REAL) / CAST(bs.FTA AS REAL))*100,2)  AS 'FT%',
        ROUND((CAST(bs.AST AS REAL) / CAST(bs.TOV AS REAL))*100,2)  AS 'ASTtoTOV%'
    FROM
        TeamAvTeamB AS ta
    JOIN box_scores AS bs ON ta.FixtureKey = bs.FixtureKey
)

-- CTE3  Query joining Query1 and Query2 using TeamName
, FinalCTE AS (SELECT DISTINCT
    Query2.FixtureKey, Query2.TeamName,Query2.Oppnent, Query2.HomeTeamAdv, Query2.Team,Query2.X2PM, Query2.X2PA, Query2.X3PM, Query2.X3PA,Query2.FTM, Query2.FTA,
    Query2.ORB,Query2.DRB,Query2.AST,Query2.STL,Query2.BLK,Query2.TOV, Query2.PF,Query2.'FG%', Query2.'3P%',Query2.'FT%',Query2.'ASTtoTOV%',
    ROUND(Query1.ORBAvg, 2) AS ORBAvg,
    ROUND(Query3.ORBAvg, 2 ) AS OppORBAvg,
    ROUND(Query1.DRBAvg, 2) AS DRBAvg,
    ROUND(Query3.DRBAvg, 2) AS OppDRBAvg,
    ROUND(Query1.STLAvg, 2) AS STLAvg,
    ROUND(Query1.BLKAvg, 2) AS BLKAvg,
    ROUND(Query1.PFAvg, 2) AS PFAvg,
    ROUND(Query3.PFAvg, 2) AS OppPFAvg
    
FROM
    Query1
JOIN Query2 ON Query1.TeamName = Query2.TeamName
JOIN Query1 AS Query3 ON Query2.Oppnent = Query3.TeamName

)
 SELECT FinalCTE.FixtureKey, FinalCTE.TeamName ,FinalCTE.Oppnent, FinalCTE.'FG%',FinalCTE.'3P%',
 FinalCTE.'FT%', FinalCTE.'ASTtoTOV%',
 (FinalCTE.ORBAvg-FinalCTE.OppORBAvg) AS ORD,
 (FinalCTE.DRBAvg-FinalCTE.OppDRBAvg) AS DRD,
 FinalCTE.STLAvg ,FinalCTE.BLKAvg,
 (FinalCTE.PFAvg-FinalCTE.OppPFAvg) AS DiffPFAvg, 
 FinalCTE.HomeTeamAdv
 FROM
  FinalCTE;"


df_box_scores <- dbGetQuery(df_box_score_query, con)




dbExecute(con, createTemp2Table)
dbGetQuery(con, joinTemp1Temp2)

















