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

