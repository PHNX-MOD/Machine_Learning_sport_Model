# Machine Learning Sport model

# Table of Contents
[About](#About)
[Exploratory data analysis](#Exploratory data analysis)

## About
The aim is to create a machine-learning model using Python and R with front-end access using Shiny and Django frameworks. 

## working files
[main.R](https://github.com/PHNX-MOD/Machine_Learning_sport_Model/blob/main/main.R) & [mainPython.ipynb](https://github.com/PHNX-MOD/Machine_Learning_sport_Model/blob/main/mainPython.ipynb)

## Working Directories 
https://github.com/PHNX-MOD/Machine_Learning_sport_Model/tree/main/CBBModelPyDjango
https://github.com/PHNX-MOD/Machine_Learning_sport_Model/tree/main/CBBModelRShiny

## Exploratory data analysis
 2 years of NCAA data is added into the database (mydatabase.db)
 ```con <- dbConnect(RSQLite::SQLite(), "mydatabase.db")
    folder <- "."
    csv_files <- list.files('.', pattern = "\\.csv$")
for (csv_file in csv_files) {
  df <- read.csv(file.path(folder, csv_file))
  
  table_name <- gsub("\\.csv$", "", csv_file)
  
  dbWriteTable(con, table_name, df)
}



```




present setup and working https://www.kaggle.com/datasets/andrewsundberg/college-basketball-dataset?select=cbb.csv
more details regarding the project are in readme.text file-->  https://github.com/PHNX-MOD/Regression_SB/blob/main/readme.txt
