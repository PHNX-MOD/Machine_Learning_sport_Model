library(tidymodels)
library(skimr)
library(rsample)
library(purrr)
library(recipes)
library(caret)
library(ggplot2)
library(pROC)
library(RSQLite)


con <- dbConnect(RSQLite::SQLite(), "mydatabase.db")



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

dbDisconnect(con)


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



#==============winner Prediction model ====================================================================

data <- Final_Score %>%select(!FixtureKey)%>%
  mutate(Winner = if_else(Home_score > Away_score, 1, 0))

dataSplit <- initial_split(data)
dataTrain <- training(dataSplit)
dataTest <- testing(dataSplit)


#hot coding using recipe library

training_recipe <- recipe(Winner ~ ., data=dataTrain) %>%
  step_dummy(Home, Away) %>%
  prep()
  

encoded_training_data <- bake(training_recipe, dataTrain)

#Regression prediction model

winner_prediction_model <- glm(Winner ~ ., family=binomial, data=encoded_training_data)


#check for the NA values / residuals tune the model 

winner_predictions <- predict(winner_prediction_model, newdata=dataTest, type="response")

threshold <- 0.5
predicted_classes <- ifelse(winner_predictions > threshold, 1, 0)

confusionMatrix(as.factor(predicted_classes), as.factor(dataTest$Winner))


predicted_classes <- ifelse(predicted_probabilities > threshold, 1, 0)

#plot & evaluate the model

observed_values <- dataTest$Winner

winner_predictions <- winner_predictions[!is.na(winner_predictions)]
observed_values <- observed_values[!is.na(observed_values)]

rmse_winner <- sqrt(mean((winner_predictions - observed_values)^2))

#plot 
roc_obj <- roc(observed_values, winner_predictions)

ggplot(data = data.frame(
  FPR = roc_obj$specificities,
  TPR = roc_obj$sensitivities
)) +
  geom_line(aes(x = FPR, y = TPR), color="blue") +
  geom_abline(intercept = 0, slope = 1, color="gray") +
  ggtitle("ROC Curve") +
  labs(x="False Positive Rate (1-Specificity)", y="True Positive Rate (Sensitivity)") +
  annotate("text", x = 0.3, y = 0.2, label = paste("AUC =", round(auc(roc_obj), 2)))



#==============Prediction model ==================================end================ 
  

#==============Score prediction model ============================================

Final_ScoreAvgScores <-  merge(Final_Score, dfboxscoresMean, by.x = "Home", by.y = "TeamName", all.x = TRUE)%>%rename(HomeScoreAvg = Base_score)%>%select(-FixtureKey)
Final_ScoreAvgScores <- merge(Final_ScoreAvgScores, dfboxscoresMean, by.x = "Away", by.y = "TeamName", all.x = TRUE)%>%rename(AwayScoreAvg = Base_score)

Final_ScoreAvgScores <- Final_ScoreAvgScores%>%select(Home, Away, HomeScoreAvg, AwayScoreAvg, Home_score, Away_score)



#home prediction 

Home_recipe <- recipe(Home_score ~ Home + Away + HomeScoreAvg + AwayScoreAvg, data=Final_ScoreAvgScores) %>%
  step_dummy(Home, Away, one_hot=TRUE) %>%
  step_normalize(HomeScoreAvg, AwayScoreAvg) %>%
  prep()

processed_Home_data  <- juice(Home_recipe)

dataSplitHome <- initial_split(processed_Home_data)
dataTrainHome <- training(dataSplitHome)
dataTestHome <- testing(dataSplitHome)


model_home <- lm(Home_score ~ ., data=dataTrainHome)

predicted_home_scores_test <- predict(model_home, newdata=dataTestHome)

#plotting the graph / Evaluate the models 
comparison_data_home <- data.frame(Actual = dataTestHome$Home_score, Predicted = predicted_home_scores_test)

ggplot(comparison_data_home, aes(x = Actual, y = Predicted)) + 
  geom_point() + 
  geom_smooth(method = "lm", se = FALSE, color = "red") + 
  ggtitle("Actual vs Predicted Home Scores") + 
  xlab("Actual Home Scores") + 
  ylab("Predicted Home Scores")

residuals_home <- comparison_data$Actual - comparison_data$Predicted
valid_residuals_home <- residuals_home[!is.na(residuals_home)]
rmse_home <- sqrt(mean(valid_residuals^2))



#away prediction
Away_recipe <- recipe(Away_score ~ Home + Away + HomeScoreAvg + AwayScoreAvg, data=Final_ScoreAvgScores) %>%
  step_dummy(Home, Away) %>%
  step_normalize(HomeScoreAvg, AwayScoreAvg) %>%
  prep()


processed_Away_data <- juice(Away_recipe)


dataSplitAway <- initial_split(processed_Away_data)
dataTrainAway <- training(dataSplitAway)
dataTestAway <- testing(dataSplitAway)

model_away <- lm(Away_score ~ ., data=dataTrainAway)

predicted_away_scores_test <- predict(model_away, newdata =dataTestAway )


#plot / evaluate the model

comparison_data_away <- data.frame(Actual = dataTestAway$Away_score, Predicted = predicted_away_scores_test)

ggplot(comparison_data_away, aes(x=Actual, y= Predicted))+
  geom_point()+
  geom_smooth(method = "lm", se = FALSE, color = "red")+
  ggtitle("Actual vs Predicted Away Scores") + 
  xlab("Actual Away Scores") + 
  ylab("Predicted Away Scores")

residuals_away <- comparison_data_away$Actual -comparison_data_away$Predicted
valid_residuals_away <- residuals_away[!is.na(residuals_away)]
rmse_away <- sqrt(mean(valid_residuals_away^2))
  
#==============Score prediction model END============================================

#===============Score Prediction ===================================

df_test_fixtures <- df_test_fixtures%>%rowwise()%>%
  mutate(
    SplittedString = strsplit(FixtureKey, " "),
    TeamAvTeamB = paste(unlist(SplittedString[-length(SplittedString)]), collapse = " ")
  )%>%
  mutate(Home = strsplit(TeamAvTeamB, "(?<!V)v", perl = TRUE)[[1]][1],
         Away = strsplit(TeamAvTeamB, "(?<!V)v", perl = TRUE)[[1]][2],
         Home =  trimws(Home),
         Away = trimws(Away),
         Date = strsplit(FixtureKey, " ")[[1]]
         [length(strsplit(FixtureKey, " ")[[1]])]
  )%>%
  select(Date, Home, Away)

upcoming_match <- df_test_fixtures%>%select(!Date)




upcoming_match <-  merge(upcoming_match, dfboxscoresMean, by.x = "Home", by.y = "TeamName", all.x = TRUE)%>%rename(HomeScoreAvg = Base_score)
upcoming_match <- merge(upcoming_match, dfboxscoresMean, by.x = "Away", by.y = "TeamName", all.x = TRUE)%>%rename(AwayScoreAvg = Base_score)

#predicted_home_scores=================================

processed_upcoming_fixture_home <- bake(Home_recipe, new_data = upcoming_match)
predicted_home_scores <- predict(model_home, newdata=processed_upcoming_fixture_home)


#predicted_away_scores=======================================

processed_upcoming_fixture_away <- bake(Away_recipe, new_data = upcoming_match)


#(predvars, data, env) : object 'Home_ABILCH' not found, adding a  column filled with zero
missing_cols <- setdiff(names(processed_Away_data), names(processed_upcoming_fixture_away))
for(col in missing_cols) {
  processed_upcoming_fixture_away[[col]] <- 0
}

predicted_away_scores <- predict(model_away, newdata=processed_upcoming_fixture_away)



upcoming_match_with_scores  <- cbind(upcoming_match, predicted_home_scores, predicted_away_scores)%>%
  select(!c(HomeScoreAvg,AwayScoreAvg))%>%
  mutate(across(everything(), ~replace_na(.x, 0)))%>%
  rename(Home_score = predicted_home_scores, Away_score = predicted_away_scores)


encoded_upcoming_matches <- bake(training_recipe, upcoming_match_with_scores)

predicted_outcome <- predict(winner_prediction_model, newdata=encoded_upcoming_matches, type="response")
predicted_winner <- ifelse(predicted_outcome > 0.5, "Home", "Away")


upcoming_fixture_predictions <- cbind(upcoming_match_with_scores, predicted_winner)
upcoming_fixture_predictions <- upcoming_fixture_predictions%>%mutate(Home_score = round(Home_score, 2),
                                      Away_score = round(Away_score , 2),
                                      Spread = Away_score-Home_score,
                                      Totals = Away_score+Home_score)



#calculating the winning percentage based on spread 

spread <- c(1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5, 15, 15.5, 16, 16.5, 17, 17.5, 18, 18.5, 19)
win_percentage <- c(0.517, 0.533, 0.574, 0.573, 0.573, 0.587, 0.651, 0.654, 0.664, 0.695, 0.698, 0.719, 0.750, 0.740, 0.806, 0.802, 0.783, 0.843, 0.843, 0.858, 0.868, 0.875, 0.879, 0.895, 0.884, 0.937, 0.890, 0.945, 0.912, 0.948, 0.910, 0.944, 0.933, 0.961, 0.950, 0.959, 1.000)

win_per_table <- data.frame(spread, win_percentage)



# Function to interpolate Win% for a given spread
interpolate_win_percentage <- function(spread_val, win_per_table) {
  # If spread greater than 19, return NA
  if (spread_val > 19) {
    return(NA_real_)
  }
  
  lower_row <- win_per_table %>% filter(spread <= spread_val) %>% arrange(desc(spread)) %>% slice(1)
  upper_row <- win_per_table %>% filter(spread > spread_val) %>% arrange(spread) %>% slice(1)
  
  if (nrow(lower_row) == 0) {
    return(upper_row$win_percentage)
  }
  if (nrow(upper_row) == 0) {
    return(lower_row$win_percentage)
  }
  
  x1 <- lower_row$spread
  y1 <- lower_row$win_percentage
  x2 <- upper_row$spread
  y2 <- upper_row$win_percentage
  
  # Interpolation formula
  y = y1 + ((spread_val - x1) * (y2 - y1)) / (x2 - x1)
  
  return(y)
}

# Mutate upcoming_fix with the interpolated Win%
upcoming_fix <- upcoming_fixture_predictions %>%
  rowwise() %>%
  mutate(WinPercentage = interpolate_win_percentage(abs(Spread),win_per_table ))












