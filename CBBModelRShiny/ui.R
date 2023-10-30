library(shiny)
library(shinythemes)
library(shinydashboard)
library(DT)


# library(rsconnect)
# rsconnect::deployApp('path')

fluidPage(
  theme = shinytheme("superhero"),
  
  tags$head(
    tags$style(
      HTML('
      #sidebar {
        background-color: white;
      }

      body, label, input, button, select { 
        font-family: "Arial";
        color: #01132e;
      }

      .round-image {
        border-radius: 50%;
        display: block;
        margin: 0 auto;
      }
      .image-column {
        text-align: center;
      }
      .custom-label-style label {
      font-size: 15px;
      font-style: italic;
      }
      
      #my-heading {
      background-color: #3498db; 
      color: white;
      padding: 10px;
      border-radius: 5px;
      text-align: center; 
      }
      
      #HomeWinTable table, #HomelossTable table, #AwayWinTable table, #AwaylossTable table {
      font-size: 13px;
      width: 100% !important;
      }
      
      .adjustTableBox .shiny-output-container {
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100%;
      }
      
     
      .small-box { height: 95px;}
      
      .small-box .icon { font-size: 17px; }
      
      .small-box h3 { font-size: 27px; }
      
      .small-box p {font-size: 17px; }
      
      #PredictedOverall {
            font-weight: bold;
            font-size: 20px;
            text-align: center;
        }
      
      
      
    ')
    )
  ),
  
  
  dashboardPage(
    skin = "red",
    dashboardHeader(title = "ML Project"),
    dashboardSidebar(
      dashboardSidebar(
        sidebarMenu(
          menuItem("Prediction", tabName = "NcaaModel"),
          menuItem("Read Me",  tabName = "ReadMe"),
          menuItem("About Us", tabName = "AboutUS")),
        
        width=110)
    ),
    dashboardBody(
#================tab item 1 =====================
      
      tabItems(tabItem(tabName = "NcaaModel",
                       h1("NCAA Prediction Model", style='
                       font-family: Impact, Charcoal, sans-serif;
                       color: black;
                       background: #edeff2;
                       text-shadow: 0.5px 0.5px 0 white, 
                       2px -2px 0 white, 
                       -2px 2px 0 white, 
                       -2px -2px 0 white; 
                       text-align:center;
                          '),
                       p('Please read Read Me section', ),
                       fluidRow(
                         column(width = 4, uiOutput('select_TeamNameHome'), align = "middle"),
                         column(width = 4, 
                                actionButton("PredictButton", 
                                             "Predict", 
                                             style = 'font-size:75%;height:35px;', 
                                             class = "btn-primary", 
                                             size = "large"), align="middle"
                         ),
                         column(width = 4, uiOutput('select_TeamNameAway'), align = "middle")
                       ),
                       
                       hr(style = "border-top: 1px solid #000000;"),
                       
                       #tableOutput('testdataframe'),
                       # verbatimTextOutput('testText'),
                       
                       textOutput('PredictedOverall'), br(),
                       
                                              
                       fluidRow(
                         valueBoxOutput("PredictedHomeScore"),
                         valueBoxOutput("PredictedAwayScore"),
                         valueBoxOutput('PredictedSpreadTotal')
                                 ),
                       
                       
                       
                       box(h3("Score Distribution (Home)", style = "color:black; text-align:center"),
                           hr(style = "border-top: 1px solid #000000;"),
                           plotOutput('DistFunGraphHome'),
                           collapsible = TRUE, status = 'primary'),
                       
                       box(h3("Score Distribution (Away)", style = "color:black; text-align:center"),
                           hr(style = "border-top: 1px solid #000000;"),
                           plotOutput('DistFunGraphAway'),
                           collapsible = TRUE, status = 'primary'),
                       
                       
                       
                       box(class = "adjustTableBox", width = 6,
                           h3("Home Last Matches", style = "color:black; text-align:center"),
                           hr(style = "border-top: 1px solid #000000;"),
                           
                           tags$h4("Last 5 Wins", id = "my-heading"),
                           tableOutput('HomeWinTable'),
                           
                           tags$h4("Last 5 Losses", id = "my-heading"),
                           tableOutput('HomelossTable'),
                           
                           collapsible = TRUE, status = 'primary'),
                       
                       box(class = "adjustTableBox", width = 6,
                           h3("Away Last Matches", style = "color:black; text-align:center"),
                           hr(style = "border-top: 1px solid #000000;"),
                           
                           tags$h4("Last 5 Wins", id = "my-heading"),
                           tableOutput('AwayWinTable'),
                           
                           tags$h4("Last 5 Losses", id = "my-heading"),
                           tableOutput('AwaylossTable'),
                           
                           collapsible = TRUE, status = 'info')
                       
                       ),
               
               #================tab item 2 =====================               
               tabItem(tabName = "ReadMe",
                       h1("Read Me to understand what we are upto!", style='
                       font-family: Impact, Charcoal, sans-serif;
                       color: black;
                       background: #edeff2;
                       text-shadow: 0.5px 0.5px 0 white, 
                       2px -2px 0 white, 
                       -2px 2px 0 white, 
                       -2px -2px 0 white; 
                       text-align:center;
                          '), 
                       p("The Appliction itself is an example app how our final model would look like. The objective is to present the project which operates like a research paper, encompassing all stages of model development, 
                       starting from data acquisition and concluding with the presentation of the findings. 
                       The paper deals with analysing the disparities between a traditional model and a model that relies on the outcomes influenced by various teams' performance 
                       in different quarters of a specific basketball league", br(),br(),"
                       In our preliminary analysis, the predictive model is developed based on exploratory data and is thus relatively rudimentary, resulting in a lower confidence in score calculations. 
                       While the user interface of the primary model will likely resemble the current prototype,
                       it's worth noting that the exploratory data analysis (EDA) stage, from which this model emanates, 
                       is inherently a provisional step in our research framework. Consequently, we've adopted a basic regression model without extensive evaluation or calibration, given that our primary research objective lies elsewhere. Interestingly, the prediction model exhibits a high degree of confidence in its outcomes. This heightened confidence might be attributed to potential overfitting or specific features disproportionately shaping the model's decision-making process. 
                       A fundamental concern is that the foundational score computations derive from variables characterized by limited confidence.",br(),br(),"
                       The aim is to create a machine-learning model using Python and R with front-end access using Shiny and Django frameworks. 
                       The overarching goal is to create a predictive model capable of unveiling the intricate relationship between various game-related 
                       features and the elusive outcomes of basketball matches. In pursuit of this objective, the algorithm is meticulously crafted using two 
                       of the most potent programming languages in data science and analysis, Python and R. The algorithm's reach extends beyond its technical prowess, 
                       as it offers seamless access through both Shiny and Django frameworks, providing a user-friendly front-end interface that empowers enthusiasts, 
                       analysts, and decision-makers to harness the insights buried within the data.", 
                         style='color:black; border: 2px solid #fafcff; font-family: Georgia, serif; font-size: 16px; letter-spacing: 2px; word-spacing: 2px;'),
                       
                       h3("Links", style='
                       font-family: Impact, Charcoal, sans-serif;
                       color: black;
                       background: #edeff2;
                       text-shadow: 0.5px 0.5px 0 white, 
                       2px -2px 0 white, 
                       -2px 2px 0 white, 
                       -2px -2px 0 white; 
                       text-align:center;
                          '),
                       
                       a(href = "https://github.com/PHNX-MOD/Machine_Learning_sport_Model", 
                         style = "color:black; text-align: center; font-family: Georgia, serif; font-size: 16px; letter-spacing: 2px; word-spacing: 2px;", 
                         "Link to the code (GitHub)"), br(),
                       
                       a(href = "https://phnx-mod.github.io/Machine_Learning_sport_Model/", 
                         style = "color:black; text-align: center; font-family: Georgia, serif; font-size: 16px; letter-spacing: 2px; word-spacing: 2px;", 
                         "Link to the base model report"),br(),
                       
                       a(href = "https://github.com/PHNX-MOD/Machine_Learning_sport_Model/blob/main/main.R", 
                         style = "color:black; text-align: center; font-family: Georgia, serif; font-size: 16px; letter-spacing: 2px; word-spacing: 2px;", 
                         "Link to the main R code"),br(),
                       
                       a(href = "https://github.com/PHNX-MOD/Machine_Learning_sport_Model/blob/main/main.ipynb", 
                         style = "color:black; text-align: center; font-family: Georgia, serif; font-size: 16px; letter-spacing: 2px; word-spacing: 2px;", 
                         "Link to the main python code"),br(),
                       
               ),
               #================tab item 3 =====================
               tabItem(tabName = "AboutUS",
                       fluidRow(
                         h1("About us", style='color:#1A1100; text-align:center; text-shadow: 1px 2px 2px #1C6EA4;'),br(),
                         box(
                           h3("Modith Hadya", style = "color:black; text-align:center"),
                           hr(style = "border-top: 1px solid #000000;"),
                           p("Someone who is a data-driven, who likes to solve problems through coding and 
                             also someone who is driven by intellectual curiosity to solve pressing problems. 
                             I have experience in developing dashboards using R & shiny as well as Python(Django). 
                             I can coordinate among the subordinates and indulge in continuous learning new skills,
                             technologies and able to function very well as a valued team member and 
                             to collaborate with others as well as work independently.", style='color:#002B80;'),
         
                           collapsible = TRUE, status = 'warning'
                         ),
                         box(h3("Seán Mulvihill", style = "color:black; text-align:center"),
                             hr(style = "border-top: 1px solid #000000;"),
                             p("Analyst looking for opportunities in a data driven industry following two years experience 
                               in a fast paced quantitative environment. Working with data analytics tools such as SQL,
                               Python, PowerBI and Excel to gain data insight that can drive business operations through 
                               data focused solutions. My previous experiences have given me knowledge in the areas
                               of iGaming, machine learning models and relational databases through various different
                               # analytical projects.",style='color:#002B80; text-align:center'),
                             h3("",imageOutput("sean_image"), style = "color:black; text-align:center"),
                             collapsible = TRUE, status = 'primary'),
                       )
               )
              )
      
      
      
    )
  )
)
