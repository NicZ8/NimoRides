#
# NimoRides User Interface
#---------------------------

library(shiny)
library(leaflet)
library(plotly)
library(DT)

shinyUI(fluidPage(
  
  titlePanel("Nimo Rides Data"),
  
  sidebarLayout(
    sidebarPanel(
            h4("What are Nimo Rides?"),
            p(a(href = "https://www.meetup.com/melbournecycling/", "Melbourne Cycling"),
                "is a social Meetup group in Melbourne/Australia. 
                Since June 2016, my husband and I have been event hosts in that group. 
                We lead hard and hilly road rides which have come to be known as
                Nimo Rides due to our nick names (Nic + Damo = Nimo)."),
            p("With this app you can explore data of all Nimo Rides. 
              Select your input below."),
            dateRangeInput("date", "Date Range:", 
                           start = "2016-06-01", end = Sys.Date(), 
                           min = "2016-06-01", max = Sys.Date(), 
                           format = "dd/mm/yy", weekstart = 1),
            sliderInput("distance", "Distance (km):",
                        min = 0, max = 200,
                        value = c(50, 190)),
            sliderInput("vert", "Elevation Gain (vm):",
                        min = 0, max = 3500,
                        value = c(500, 3300)),
            br(),
            p("Data current as of 21 April 2017")
    ),
    
    mainPanel(
            tabsetPanel(type = "tabs", 
                        tabPanel("Graph", br(),
                                 p("Each point represents a cycling event. 
                                   Hover your mouse over a point to get the ride details.
                                   The colour of the point indicates the ride's elevation gain
                                   and the size indicates the number of riders."),
                                 plotlyOutput("ridePlot"),
                                 br(),
                                p("Total number of events:  ",
                                  strong(textOutput("no", inline = TRUE),
                                         style = "color:blue")),
                                p("Total Distance (km):  ",
                                  strong(textOutput("km", inline = TRUE),
                                         style = "color:blue")),
                                p("Total Elevation Gain (vertical m):  ",
                                  strong(textOutput("vm", inline = TRUE), 
                                         style = "color:blue"))),
                                 
                        tabPanel("Map", br(),
                                 p("Each pin represents a cycling event at its starting location. 
                                   Zoom the map by clicking on a cluster or 
                                   use the +/- buttons. 
                                   Click on a pin to get the ride details with a 
                                   link to the event website."),
                                 leafletOutput("rideMap")),
                        
                        tabPanel("Table", br(),
                                 p("This is a list of rides including links to the 
                                        event page and route map. To refine the results, 
                                        enter a search term or sort by column."),
                                 dataTableOutput("rideTable"))
            )
    )
  )
))
