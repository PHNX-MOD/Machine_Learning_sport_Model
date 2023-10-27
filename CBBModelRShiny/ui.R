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
        background-color: #d46ed4;
      }

      body, label, input, button, select { 
        font-family: "Arial";
        color: black;
      }

      .round-image {
        border-radius: 50%;
        display: block;
        margin: 0 auto;
      }
      .image-column {
        text-align: center;
      }
    ')
    )
  ),
  
  
  
  dashboardPage(
    skin = "red",
    dashboardHeader(title = "NCAA model"),
    dashboardSidebar(
      dashboardSidebar(
        sidebarMenu(
          menuItem("NCAA Model", tabName = "NcaaModel"),
          menuItem("Read Me",  tabName = "ReadMe"),
          menuItem("About Us", tabName = "AboutUS")),
        
        width=110)
    ),
    dashboardBody(
#================tab item 1 =====================
      
      tabItems(tabItem(tabName = "NcaaModel",
                       h1("NCAA score prediction model", style='
                       font-family: Impact, Charcoal, sans-serif;
                       color: #FFFFFF;
                       background: #edeff2;
                       text-shadow: 2px 2px 0 #004466, 
                       2px -2px 0 #4074b5, 
                       -2px 2px 0 #4074b5, 
                       -2px -2px 0 #4074b5, 
                       2px 0px 0 #4074b5, 
                       0px 2px 0 #4074b5, 
                       -2px 0px 0 #4074b5,
                       0px -2px 0 #4074b5;
                       text-align:center;
                          '),
                       p('Please read Read Me section'),
                       box(h3("Home Last 5 Wins/Losses", style = "color:black; text-align:center"),
                           hr(style = "border-top: 1px solid #000000;"),
                           collapsible = TRUE, status = 'primary'),
                       box(h3("Away Last 5 Wins/Losses", style = "color:black; text-align:center"),
                           hr(style = "border-top: 1px solid #000000;"),
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
