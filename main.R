library(RSQLite)
library(dplyr)
library(skimr)

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



#data Preprocessing 

skim(df_box_scores)
skim(df_fixture_information)
skim(df_test_fixtures)
skim(df_test_fixtures_actuals)

# box scores:  split into test and train

df_box_scores_split <- initial_split(df_box_scores)
df_box_scores_train <- training(df_box_scores_split)
df_box_scores_test <- testing(df_box_scores_split)

skim(df_box_scores_train)


# df_test_fixtures_actuals : split into test and train

df_test_fixtures_actuals_split <- initial_split(df_test_fixtures_actuals)
df_test_fixtures_actuals_train <- training(df_test_fixtures_actuals_split)
df_test_fixtures_actuals_test <- testing(df_test_fixtures_actuals_split)

#checking missing values
skim(df_test_fixtures_actuals_train)
any(is.na(df_test_fixtures_actuals_train))
colSums(is.na(df_test_fixtures_actuals_train)) #TeamHandicap NA values 


