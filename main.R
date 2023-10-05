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


df_box_score_query <- "
WITH TeamAvTeamB AS (
    SELECT
        FixtureKey,
        SUBSTR(FixtureKey, 1, LENGTH(FixtureKey) - 12) AS TeamAvTeamB
    FROM
        box_scores
)
SELECT
    TeamAvTeamB.FixtureKey AS FixtureKey, 
    TRIM(CASE
            WHEN Team = 1 THEN SUBSTR(TeamAvTeamB, 1, INSTR(TeamAvTeamB, 'v') - 1)
            WHEN Team = 2 THEN SUBSTR(TeamAvTeamB, INSTR(TeamAvTeamB, 'v') + 1)
            ELSE NULL -- Handle other cases if needed
        END) AS TeamName,
    Team,X2PM,X2PA,X3PM,X3PA,FTM,FTA,ORB,DRB,AST,STL,BLK,TOV,PF
FROM
    TeamAvTeamB
    JOIN box_scores ON TeamAvTeamB.FixtureKey = box_scores.FixtureKey;"


df_box_scores <- dbGetQuery(df_box_score_query, con)


"1. **Shooting Percentages**:
   - Calculate the Field Goal Percentage (FG%) for each team. FG% is the ratio of successful field goals (2PM + 3PM) to total field goal attempts (2PA + 3PA)."





" - Calculate the Three-Point Percentage (3P%) for each team. 3P% is the ratio of successful three-pointers (3PM) to total three-point attempts (3PA).
   - Calculate the Free Throw Percentage (FT%) for each team. FT% is the ratio of successful free throws (FTM) to total free throw attempts (FTA).

2. **Rebound Differential**:
   - Calculate the Offensive Rebound Differential (ORD) for each team. ORD is the difference between the average offensive rebounds (ORB) a team secures and the average offensive rebounds their opponents secure.
   - Calculate the Defensive Rebound Differential (DRD) for each team. DRD is the difference between the average defensive rebounds (DRB) a team secures and the average defensive rebounds their opponents secure.

3. **Assist-to-Turnover Ratio**:
   - Calculate the Assist-to-Turnover Ratio (AST/TOV) for each team. This ratio measures a team's ball-handling efficiency. It's the ratio of assists (AST) to turnovers (TOV).

4. **Steal and Block Averages**:
   - Calculate the average number of steals (STL) and blocks (BLK) for each team. These metrics can represent a team's defensive capabilities.

5. **Foul Differential**:
   - Calculate the average difference in the number of fouls committed (PF) between a team and its opponents. This can indicate a team's discipline on the court.

6. **Historical Performance**:
   - Consider incorporating historical performance metrics. For example, calculate the team's win-loss record over a certain number of previous games.

7. **Home Court Advantage**:
   - If applicable, include a binary feature that indicates whether the game was played at the home court of one of the teams. Home court advantage can significantly impact game outcomes.

8. **Day of the Week**:
   - Extract the day of the week from the date and include it as a categorical feature. Some teams may perform differently on specific days.

9. **Opponent Strength**:
   - Consider including a feature that measures the strength of the opponent. This can be based on the opponent's win-loss record, rankings, or other relevant metrics.

10. **Time Since Last Game**:
    - Calculate the number of days since each team's last game. Fatigue can play a role in performance."





dbExecute(con, createTemp2Table)
dbGetQuery(con, joinTemp1Temp2)

















