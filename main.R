install.packages("RSQLite")
library(RSQLite)
con <- dbConnect(SQLite(), dbname = "porsche")
query <- 'SELECT * FROM demo;'
data <- dbGetQuery(con, query)

sqldbDisconnect(con)

#changes to be made
