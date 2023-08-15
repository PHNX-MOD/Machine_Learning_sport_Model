install.packages("RSQLite")
library(RSQLite)

con <- dbConnect(RSQLite::SQLite(), "mydatabase.db")
result <- dbGetQuery(con, "SELECT * FROM cbb")
dbDisconnect(con)



#changes to be made from replt
