
con <- dbConnect(RSQLite::SQLite(), "mydatabase.db")
result <- dbGetQuery(con, "SELECT * FROM box_scores")
dbDisconnect(con)





