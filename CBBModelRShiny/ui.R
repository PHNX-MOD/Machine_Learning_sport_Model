library(shiny)
library(shinythemes)
library(shinydashboard)
library(DT)

# library(rsconnect)
# rsconnect::deployApp('path')

fluidPage(
  theme = shinytheme("superhero"),

  dashboardPage(
    skin = "red",
    dashboardHeader(title = "NCAA model"),
    dashboardSidebar(),
    dashboardBody(
      
      
    )
  )
)
