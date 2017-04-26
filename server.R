#
# Nimo Rides 
#------------

library(shiny)
library(tidyverse)
library(lubridate)
library(stringr)
library(scales)
library(leaflet)
library(plotly)
library(DT)

nimo <- read_csv("nimo.csv") # Load data

# Server logic for shiny web app
#-----------------------------------

shinyServer(function(input, output) {
        
        nimo_f <- reactive({nimo %>%
                        filter(distance_km >= input$distance[1],
                               distance_km <= input$distance[2],
                               vertical_m >= input$vert[1],
                               vertical_m <= input$vert[2],
                               date >= input$date[1],
                               date <= input$date[2])
                        })

        kms <- reactive({sum(nimo_f()$distance_km)})
        vms <- reactive({sum(nimo_f()$vertical_m)})
        nos <- reactive({nrow(nimo_f())})

        output$km <- renderText({format(kms(), big.mark=",")})  # total km's
        output$vm <- renderText({format(vms(), big.mark=",")})  # total vm's
        output$no <- renderText({nos()})  # total no of events
        
        output$ridePlot <- renderPlotly({
                plot_ly(nimo_f(), 
                        x = ~date,
                        y = ~distance_km,
                        type = "scatter",       
                        mode = "markers",       
                        size = ~yes_rsvp_count,
                        color = ~vertical_m,
                        hoverinfo = "text",
                        text = ~paste("<b>", event_title, "</b>",
                                      "</br> Date: ", format(date, "%a, %d %b %Y"),
                                      "</br> Distance: ", distance_km, " km",
                                      "</br> Elevation Gain: ", vertical_m, " vm",
                                      "</br> Number of Riders: ", yes_rsvp_count)) %>%
                        layout(xaxis = list(range = c(as.numeric(as_datetime("2016-06-01"))*1000, 
                                                      as.numeric(Sys.time())*1000),
                                            title = "Date"),
                               yaxis = list(title = "Distance (km)")) %>%
                        colorbar(title = "Elevation Gain (vm)")
                })
        
# Create data table with selected columns        
        output$rideTable <- renderDataTable({
                z <- nimo_f() %>% 
                        select(href_short, date, distance_km, vertical_m,
                        route_href)
                z}, 
                escape = FALSE, 
                colnames = c("Title", "Date", "Distance (km)",
                             "Elevation Gain (vm)", "Route Map"))

# Create interactive map output
        bicycle_icon <- awesomeIcons(icon = "bicycle", 
                                     library = "fa",
                                     iconColor = "white",
                                     markerColor = "red")
                        
        popup_text <- reactive({paste("<b>", nimo_f()$href,"</b><br/>", 
                                      nimo_f()$date, sep = "")})
        
        output$rideMap <- renderLeaflet({nimo_f() %>%
                        leaflet() %>%
                        addTiles() %>%
                        addAwesomeMarkers (clusterOptions = markerClusterOptions(),
                                   popup = popup_text(),
                                   icon = bicycle_icon)
        })
})

