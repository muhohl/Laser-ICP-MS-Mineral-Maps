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

    navbarPage("Laser-ICPMS Maps",
               tabPanel("Clipping Element",
                        sidebarLayout(
                            sidebarPanel(
                                # Uploat data set
                                fileInput("upload",
                                          "Laser Data"),
                                selectInput("clipelement", "Choose element to clip!", 
                                            choices = ""),
                                actionButton("clip", "Clip your data!"),
                                checkboxInput("keepdata", "Keep the clipped data set!")
                            ),
                            
                            mainPanel(
                                plotly::plotlyOutput("ClipPlot"),
                                
                                sliderInput("clip_slider", "Clip element", 
                                            value = c(10, 90),
                                            min = 1,
                                            max = 100,
                                            step = 0.1)
                        ))),
               tabPanel("Laser Map",
                        sidebarLayout(
                            sidebarPanel(
                                tabsetPanel(
                                    tabPanel("Elements",
                                             fluidRow(
                                                column(5,
                                                       radioButtons("color", "Choose a color palette!",
                                                             choices = c("magma", "inferno", 
                                                                         "plasma", "viridis", 
                                                                         "cividis", "rocket",
                                                                         "mako", "turbo"),
                                                             selected = "turbo")
                                                       ),
                                                column(5, 
                                                       selectInput("unit_title", "Choose a unit!",
                                                                   choices = c("[ppm]", "[wt.%]", " "))
                                                       ),
                                                column(5,
                                                       selectInput("font", "Choose a font!",
                                                                   choices = c("serif", "sans", "mono"))
                                                       ),
                                                column(5,
                                                       selectInput("label", "Choose a starting label!",
                                                                   choices = c(NA, LETTERS), selected = "B"))
                                                ),
                                             fluidRow(
                                                 column(5,
                                                        checkboxInput("columsman", "cols manually?",
                                                                      value = FALSE)
                                                        ),
                                                 column(5,
                                                        selectInput("labels", "Choose a scale notation!",
                                                                    choices = c("number", "scientific", "number_si")))
                                             ),
                                             fluidRow(
                                                column(5,
                                                       checkboxGroupInput("sel_elements", "Select Elements")),
                                                column(5, 
                                                       checkboxGroupInput("linear", "Linear Transform"))
                                                )
                                             
                                             ),
                                    #tabPanel("Ratio Plots",
                                    #         fluidRow(
                                    #             column(5,
                                    #                    selectInput("denominator", "Denominator",
                                    #                                choices = "")),
                                    #             column(5,
                                    #                    actionButton("ratio", "Add Ratio!"))
                                    #             ),
                                    #         fluidRow(
                                    #             column(5,
                                    #                    selectInput("enumerator", "Enumerator",
                                    #                                choices = ""))
                                    #             ),
                                    #         fluidRow(
                                    #             column(5,
                                    #                    checkboxGroupInput("sel_elements_ratio", "Select Elements"))
                                    #             )
                                    #         ),
                                    tabPanel("Download",
                                             fluidRow(downloadButton("download"))

                                    )
                            )),
                            
                            mainPanel(
                                fluidRow(
                                    column(3,
                                           sliderInput("barsize", "Bar Size", value = 7, min = 1, max = 15)),
                                    column(3,
                                           sliderInput("height", "Height", value = 500, min = 100, max = 5000)),
                                    column(3,
                                           sliderInput("width", "Width", value = 500, min = 100, max = 5000)),
                                    column(3,
                                           sliderInput("fontsize", "Font Size", value = 14, min = 6, max = 30)),
                                    column(3,
                                           uiOutput("column_slider"))
                                ),
                                    plotOutput("LaserMap"),
                            )
                        ))
               )
    ))
