#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Laser Icp-Ms Maps"),

    sidebarLayout(
        sidebarPanel(
            # Uploat data set
            fileInput("upload",
                      "Laser Data"),
            
            checkboxGroupInput("sel_elements", "Select elements", "")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            # if more than 12 elements are selected I should create more plot 
            # Outputs
            tableOutput("files"),
            plotOutput("LaserMap"),
            textOutput("elements_all")
        )
    )
))
