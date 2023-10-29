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




write.fst(dfBoxScoresFromQuery, "dfBoxScoresFromQuery.fst", 100)



# write.fst(Final_Score%>%rowwise()%>%
#             mutate(Date = strsplit(FixtureKey, " ")[[1]]
#                    [length(strsplit(FixtureKey, " ")[[1]])])%>%
#             select(!FixtureKey)%>%
#             mutate(Date= as.Date(Date,  format="%d-%b-%Y")),
#           "Final_score.fst"
#           )

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
   
   
   
  
  
  output$sean_image <- renderImage({
    list(src = "sean_image.jpg",
         alt = "Sean Mulvilhill",
         width = 250, height = 250) 
  }, deleteFile = FALSE)
  
  
  
  
  
  
  
}























