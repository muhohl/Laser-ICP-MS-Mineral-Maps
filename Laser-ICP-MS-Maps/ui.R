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

    navbarPage("Laser Icp-Ms Maps",
               tabPanel("Clipping Element",
                        sidebarLayout(
                            sidebarPanel(
                                # Uploat data set
                                fileInput("upload",
                                          "Laser Data"),
                                selectInput("clipelement", "Choose element to clip", 
                                            choices = "")
                            ),
                            
                            mainPanel(
                                plotly::plotlyOutput("ClipPlot"),
                                
                                sliderInput("clip_slider", "Clip element", 
                                            value = c(10, 90),
                                            min = 1,
                                            max = 100),
                                
                                textOutput("SliderText")
                        ))),
               tabPanel("Laser Map",
                        sidebarLayout(
                            sidebarPanel(
                                checkboxGroupInput("sel_elements", "Select elements")
                            ),
                            
                            mainPanel(
                                plotOutput("LaserMap")
                            )
                        ))
               )
    ))