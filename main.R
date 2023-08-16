install.packages("RSQLite")
library(RSQLite)

con <- dbConnect(RSQLite::SQLite(), "mydatabase.db")
result <- dbGetQuery(con, "SELECT * FROM cbb")
dbDisconnect(con)



#list of tables 
Sql_tables <- c("cbb", "cbb13", "cbb14", "cbb15",
               "cbb16", "cbb17" ,"cbb18", "cbb19",
               "cbb20" ,"cbb21", "cbb22" ,"cbb23")
