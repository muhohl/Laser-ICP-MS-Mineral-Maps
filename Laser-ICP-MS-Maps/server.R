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

# Data Loading and Element Selection --------------------------------------

    laser_data <- reactive({
        readr::read_csv(input$upload$datapath) 
    })
    
    elements_all <- reactive({
        names(laser_data()[-c(1,2)])
    })
    
    #TODO Here I have to create a data frame that says if element should be
    #transformed or not. 
    sel_elements <- reactive({
        input$sel_elements
    })
    
    linear_elements <- reactive({
        input$linear
    })
    

# Clip Element ------------------------------------------------------------

    clip_element <- reactive({
        input$clipelement
    })
    
    clip_values <- reactive({
        laser_data() %>% 
        dplyr::pull(clip_element())
    })
     
    cliped_data <- reactive({
        laser_data() %>% 
            dplyr::filter(!! sym(clip_element()) > input$clip_slider[1] &
                              !! sym(clip_element()) < input$clip_slider[2])
    })
     
    cliped_plot_data <- eventReactive(input$clip, {
        cliped_data()
    })

    observe({
       
       if (is.null(input$upload)) return(NULL)
       
       updateSelectInput(session, "clipelement",
                         choices = elements_all())
   }) 
    
    observe({
        
        if (clip_element() == "") return(NULL)       
        
       
        updateSliderInput(session, "clip_slider",
                          value = c(0, round(max(clip_values()))),
                          min = 0,
                          max = round(max(clip_values())))
        
    })
     
  
# Columns -----------------------------------------------------------------

    colums_manually <- reactive({
        input$columsman
    })
    
    n_columns <- reactive({
        if (colums_manually()) {
            input$ncol
        } else {
            NULL
        }
    })

    observe({
        if (input$columsman) {
            output$column_slider <- renderUI({sliderInput("ncol", "Columns", 
                                                          value = 2, 
                                                          min = 1, 
                                                          max = length(sel_elements()),
                                                          step = 1)
            })
        } 
        if (!input$columsman) {
            output$column_slider <- renderUI({})
        }
    })

    
# Plots -------------------------------------------------------------------

    output$ClipPlot <- plotly::renderPlotly({
        
         if (clip_element() == "") return(NULL)
        
         geochem::clipping_element(clip_element(),
                                  cliped_data())
         }) 
     
    output$LaserMap <- renderPlot(height = function() input$height,
                                  width = function() input$width,{ # 500 seems ok so far
         
        if (is.null(input$upload)) return(NULL)
        if (is.null(sel_elements())) return(NULL)
        
        map_plot_list <- geochem::laser_map(data = cliped_plot_data(),
                                            selected_elements = sel_elements(),
                                            option = input$color)

        cowplot::plot_grid(plotlist = map_plot_list, ncol = n_columns())
    })
    
   
    output$SliderText <- renderText({paste(my_range(), sel_elements())})
    
    observe({
        
        if (is.null(input$upload)) return(NULL)
        
        updateCheckboxGroupInput(session, "sel_elements",
                                 choices = elements_all())
    })
    
    observe({
        if (is.null(input$sel_elements)) return(NULL)
        
        updateCheckboxGroupInput(session, "linear",
                                 choiceValues = sel_elements(),
                                 choiceNames = sel_elements())
    })
    
    
 #Download ----------------------------------------------------------------

    output$download <- downloadHandler(
        filename = function() {
            paste0(input$upload, ".png")
        },
        
        content = function(file) {
            ggplot2::ggsave(file, device = "png", width = 10, height = 15)
        }
    )
    
    observe({
        if (input$sizemanual == "manual"){
            output$width0 <- renderUI({numericInput("width", "Plot Width", 
                                                    value = 10, 
                                                    min = 5,
                                                    max = 20)
                })
            output$height0 <- renderUI({numericInput("height", "Plot Height",
                                                     value = 7,
                                                     min = 5, 
                                                     max = 20)})
        }
        if (input$sizemanual == "auto") {
            output$width0 <- renderUI({})
            output$height0 <- renderUI({})
        }
    })
    
})


# Notes & TODO ------------------------------------------------------------

# Works pretty well so far!!
# Next steps!
# TODO Write backend for the height and width settings!
# TODO Create hight and width settings for the active plot, or maybe even better
# find a way to fix the coord_ratio of the plots. I don't know if that is possible.
# TODO Write backend for the log transformation!
# TODO Make plot width and height widgets appear next to each other in the Download
# tab!
# 
# Later
# TODO See second point! Make the plot size depending on the number of plots shown, 
# this involves a lot a of trying and than writing if statements. OR!!
# Make buttons that let you increase or decrease the plot size manually
# 
# TODO If more than 10? elements are selected make an action button 
# appear which needs to be pressed to render the plot, because the 
# plotting slows down quiet a lot with more elements and every selection
# is plotted anew.