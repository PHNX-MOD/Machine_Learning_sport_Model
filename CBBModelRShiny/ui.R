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
                       h1("NCAA Score Prediction Model", style='
                       font-family: Impact, Charcoal, sans-serif;
                       color: black;
                       background: #edeff2;
                       text-shadow: 0.5px 0.5px 0 white, 
                       2px -2px 0 white, 
                       -2px 2px 0 white, 
                       -2px -2px 0 white; 
                       text-align:center;
                          '),
                       p('Please read Read Me section'),
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
                       # verbatimTextOutput('testText'),
                       
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
                       p("Select 'Select Input Date' or 'Select Weeks/Months' and click search here first", style='color:black;')
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
