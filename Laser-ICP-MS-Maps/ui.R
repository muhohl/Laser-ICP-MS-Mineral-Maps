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
shinyUI(fluidPage(theme = shinythemes::shinytheme("flatly"),

    # Application title
    titlePanel("Laser Icp-Ms Maps"),

    sidebarLayout(
        sidebarPanel(
            # Uploat data set
            fileInput("upload",
                      "Laser Data"),
            
            checkboxGroupInput("sel_elements", "Select elements")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(
                tabPanel("Clipping Element",
                         
                         plotly::plotlyOutput("ClipPlot"),
                         
                         sliderInput("clip_slider", "Clip element", 
                                     value = c(10, 90),
                                     min = 1,
                                     max = 100),
                         
                         textOutput("SliderText"),
                         ),
                
                tabPanel("Laser Map",
                    # if more than 12 elements are selected I should create more plot 
                    # Outputs
                    plotOutput("LaserMap")
                    
                    )
                )
            )
        )
    ))
