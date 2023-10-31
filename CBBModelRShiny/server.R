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
library(DT)
library(RDS)
library(fst)




#calculating the winning percentage based on spread 

spread <- c(1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5, 15, 15.5, 16, 16.5, 17, 17.5, 18, 18.5, 19)
win_percentage <- c(0.517, 0.533, 0.574, 0.573, 0.573, 0.587, 0.651, 0.654, 0.664, 0.695, 0.698, 0.719, 0.750, 0.740, 0.806, 0.802, 0.783, 0.843, 0.843, 0.858, 0.868, 0.875, 0.879, 0.895, 0.884, 0.937, 0.890, 0.945, 0.912, 0.948, 0.910, 0.944, 0.933, 0.961, 0.950, 0.959, 1.000)

win_per_table <- data.frame(spread, win_percentage)



# Function to interpolate Win% for a given spread
interpolate_win_percentage <- function(spread_val, win_per_table) {
  # If spread greater than 19, return NA
  if (spread_val > 19) {
    return(NA_real_)
  }
  
  lower_row <- win_per_table %>% filter(spread <= spread_val) %>% arrange(desc(spread)) %>% slice(1)
  upper_row <- win_per_table %>% filter(spread > spread_val) %>% arrange(spread) %>% slice(1)
  
  if (nrow(lower_row) == 0) {
    return(upper_row$win_percentage)
  }
  if (nrow(upper_row) == 0) {
    return(lower_row$win_percentage)
  }
  
  x1 <- lower_row$spread
  y1 <- lower_row$win_percentage
  x2 <- upper_row$spread
  y2 <- upper_row$win_percentage
  
  # Interpolation formula
  y = y1 + ((spread_val - x1) * (y2 - y1)) / (x2 - x1)
  
  return(y)
}


Away_recipe <- readRDS("Away_recipe.rds")
Home_recipe <- readRDS("Home_recipe.rds")
model_home <- readRDS("model_home.rds")
model_away <- readRDS("model_away.rds")
training_recipe <- readRDS("training_recipe.rds")

winner_prediction_model <- readRDS('winner_prediction_model.rds')
dfboxscoresMean <- read.fst("dfboxscoresMean.fst")

processed_Away_data <- juice(Away_recipe)
processed_Home_data <- juice(Home_recipe)


#=============team names ===============
Team_names <- c( "A PEAY", "ABILCH", "AIRFOR", "AKRON", "AL A&M", "ALA ST", "ALA", "ALBANY", "ALCORN", 
   "AMER", "APP ST", "ARIZ", "ARK PB", "ARK ST", "ARK", "ARMY", "AUBURN", "AZ ST", "BALLST", "BAYLOR", 
   "BC", "BECOOK", "BELLAR", "BELMNT", "BGSU", "BINGHA", "BOISE", "BRAD", "BROWN", "BRYANT", "BU", "BUCKNL",
   "BUFF", "BUTLER", "BYU", "C ARK", "C CONN", "C MICH", "C OF C", "CAL", "CALBAP", "CALPLY", "CAMPBL", 
   "CANISI", "CHAR", "CHARSO", "CHAT", "CHI ST", "CINCY", "CITDEL", "CLE ST", "CLEM", "CO CAR", "CO ST", 
   "COLGAT", "COLO", "COLUMB", "COPPIN", "CORN", "CREIGH", "CSFULL", "CSUBAK", "CSUN", "DART", "DAVID", 
   "DAYTON", "DEL ST", "DEL", "DENVER", "DEPAUL", "DET", "DIXST", "DRAKE", "DREXEL", "DUKE", "DUQSNE",
   "E CAR", "E ILL", "E KY", "E MICH", "E WASH", "ELON", "ETSU", "EVANS", "FAIR", "FAU", "FDU", "FGCU", "FIU",
   "FL A&M", "FLA", "FORDHM", "FRESNO", "FSU", "FURMAN", "G WASH", "G WEBB", "GA SOU", "GA ST", "GATECH", "GCANYN", 
   "GMU", "GONZ", "GRAMB", "GRNBAY", "GTOWN", "HAMPTN", "HARV", "HAWAII", "HIGHPT", "HOFSTR", "HOLYCR", "HOU", "HOUBAP",
   "HOWARD", "HRTFRD", "ID ST", "IDAHO", "ILL ST", "ILL", "INCWRD", "IND ST", "IND", "IONA", "IOWA", "IOWAST", "IPFW", "IUPUI",
   "JACKST", "JAX ST", "JMU", "JVILLE", "KAN ST", "KANSAS", "KENSAW", "KENT", "LA MON", "LAFAYE", "LAMAR", "LASALL", "LATECH", "LBSU", 
   "LEHIGH", "LIBRTY", "LINWOD", "LIPSCO", "LIU BK", "LMU", "LONGWD", "LOUIS", "LOY MD", "LOYCHI", "LSU", "MAINE", "MANHAT", "MARIST", 
   "MARQ", "MARSH", "MCNEES", "MD", "MEM", "MERCER", "MERMCK", "MIA OH", "MIAMI", "MICH", "MICHST", "MIDTEN", "MILWKE", "MINN", "MISS", 
   "MISSST", "MIZZOU", "MO ST", "MONMTH", "MONT", "MONTST", "MOREST", "MORGAN", "MS VAL", "MTSTMY", "MURRAY", "N ALA", "N COLO", "N DAME", 
   "N IOWA", "N KY", "N MEX", "NAU", "NAVY", "NC A&T", "NC CEN", "NC ST", "ND ST", "NEB", "NEVADA", "NIAGRA", "NICHST", "NIU", "NJIT", "NM ST", 
   "NO DAK", "NO FLA", "NO TEX", "NOEAST", "NORFLK", "NOVA", "NW ST", "NWSTRN", "OAK", "ODU", "OHIO", "OHIOST", "OKLA", "OKLAST", "OMAHA", "ORE ST", 
   "OREGN", "ORU", "PACIF", "PENN", "PENNST", "PEPPER", "PITT", "PORT", "PORTST", "PRESBY", "PRINCE", "PROV", "PURDUE", "PV A&M", "QUENNC", "QUINN", 
   "RADFRD", "RICE", "RICH", "RIDER", "ROBMOR", "RUTGER", "S ALA", "S CAR", "S FRAN", "S IND", "S MISS", "S UTAH", "SAC ST", "SACHRT", "SAMFRD", "SAMHOU", 
   "SC ST", "SC UPS", "SDAKST", "SDSU", "SE LA", "SEATTL", "SEMO", "SETON", "SFA", "SIENA", "SIU", "SIUE", "SJSU", "SMU", "SO DAK", "SOUTHR", "ST LOU",
   "ST PTR", "STAN", "STBONA", "STCLAR", "STETSN", "STFRBK", "STFRPA", "STJOES", "STJOHN", "STMARY", "STONEH", "STONY", "STTHOM", "SYR", "TAMUCC",
   "TAMUCO", "TARLET", "TCU", "TEMPLE", "TENN", "TENNST", "TEXAS", "TNTECH", "TOLEDO", "TOWSON", "TROY", "TULANE", "TULSA", "TX A&M", "TX ARL", "TX SOU",
   "TX ST", "TXTECH", "UAB", "UALR", "UC DAV", "UC IRV", "UC RIV", "UCF", "UCLA", "UCONN", "UCSB", "UCSD", "UGA", "UIC", "UK", "ULL", "UMASS", "UMASSL",
   "UMBC", "UMES", "UMKC", "UNC A", "UNC G", "UNC", "UNCW", "UNH", "UNLV", "UNO", "URI", "USC", "USD", "USF", "UT MAR", "UT ST", "UT VAL", "UTAH", "UTEP", 
   "UTRGV", "UTSA", "UVA", "VALPO", "VANDY", "VCU", "VERMNT", "VMI", "VT", "W CAR", "W ILL", "W KY", "W MICH", "WAGNER", "WAKE", "WASH", "WASHST", 
   "WEB ST", "WICHST", "WINTHR", "WISC", "WM&MRY", "WOFFRD", "WRIGHT", "WVU", "WYO", "XAVIER", "YALE", "YSU" )

#=============team names ===============



get_team_spread_data <- function(team_name, team_column, spread_condition) {
  
  data <- read.fst("Final_score.fst") %>%
    mutate(spread = Home_score - Away_score) %>%
    filter(!!sym(team_column) == team_name)
  
  if(spread_condition == "greater") {
    result <- data %>%
      filter(spread > 0)
  } else if(spread_condition == "lesser") {
    result <- data %>%
      filter(spread < 0)
  } else {
    stop("Invalid spread_condition. Choose either 'greater' or 'lesser'.")
  }
  
  return(result)
}
  


function(input, output, session) {
  
  
  
  output$select_TeamNameHome <- renderUI({
    div(class = "custom-label-style", 
        selectInput('SelectTeamNameHome', 'Select Home', Team_names, width = '150px')
    )
  })
  
  output$select_TeamNameAway <- renderUI({
    div(class = "custom-label-style", 
        selectInput('SelectTeamNameAway', 'Select Away', Team_names, width = '150px')
    )
    })
  
  
  
  
  output$HomeWinTable <- renderTable({
    head(rbind(get_team_spread_data(input$SelectTeamNameHome, "Home", "lesser"),
               get_team_spread_data(input$SelectTeamNameHome, "Away", "lesser"))%>%
           arrange(desc(Date)),5)%>%mutate(Date = as.character(Date))%>%
      rename("Home score" = Home_score, 'Away score' =Away_score)%>%
      select(Date, Home, Away, "Home score", 'Away score')%>%mutate(Result =c("Win"))
  })
  
  output$HomelossTable <- renderTable({
    head(rbind(get_team_spread_data(input$SelectTeamNameHome, "Home", "greater"),
               get_team_spread_data(input$SelectTeamNameHome, "Away", "greater"))%>%
           arrange(desc(Date)),5)%>%mutate(Date = as.character(Date))%>%
      rename("Home score" = Home_score, 'Away score' =Away_score)%>%
      select(Date, Home, Away, "Home score", 'Away score')%>%mutate(Result =c("Loss"))
  })
  
  
   output$AwayWinTable <- renderTable({
     head(rbind(get_team_spread_data(input$SelectTeamNameAway, "Home", "lesser"),
                get_team_spread_data(input$SelectTeamNameAway, "Away", "lesser"))%>%
            arrange(desc(Date)),5)%>%mutate(Date = as.character(Date))%>%
       rename("Home score" = Home_score, 'Away score' =Away_score)%>%
       select(Date, Home, Away, "Home score", 'Away score')%>%mutate(Result =c("Win"))
  })
   
   output$AwaylossTable <- renderTable({
     rbind(get_team_spread_data(input$SelectTeamNameAway, "Home", "greater"),
                   get_team_spread_data(input$SelectTeamNameAway, "Away", "greater"))%>%
       arrange(desc(Date)) %>% mutate(Date = as.character(Date))%>%
       head(5) %>%
       mutate(Date = as.character(Date))%>%rename("Home score" = Home_score, 'Away score' =Away_score)%>%
       select(Date, Home, Away, "Home score", 'Away score')%>%mutate(Result =c("Loss"))

   })
   
   
   #prediction ====
   
   UpcomingMatchER <- eventReactive(input$PredictButton, {
     req(input$SelectTeamNameHome, input$SelectTeamNameAway)
     upcoming_match <- data.frame(Home = input$SelectTeamNameHome, Away = input$SelectTeamNameAway)
     upcoming_match <-  merge(upcoming_match, dfboxscoresMean, by.x = "Home", by.y = "TeamName", all.x = TRUE)%>%rename(HomeScoreAvg = Base_score)
     upcoming_match <- merge(upcoming_match, dfboxscoresMean, by.x = "Away", by.y = "TeamName", all.x = TRUE)%>%rename(AwayScoreAvg = Base_score)
     
     #predicted_home_scores=================================

     processed_upcoming_fixture_home <- bake(Home_recipe, new_data = upcoming_match)
     predicted_home_scores <- predict(model_home, newdata=processed_upcoming_fixture_home)


     #predicted_away_scores=======================================

     processed_upcoming_fixture_away <- bake(Away_recipe, new_data = upcoming_match)


     #(predvars, data, env) : object 'Home_ABILCH' not found, adding a  column filled with zero
     missing_cols <- setdiff(names(processed_Away_data), names(processed_upcoming_fixture_away))
     for(col in missing_cols) {
       processed_upcoming_fixture_away[[col]] <- 0
     }

     predicted_away_scores <- predict(model_away, newdata=processed_upcoming_fixture_away)

     upcoming_match_with_scores  <- cbind(upcoming_match, predicted_home_scores, predicted_away_scores)%>%
       select(!c(HomeScoreAvg,AwayScoreAvg))%>%
       mutate(across(everything(), ~replace_na(.x, 0)))%>%
       rename(Home_score = predicted_home_scores, Away_score = predicted_away_scores)%>%
       mutate(Home_score = round(Home_score,2), Away_score = round(Away_score, 2))
     
     encoded_upcoming_matches <- bake(training_recipe, upcoming_match_with_scores)
     
     predicted_outcome <- predict(winner_prediction_model, newdata=encoded_upcoming_matches, type="response")
     predicted_winner <- ifelse(predicted_outcome > 0.5, "Home", "Away")
     
     
     upcoming_fixture_predictions <- cbind(upcoming_match_with_scores, predicted_winner)
     upcoming_fixture_predictions <- upcoming_fixture_predictions%>%mutate(Home_score = round(Home_score, 2),
                                                                           Away_score = round(Away_score , 2),
                                                                           Spread = Away_score-Home_score,
                                                                           Totals = Away_score+Home_score)
     
     
     # Mutate upcoming_fix with the interpolated Win%
     upcoming_fix <- upcoming_fixture_predictions %>%
       rowwise() %>%
       mutate(WinPercentage = interpolate_win_percentage(abs(Spread),win_per_table ))
     
     upcoming_fix <- upcoming_fix%>%mutate(Spread = round(Spread,2), WinPercentage = round(WinPercentage,4))
     
     return(upcoming_fix)
   })
   
   
   
   #====distribution plot ===============
   
   
   createADistGraphFun <- function(inputCondtion){
     distributCal <- if(inputCondtion == "home"){
       rbind(read.fst("Final_score.fst")%>%filter(Home == input$SelectTeamNameHome)%>%
               select(Home, Home_score)%>%rename(Team=Home, Score=Home_score),
             read.fst("Final_score.fst")%>%filter(Away == input$SelectTeamNameHome)%>%
               select(Away, Away_score)%>%rename(Team=Away, Score=Away_score))
     } else {
       rbind(read.fst("Final_score.fst")%>%filter(Home == input$SelectTeamNameAway)%>%
               select(Home, Home_score)%>%rename(Team=Home, Score=Home_score),
             read.fst("Final_score.fst")%>%filter(Away == input$SelectTeamNameAway)%>%
               select(Away, Away_score)%>%rename(Team=Away, Score=Away_score))
     }
     
     mean_score <- mean(distributCal$Score)
     sd_score <- sd(distributCal$Score)
     environment()
   }
   
   PlotADistGraphFun <- function(inputCondtion, colorVar){
     env = createADistGraphFun(inputCondtion)
     ggplot(env$distributCal, aes(x=Score)) + 
       geom_histogram(aes(y=..density..), binwidth=5, fill=colorVar, color="black", alpha=0.7) + 
       geom_density(color="red", size=1.2) +   
       geom_vline(aes(xintercept=env$mean_score), color="green", linetype="dashed", size=1) + 
       geom_vline(aes(xintercept=env$mean_score - env$sd_score), color="purple", linetype="dashed", size=0.8) + 
       geom_vline(aes(xintercept=env$mean_score + env$sd_score), color="purple", linetype="dashed", size=0.8) + 
       
       geom_text(aes(x=env$mean_score, y=0, label=sprintf("Mean: %.2f", env$mean_score)), vjust=-0.5, color="green") +
       geom_text(aes(x=env$mean_score - env$sd_score, y=0, label=sprintf("-1 SD: %.2f", env$mean_score - env$sd_score)), vjust=-0.5, color="purple") +
       geom_text(aes(x=env$mean_score + env$sd_score, y=0, label=sprintf("+1 SD: %.2f", env$mean_score + env$sd_score)), vjust=-0.5, color="purple") +
       
       labs(title=paste("Distribution of Scores for", ifelse(inputCondtion == "home", input$SelectTeamNameHome, input$SelectTeamNameAway)),
            x="Score", 
            y="Density") +
       theme_minimal()
   }
  
   
   plotDataHome <- eventReactive(input$PredictButton, {
     PlotADistGraphFun('home', 'gold')
   })
   plotDataAway <- eventReactive(input$PredictButton, {
     PlotADistGraphFun('away', 'orange')
   })
   
   
   output$DistFunGraphHome <- renderPlot({
     plotDataHome()
   })
   
   output$DistFunGraphAway <- renderPlot({
     plotDataAway()
   })
   
   
  
   #====distribution plot end===============
   
   
   
   output$PredictedHomeScore <- renderValueBox({
     valueBox(UpcomingMatchER()[1,3],
              subtitle = "Predicted Home Score",
              icon = icon("home"),
              color = "purple")
   })
   
   
   output$PredictedAwayScore <- renderValueBox({
     valueBox(UpcomingMatchER()[1,4],
              subtitle = "Predicted Away Score",
              icon = icon("users"),
              color = "green")
   })
   
   
   output$PredictedSpreadTotal <- renderValueBox({
     valueBox(paste("Spread:  ", UpcomingMatchER()[1,6],"   ",
                              "Total:  ",  UpcomingMatchER()[1,7]),
              subtitle = "Predicted Spread & Total",
              icon = icon("signal"),
              color = "light-blue")
   })
   
   
   output$PredictedOverall <- renderText({
     paste( 
       UpcomingMatchER()[1,5], "is predicted to win with",
       ifelse(UpcomingMatchER()[1,6] <= 19, UpcomingMatchER()[1,8]*100, "> 99"), "%"
     )
   })

   
   
  #=====about us ============= 
   
  output$sean_image <- renderImage({
    list(src = "sean_image.jpg",
         alt = "Sean Mulvilhill",
         width = 250, height = 250) 
  }, deleteFile = FALSE)
   
   output$modith_image <- renderImage({
     list(src = "modith_image.png",
          alt = "Modith Hadya",
          width = 250, height = 250) 
   }, deleteFile = FALSE)
  
  
  #test =============
  
  output$testdataframe <- renderTable({
    UpcomingMatchER()
  })
  # 
  # output$testText <- renderText({
  #   UpcomingMatchER()[1, 3]
  # })
  
  
  
  
  
  
}























