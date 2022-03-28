# Shiny app to run fwoxy.R
# 2021-04-05 Jill Arriola
# fwoxy.R is housed at https://github.com/jmarriola/fwoxy
#
#
library(shiny)
library(devtools)
devtools::install_github('jmarriola/fwoxy@v1.0')
library(fwoxy)
library(ggplot2)
library(grid)
library(gridExtra)
library(lattice)
library(tidyr)
library(markdown)

# Define UI for fwoxy
# Each slider is an input into the fwoxy model
# Ranges are set in the sliderInput with the initial value set at equilibrium
ui <- fluidPage(
   # Application title
   titlePanel("Forward Oxygen Model"),
   
   # Sidebar with slider inputs for parameters and forcings of model
   sidebarLayout(
     sidebarPanel(
       
      sliderInput("oxy_ic", h4(HTML(paste0("Initial oxygen concentration (mmol/m",tags$sup("3"),")"))),
                  min = 100, max = 300, value = 250, step = 25),
      
      sliderInput("a_param", h4(HTML(paste0("Light efficiency ((mmol/m",tags$sup("3"),") / (W/m",tags$sup("2"),"))"))),
                  min = 0.1, max = 1.0, value = 0.2, step = 0.1),
      
      sliderInput("er_param", h4(HTML(paste0("Ecosystem respiration (mmol/m",tags$sup("3"),"/day)"))),
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
      plotOutput('fluxPlot'),
      br(),
      fluidRow(
        align = "center",
        em(span("ER = Ecosystem Respiration;", style = "color:darkviolet"),
         span("GPP = Gross Primary Productivity;", style = "color:orange"),
         span("GASEX = Gas Exchange;", style = "color:firebrick"),
         span("TROC = Time Rate of Change of Oxygen", style = "color:steelblue"))),
      br(),
      actionButton("show", "Help")
    )
  ))


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
     results <- fwoxy(oxy_ic = oxy_ic, a_param = a_param, er_param = er_param, ht_in = ht_const, 
             salt_in = salt_const, temp_in = temp_const, wspd_in = wspd_const)
    
     
     # Set up plots
     labels <- c('1'='0','43201'='12','86401'='0','129601'='12','172801'='0',
                 '216001'='12','259201'='0','302401'='12','345601'='0','388801'='12',
                 '432001'='0','475201'='12')
     breaks <- seq(1,518400,by=43200)
     varb <- c('t', 'c', 'dcdtd', 'gasexd', 'gppd', 'erd', 'oxysu', 'wspd2', 'sc', 'kw')
     colnames(results) <- varb
     
    
     # Oxygen Concentration plot
     
      oxyPlot <- ggplot(results, aes(x = t, y = c)) +
                 geom_line(colour = "blue", size = 1.05) +
                 labs(x = "Hour of day", y = bquote("oxy, mmol/"~m^3), title = "Dissolved Oxygen Concentration") +
                 theme_bw() +
                 scale_x_continuous(breaks = breaks, labels = labels) +
                 theme(axis.text=element_text(size=12), axis.title=element_text(size=14),
                       plot.title=element_text(size=20, face="bold"))
      
      print(oxyPlot)
    }
  )  
  
  # Plot 2
  output$fluxPlot <- renderPlot({ 
    
    # Input from UI
    oxy_ic <- input$oxy_ic
    a_param <- input$a_param
    er_param <- input$er_param
    ht_const <- input$ht_const
    salt_const <- input$salt_const
    temp_const <- input$temp_const
    wspd_const <- input$wspd_const
    
    
    # Run fwoxy R package
    results <- fwoxy(oxy_ic = oxy_ic, a_param = a_param, er_param = er_param, ht_in = ht_const, 
            salt_in = salt_const, temp_in = temp_const, wspd_in = wspd_const)
  
    
    # Set up plots
    labels <- c('1'='0','43201'='12','86401'='0','129601'='12','172801'='0',
                '216001'='12','259201'='0','302401'='12','345601'='0','388801'='12',
                '432001'='0','475201'='12')
    breaks <- seq(1,518400,by=43200)
    varb <- c('t', 'c', 'dcdtd', 'gasexd', 'gppd', 'erd', 'oxysu', 'wspd2', 'sc', 'kw')
    colnames(results) <- varb
    colors <- c(GASEX = "firebrick", GPP = "orange", ER = "darkviolet", TROC = "steelblue3")
    fluxes <- data.frame(results$t, results$gasexd, results$gppd, results$erd, results$dcdtd)
    colnames(fluxes) <- c('t', 'GASEX', 'GPP', 'ER', 'TROC')
    resultsNew <- fluxes %>% pivot_longer(cols = GASEX:TROC, names_to = 'Variables', values_to = "Value")
    
    # Plot fluxes
    fluxPlot <- ggplot(resultsNew, aes(x = t, y = Value, group = Variables, color = Variables)) +
      theme_bw() +
      geom_line(size = 1.05) +
      labs(x = "Hour of day", y = bquote("Flux, mmol/"~m^3/day), title = "Fluxes") +
      scale_color_manual(values = colors) +
      scale_x_continuous(breaks = breaks, labels = labels) +
      theme(legend.position = c(0.96,0.85), axis.text=element_text(size=12), axis.title=element_text(size=14),
            legend.title=element_blank(), legend.text=element_text(size=12), 
            plot.title=element_text(size=20, face="bold"))
  
    print(fluxPlot)
  }
 )
   
   observeEvent(input$show, {
    showModal(modalDialog(
      withMathJax(includeMarkdown("./fwoxy_doc.Rmd")),
      title = "Help",
      footer = modalButton("Dismiss"),
      size = c("l"),
      easyClose = TRUE
    ),
    )
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

