con <- dbConnect(RSQLite::SQLite(), "mydatabase.db")


con <- dbConnect(RSQLite::SQLite(), "mydatabase.db")
result <- dbGetQuery(con, "SELECT * FROM box_scores")
dbDisconnect(con)


folder <- "."

#Get a list of the CSV files in the folder
csv_files <- list.files('.', pattern = "\\.csv$")


for (csv_file in csv_files) {
  df <- read.csv(file.path(folder, csv_file))
  
  table_name <- gsub("\\.csv$", "", csv_file)
  
  dbWriteTable(con, table_name, df)
}



df <- read.csv('box_scores.csv')

dbWriteTable(con, 'box_scores' , df)

gsub("\\.csv$", "", "box_scores.csv")


#try this 


