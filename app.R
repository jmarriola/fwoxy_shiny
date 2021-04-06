# Shiny app to run fwoxy.R
# 2021-04-05 Jill Arriola
# fwoxy.R is housed at https://github.com/jmarriola/fwoxy
#
#
library(shiny)
library(devtools)
devtools::install_github('jmarriola/fwoxy')

# Define UI for fwoxy
# Each slider is an input into the fwoxy model
# Ranges are set in the sliderInput with the initial value set at equilibrium
ui <- fluidPage(
   # Application title
   titlePanel("Forward Oxygen Model"),
   
   # Sidebar with slider inputs for parameters and forcings of model
   sidebarLayout(
     sidebarPanel(
       
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
   # Output panel with tabs for each plot
   mainPanel(
    tabsetPanel(
      tabPanel("Oxygen Concentration", plotOutput("oxyPlot")),
      tabPanel("Fluxes", plotOutput("fluxPlot"))
      )
    )
  )
)


# Define server logic required to output oxy concentrations and fluxes
server <- function(input, output) {
  
   # Oxygen Concentration plot
   output$fluxPlot <- renderPlot({
     
     # Input from UI
     a_param <- input$a_param
     er_param <- input$er_param
     ht_const <- input$ht_const
     salt_const <- input$salt_const
     temp_const <- input$temp_const
     wspd_const <- input$wspd_const
     
     
     
   })
   
}

# Run the application 
shinyApp(ui = ui, server = server)

