library(shiny)
library(tidymodels)
library(skimr)
library(rsample)
library(purrr)
library(recipes)
library(caret)
library(ggplot2)
library(pROC)
library(RSQLite)



write.fst(dfBoxScoresFromQuery, "dfBoxScoresFromQuery.fst", 100)

Final_Score%>%rowwise()%>%
  mutate(Date = strsplit(FixtureKey, " ")[[1]]
         [length(strsplit(FixtureKey, " ")[[1]])])%>%
  select(!FixtureKey)%>%
  mutate(Date= as.Date(Date,  format="%d-%b-%Y"))%>%
  arrange(desc(Date))




function(input, output, session) {
  con <- dbConnect(RSQLite::SQLite(), "mydatabase.db")
  dfBoxScoresFromQuery <- dbGetQuery(con, query)
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
  
  
  output$sean_image <- renderImage({
    list(src = "sean_image.jpg",
         alt = "Sean Mulvilhill",
         width = 250, height = 250) # Adjust width and height as needed
  }, deleteFile = FALSE)
  
}
























