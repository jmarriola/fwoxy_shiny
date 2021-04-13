# Shiny app to run fwoxy.R
# 2021-04-05 Jill Arriola
# fwoxy.R is housed at https://github.com/jmarriola/fwoxy
#
#
library(shiny)
library(devtools)
devtools::install_github('jmarriola/fwoxy')
library(fwoxy)
library(fwoxy)
library(ggplot2)
library(grid)
library(gridExtra)
library(lattice)
library(tidyr)

# Define UI for fwoxy
# Each slider is an input into the fwoxy model
# Ranges are set in the sliderInput with the initial value set at equilibrium
ui <- fluidPage(
   # Application title
   titlePanel("Forward Oxygen Model"),
   
   # Sidebar with slider inputs for parameters and forcings of model
   sidebarLayout(
     sidebarPanel(
       
       sliderInput("oxy_ic", h4("Oxygen Concentration (mmol/m3)"),
                   min = 100, max = 300, value = 250, step = 25),
       
       sliderInput("a_param", h4("Light efficiency (W/m2)"),
                        min = 0.1, max = 1.0, value = 0.2, step = 0.1),
       
       sliderInput("er_param", h4("Ecosystem respiration (mmol/m3)"),
                        min = 0, max = 80, value = 20, step = 10),
       
       sliderInput("ht_const", h4("Depth of water (m)"),
                        min = 0.5, max = 5.0, value = 3.0, step = 0.5),
       
       sliderInput("salt_const", h4("Salinity (ppt)"),
                        min = 5, max = 35, value = 25, step = 5),
       
       sliderInput("temp_const", h4("Water temperature (deg C)"),
                        min = 15, max = 30, value = 25, step = 5),
       
       sliderInput("wspd_const", h4("Wind speed (m/s)"),
                        min = 0, max = 6, value = 3, step = 1) 
       
     ),
   # Output panel 
   mainPanel(
        plotOutput('oxyPlot'),
        plotOutput('fluxPlot')
      
    )
  )
)


# Define server logic required to output oxy concentrations and fluxes
server <- function(input, output) {

  # Plot 1
  output$oxyPlot <- renderPlot({ 
  
    # Input from UI
     oxy_ic <- input$oxy_ic
     a_param <- input$a_param
     er_param <- input$er_param
     ht_const <- input$ht_const
     salt_const <- input$salt_const
     temp_const <- input$temp_const
     wspd_const <- input$wspd_const
    
     
     # Run fwoxy R package
     results <- reactive({
       fwoxy(oxy_ic = oxy_ic, a_param = a_param, er_param = er_param, ht_in = ht_const, 
             salt_in = salt_const, temp_in = temp_const, wspd_in = wspd_const)
     })
     
     # Set up plots
     labels <- c('1'='0','43201'='12','86401'='0','129601'='12','172801'='0',
                 '216001'='12','259201'='0','302401'='12','345601'='0','388801'='12',
                 '432001'='0','475201'='12')
     breaks <- seq(1,518400,by=43200)
    
     
     # Oxygen Concentration plot
     
      oxyPlot <- ggplot(results, aes(x = t, y = c)) +
                 geom_line(colour = "blue") +
                 labs(x = "Hour of day", y = "oxy, mmol/m3") +
                 theme_bw() +
                 scale_x_continuous(breaks = breaks, labels = labels)
      
      print(oxyPlot)
    }
  )  
  
  # Plot 2
  #output$fluxPlot <- renderPlot({ 
    
    # Input from UI
    #oxy_ic <- input$oxy_ic
    #a_param <- input$a_param
    #er_param <- input$er_param
    #ht_const <- input$ht_const
    #salt_const <- input$salt_const
    #temp_const <- input$temp_const
    #wspd_const <- input$wspd_const
    
    
    # Run fwoxy R package
    #results <- reactive({
      #fwoxy(oxy_ic = oxy_ic, a_param = a_param, er_param = er_param, ht_in = ht_const, 
            #salt_in = salt_const, temp_in = temp_const, wspd_in = wspd_const)
    #})
    
    # Set up plots
    #labels <- c('1'='0','43201'='12','86401'='0','129601'='12','172801'='0',
               # '216001'='12','259201'='0','302401'='12','345601'='0','388801'='12',
               # '432001'='0','475201'='12')
    #breaks <- seq(1,518400,by=43200)
    #colors <- c(gasexd = "red3", gppd = "orange", erd = "purple4", dcdtd = "steelblue3")
    #fluxes <- data.frame(t, gasexd, gppd, erd, dcdtd)
    #resultsNew <- fluxes %>% pivot_longer(cols = gasexd:dcdtd, names_to = 'Variables', values_to = "Value")
    
    # Plot fluxes
    #fluxPlot <- ggplot(resultsNew, aes(x = t, y = Value, group = Variables, color = Variables)) +
     # theme_bw() +
     # geom_line() +
     # labs(x = "Hour of day", y = "Flux, mmol/m3/day") +
     # scale_color_manual(values = colors) +
     # scale_x_continuous(breaks = breaks, labels = labels)
  
    #print(fluxPlot)
  #}
 #)
}

# Run the application 
shinyApp(ui = ui, server = server)

