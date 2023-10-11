library(tidymodels)
library(skimr)
library(rsample)
library(purrr)
library(recipes)

starwars

skim(starwars)
view(starwars)


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


# ====================Method one splitString ===============================================

dfBoxScores <-df_box_scores %>%rowwise()%>%
  mutate(
    SplittedString = strsplit(FixtureKey, " "),
    TeamAvTeamB = paste(unlist(SplittedString[-length(SplittedString)]), collapse = " ")
  )%>%
  mutate(TeamName = strsplit(TeamAvTeamB, "(?<!V)v", perl = TRUE)[[1]][Team])%>%
  mutate(TeamName = trimws(TeamName))%>%
  select(!TeamAvTeamB)%>%
  select(TeamName,FixtureKey,Team,X2PM,X2PA,X3PM,X3PA,FTM,FTA,ORB,DRB,AST,STL,BLK,TOV,PF)

dfBoxScores<- dfBoxScores%>%group_by(TeamName)%>%
  summarise(X2PA = mean(X2PA))


# ====================Methods two splitString ============================================



dfBoxScores2 <- df_box_scores %>%rowwise()%>%
  mutate(TeamAvTeamB = sub(" \\d{2}-\\w{3}-\\d{4}$", "", FixtureKey))%>%
  mutate(TeamName = strsplit(TeamAvTeamB, "(?<!V)v", perl = TRUE)[[1]][Team])%>%
  mutate(TeamName = trimws(TeamName))%>%
  select(!TeamAvTeamB)%>%
  select(TeamName,FixtureKey,Team,X2PM,X2PA,X3PM,X3PA,FTM,FTA,ORB,DRB,AST,STL,BLK,TOV,PF)



con <- dbConnect(RSQLite::SQLite(), "mydatabase.db")


dbExecute(con, createTemp2Table)
dbGetQuery(con, qurt1)

#==========================================================query======================

qurt1 <- 
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

--Joining Final CTE from BOX score table with fixture_information

 SELECT FinalCTE.FixtureKey, FinalCTE.TeamName ,FinalCTE.Oppnent, FinalCTE.'FG%',FinalCTE.'3P%',
 FinalCTE.'FT%', FinalCTE.'ASTtoTOV%',
 (FinalCTE.ORBAvg-FinalCTE.OppORBAvg) AS ORD,
 (FinalCTE.DRBAvg-FinalCTE.OppDRBAvg) AS DRD,
 FinalCTE.STLAvg ,FinalCTE.BLKAvg,
 (FinalCTE.PFAvg-FinalCTE.OppPFAvg) AS DiffPFAvg, 
 FinalCTE.HomeTeamAdv,
 fixture_information.TipOff AS TipOff,             
 fixture_information.GameType AS GameType, 
 fixture_information.IsNeutralSite AS IsNeutralSite,
 fixture_information.Attendance AS Attendance,
 fixture_information.Season AS Season,
 fixture_information.Team1Conference AS Team1Conference,
 fixture_information.Team2Conference AS Team2Conference
 FROM
     FinalCTE
 JOIN fixture_information ON FinalCTE.FixtureKey = fixture_information.FixtureKey
"
#==========================================================queryEND======================

dfBoxScoresFromQuery <- dbGetQuery(con, qurt1)




fiter_box_scoreFun <- function(df){
  df%>%rowwise()%>%
    mutate(Date = strsplit(FixtureKey, " ")[[1]]
           [length(strsplit(FixtureKey, " ")[[1]])])%>%
    mutate(Day = weekdays(as.Date(Date, format="%d-%b-%Y")))%>%
    mutate(
      HomeTeamAdv = 
        if(HomeTeamAdv =="Yes" & IsNeutralSite == 0){
          "Yes"
        } else if (HomeTeamAdv =="No" & IsNeutralSite == 1) {
          "No"
        } else if (HomeTeamAdv =="Yes" & IsNeutralSite == 1) {
          "No"
        } else if (HomeTeamAdv =="No" & IsNeutralSite == 0) {
          "No"
        }
    )%>%
    #adding home advantage factor
    mutate(HomeTeamAdv = ifelse(HomeTeamAdv == "Yes", 1, 0) * 0.05)%>%
    #calculating base score
    mutate(Base_score = ((`FG%`*0.3) + (`3P%`*0.2)+(`FT%`*0.1)+(`ASTtoTOV%`*0.2)+
                           (ORD*0.05)+(DRD*0.05)+(STLAvg*0.03)+(BLKAvg*0.02)+(DiffPFAvg*0.03)+HomeTeamAdv))%>%
    #adding attendance factor
    mutate(Base_score = Base_score*ifelse(Attendance == 0, 1, 1+0.05*(Attendance/max(Attendance))))%>%
    #adding home GameType factor
    mutate(Base_score = case_when(
      GameType == "RegularSeason" ~ 1.0*Base_score,
      GameType == "ConferenceChampionship" ~ 1.1*Base_score,
      GameType == "NIT" ~ 1.2*Base_score,
      TRUE ~ 1.0*Base_score))%>%
    mutate(time_multiplier = as.integer(strsplit(TipOff[1],":")[[1]][1]))%>%
    mutate(Base_score = case_when(
      time_multiplier >= 6 & time_multiplier < 12 ~ 0.98*Base_score,
      time_multiplier >= 12 & time_multiplier < 17 ~ 1*Base_score,
      time_multiplier >= 17 & time_multiplier < 21 ~ 1.02*Base_score,
      TRUE ~ 1.01*Base_score
    ))%>%mutate(Base_score = case_when(
      Day == "Monday"~ 1.0*Base_score,
      Day == "Tuesday"~ 1.0*Base_score,
      Day == "Wednesday"~ 1.0*Base_score,
      Day == "Thursday"~ 1.0*Base_score,
      Day == "Friday"~ 1.01*Base_score,
      Day == "Saturday"~ 1.02*Base_score,
      Day == "Sunday"~ 1.01*Base_score
    ))%>%select(FixtureKey, TeamName,Oppnent,Base_score)
}

dfBoxScores <- fiter_box_scoreFun(dfBoxScoresFromQuery)

dfBoxScoresHome<- dfBoxScoresFromQuery%>%filter(HomeTeamAdv == "Yes")
dfBoxScoresHome <- fiter_box_scoreFun(dfBoxScoresHome)

dfBoxScoresAway<- dfBoxScoresFromQuery%>%filter(HomeTeamAdv == "No")
dfBoxScoresAway <- fiter_box_scoreFun(dfBoxScoresAway)


Final_Score <- merge(dfBoxScoresHome%>%rename(Home = TeamName, Away=Oppnent, Home_score = Base_score),
                     dfBoxScoresAway%>%rename(Away = TeamName, Home=Oppnent, Away_score = Base_score))%>%
  mutate(Home_score = round(Home_score,2),
         Away_score = round(Away_score,2))
  

dfboxscoresMean <- rbind(dfBoxScoresHome%>%select(-Oppnent, -FixtureKey),dfBoxScoresAway%>%select(-Oppnent, -FixtureKey ))%>%
  group_by(TeamName)%>%summarise(Base_score = mean(Base_score))

dfboxscoreMeadian <- rbind(dfBoxScoresHome%>%select(-Oppnent, -FixtureKey),dfBoxScoresAway%>%select(-Oppnent, -FixtureKey ))%>%
  group_by(TeamName)%>%summarise(Base_score = median(Base_score))



#==============feature ====================================================================



data <- Final_Score %>%
  mutate(Winner = if_else(Home_score > Away_score, 1, 0))



# One-hot encoding for 'Home' teams
home_encoded <- model.matrix(~ Home - 1, data=data)

# One-hot encoding for 'Away' teams
away_encoded <- model.matrix(~ Away - 1, data=data)

# Combining the encoded matrices with the original dataset
data_encoded <- as.data.frame(cbind(data, home_encoded, away_encoded))



normalize <- function(feature){(feature-mean(feature))/sd(feature)}

home_encoded %>% mutate_all(normalize)





model <- glm(Winner ~ . - FixtureKey - Home - Away - Home_score - Away_score, 
             data=data_encoded, family=binomial(link="logit"))

summary(model)

predicted_probs <- predict(model, newdata=data, type="response")

predicted_classes <- ifelse(predicted_probs > 0.5, 1, 0)
  
  
  
#==============feature ==================================eng================ 
  
  
  
  
  
Feature Engineering:
  
Create new features based on the outcomes of previous games. For instance, you can create features like RecentWinStreak, RecentLossStreak, WinRateLast5Games, AveragePerformanceScoreLast5Games, etc.
Incorporate the outcomes of the games (win/lose) to calculate new performance metrics for teams. 
This can include an updated average performance score, total wins, total losses, etc.



















