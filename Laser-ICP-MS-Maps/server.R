#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    laser_data <- reactive({
        readr::read_csv(input$upload$datapath) 
    })
    
    elements_all <- reactive({
        names(laser_data()[-c(1,2)])
    })
     
    output$LaserMap <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
        
        geochem::laser_map()

    })
    output$files <- renderTable(input$upload)
    
    output$elements_all <- renderText(elements_all())
    
    observe({
        inFile <- input$upload
        if (is.null(inFile)){
            return(NULL)
        }
        
        updateCheckboxGroupInput(session, "sel_elements",
                                 choices = elements_all())
        
    })
    
})
