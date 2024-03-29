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
library(geochem)

options(shiny.maxRequestSize=30*1024^2)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

# Data Loading and Element Selection --------------------------------------

    laser_data <- reactiveVal()
    
    observe({
      req(input$upload$datapath)
      laser_data(readr::read_csv(input$upload$datapath) %>% 
                   plyr::rename(replace = c(X="x", Y="y"), warn_missing = FALSE))
    })

    
    elements_all <- reactive({
        laser_data() %>% 
            dplyr::select(!x) %>% 
            dplyr::select(!y) %>% 
            names()
    })
    
    #TODO Here I have to create a data frame that says if element should be
    #transformed or not. 
    sel_elements <- reactive({
        input$sel_elements
    })
    
    linear_elements <- reactive({
        input$linear
    })
    
    sel_labels <- reactive({
      if (input$labels == "number") {
        return(scales::label_number())
      } 
      if (input$labels == "scientific") {
        return(scales::label_scientific())
      }
      if (input$labels == "number_si") {
        return(scales:::label_number_si())
      }
    })
    

# Clip Element ------------------------------------------------------------

    clip_element <- reactive({
        input$clipelement
    })
    
    clip_values <- reactive({
        laser_data() %>% 
        dplyr::pull(clip_element())
    })
   
    keep_data <- reactive({
        input$keepdata
    })
       
    cliped_data <- reactive({
      laser_data() %>% 
        dplyr::filter(!! sym(clip_element()) > input$clip_slider[1] &
                      !! sym(clip_element()) < input$clip_slider[2])
    })
     
    cliped_plot_data <- eventReactive(input$clip, {
        cliped_data()
    })
   
    
    observeEvent(input$keepdata, {
      tmp <- cliped_plot_data()
      laser_data(tmp)
    })
    
    #cliped_data_updater <- reactive({
    #  if (keep_data()) {
    #    laser_data <- cliped_data()
    #  }
    #})

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


# Linear Transformation ---------------------------------------------------

    Log_Trans_Df <- reactive({
        tibble(Elements = sel_elements(),
               Log_Trans = "log") %>% 
          mutate(Log_Trans = if_else(sel_elements() %in% input$linear,
                                     "identity", "log"))
    })  
    
# Plots -------------------------------------------------------------------
    
    output$ClipPlot <- plotly::renderPlotly({
        
         if (clip_element() == "") return(NULL)
        
         geochem::clipping_element(clip_element(),
                                  cliped_data())
         }) 
     
    laser_map_plot <- reactive({ # 500 seems ok so far
         
        if (is.null(input$upload)) return(NULL)
        if (is.null(sel_elements())) return(NULL)

        map_plot_list <- geochem::laser_map2(data = cliped_plot_data(),
                                             columns = which(names(cliped_plot_data()) %in% input$sel_elements),
                                             unit = input$unit_title,
                                             option = input$color,
                                             plot_label_start = input$label,
                                             labels = sel_labels(),
                                             family = input$font)
        #map_plot_list <- geochem::laser_map(data = cliped_plot_data(),
        #                                    selected_elements = sel_elements(),
        #                                    Log_Trans = Log_Trans_Df(),
        #                                    option = input$color,
        #                                    unit_title = input$unit_title,
        #                                    font = input$font,
        #                                    fontsize = input$fontsize,
        #                                    labels = sel_labels())

        # Setup a plot for the linear maps
        for (i in which(input$sel_elements %in% input$linear)) {
            if (input$label != "NA") {
                # Make sure to use the right letters
                letter <- LETTERS[i+which(LETTERS %in% input$label)-1]
            } else {
                letter <- "NA"
            }
            map_plot_list[[i]] <- geochem::laser_map2(data = cliped_plot_data(),
                                                      columns = which(names(cliped_plot_data()) %in% input$sel_elements[i]),
                                                      unit = input$unit_title,
                                                      trans = "identity",
                                                      option = input$color,
                                                      plot_label_start = letter,
                                                      family = input$font,
                                                      labels = scales::label_number(),
                                                      breaks = scales::extended_breaks())[[1]]
        }

        # TODO Write for Loop that changes the color bar height and width
        # And change the labels as according to the linear or log transformation probably offer different color scale option

        for (i in seq_along(map_plot_list)) {
            map_plot_list[[i]] <- map_plot_list[[i]] +
               ggplot2::guides(fill = ggplot2::guide_colorbar(barheight = input$barsize,
                                                     barwidth = input$barsize/13,
                                                     ticks.colour = "black",
                                                     frame.colour = "black")) +
               ggplot2::theme(title = ggplot2::element_text(size = input$fontsize),
                              legend.text = ggplot2::element_text(size = input$fontsize))
        }

        cowplot::plot_grid(plotlist = map_plot_list, ncol = n_columns(), align = c("v", "h"))
    })
    
    output$LaserMap <- renderPlot(height = function() input$height,
                                  width = function() input$width,{
                                    
                                    laser_map_plot()
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

 # Ratio Plots ------------------------------------------------------------
 # So far I can't the append the newly created ratio columns to the main data frame
 # Look in Laser_Mapping_R/app.R for possible solution, in which I manage to add columns to the
 # exisiting data frame with reactiveValues() and the dataframe as function argument summarized
 ## Need to understand what the function reactiveValues() does!!
#
 #   observe({
 #       if (is.null(input$upload)) return(NULL)
#
 #       updateSelectInput(session, "denominator",
 #                         choices = elements_all())
#
 #   })
#
 #   observe({
 #       if (is.null(input$upload)) return(NULL)
#
 #       updateSelectInput(session, "enumerator",
 #                         choices = elements_all())
#
 #   })
#
#
 #   observe({
 #       if (is.null(input$upload)) return(NULL)
#
 #       updateCheckboxGroupInput(session, "selected_elements_ratio",
 #                                choiceValues = sel_elements(),
 #                                choiceNames = sel_elements())
#
 #   })
#
 #   ratio_den <- reactive({
 #       input$denominator
 #   })
 #   ratio_enu <- reactive({
 #       input$enumerator
 #   })
#
 #   plus_it <- eventReactive(input$plus{
#
 #   })
#
 #   ratio_data <- reactive({
 #       if (is.null(input$upload)) return(NULL)
#
 #       cliped_plot_data() %>%
 #           #mutate(paste0(!! sym(ratio_enu()), "/", !! sym(ratio_enu())) := !! sym(ratio_den()) / !! sym(ratio_enu()) %>%
 #           mutate(paste0(!! sym(ratio_enu()), "/", !! sym(ratio_enu())) := Ti49/V51) %>%
 #           select(tail(names(.),1))
 #   })
#
 #   #cliped_plot_data <- eventReactive(input$ratio, {
    #    bind_cols(cliped_plot_data(), ratio_data())
    #})
 # Download ---------------------------------------------------------------

    plot_width <- reactive({
      input$width
    })
    
    plot_height <- reactive({
      input$height
    })
    
    output$download <- downloadHandler(
        filename = function() {
            paste0(input$upload, ".png")
        },
        
        content = function(file) {
            cowplot::save_plot(file, laser_map_plot(), 
                               base_height = plot_height()/100,
                               units = c("in"),
                               base_asp = plot_width()/plot_height()
            )
        }
    )
})


# Notes & TODO ------------------------------------------------------------

# Works pretty well so far!!
# Next steps!
# TODO Make plot width and height widgets appear next to each other in the Download
# tab!
# TODO Add ratio plot and maybe a PCA algorithm in the background
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
