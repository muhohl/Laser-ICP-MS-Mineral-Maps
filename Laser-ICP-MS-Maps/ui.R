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
                                            choices = ""),
                                actionButton("clip", "Clip your data!"),
                            ),
                            
                            mainPanel(
                                plotly::plotlyOutput("ClipPlot"),
                                
                                sliderInput("clip_slider", "Clip element", 
                                            value = c(10, 90),
                                            min = 1,
                                            max = 100)
                        ))),
               tabPanel("Laser Map",
                        sidebarLayout(
                            sidebarPanel(
                                tabsetPanel(
                                    tabPanel("Elements",
                                             fluidRow(
                                                column(5,
                                                       radioButtons("color", "Choose a color palette",
                                                             choices = c("magma", "inferno", 
                                                                         "plasma", "viridis", 
                                                                         "cividis"),
                                                             selected = "viridis")
                                                       ),
                                                column(5,
                                                       checkboxInput("columsman", "cols manually?",
                                                                     value = FALSE))
                                                ),
                                             fluidRow(
                                                column(5,
                                                       checkboxGroupInput("sel_elements", "Select Elements")),
                                                column(5, 
                                                       checkboxGroupInput("linear", "Linear Transform"))
                                                )
                                             
                                             ),
                                    tabPanel("Download",
                                             fluidRow(
                                             radioButtons("sizemanual", "",
                                                          choices = c("auto", "manual"),
                                                          selected = "auto"),
                                             uiOutput("width0"),
                                             uiOutput("height0"),
                                             downloadButton("download"))
                                    )
                            )),
                            
                            mainPanel(
                                fluidRow(
                                    column(3,
                                           sliderInput("height", "Height", value = 500, min = 100, max = 5000)),
                                    column(3,
                                           sliderInput("width", "Width", value = 500, min = 100, max = 5000)),
                                    column(3,
                                           uiOutput("column_slider"))
                                ),
                                    plotOutput("LaserMap"),
                            )
                        ))
               )
    ))