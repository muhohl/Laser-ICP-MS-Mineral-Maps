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
    
    sel_elements <- reactive({
        input$sel_elements
    })
    
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
        
    my_range <- reactive({
        cbind(input$clip_slider[1],input$clip_slider[2])
    })
         
    output$ClipPlot <- plotly::renderPlotly({
        
        if (clip_element() == "") return(NULL)
        
        geochem::clipping_element(clip_element(),
                                  cliped_data())
    }) 
     
    output$LaserMap <- renderPlot(height = 500,{ # 500 seems ok so far
         
        if (is.null(input$upload)) return(NULL)
        if (is.null(sel_elements())) return(NULL)
        
        map_plot_list <- geochem::laser_map(data = laser_data(),
                                            selected_elements = sel_elements())

        ggpubr::ggarrange(plotlist = map_plot_list)
    })
    
    output$SliderText <- renderText({paste(my_range(), sel_elements())})
    
    observe({
        
        if (is.null(input$upload)) return(NULL)
        
        updateCheckboxGroupInput(session, "sel_elements",
                                 choices = elements_all())
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
    
})

# Works pretty well so far!!
# TODO Clip the element (slider, plotly (could might be pretty wicked))
# TODO Option for color scale.
# TODO Option for not log transforming the plot. Maybe in a second tab,
# because otherwise the list will be very long. Or try to split the 
# sidebar panel in two columns.
# TODO Make the plot size depending on the number of plots shown, 
# this involves a lot a of trying and than writing if statements. OR!!
# Make buttons that let you increase or decrease the plot size manually
# 
# TODO Show only selected elements
# TODO If more than 10? elements are selected make an action button 
# appear which needs to be pressed to render the plot, because the 
# plotting slows down quiet a lot with more elements and every selection
# is plotted anew.