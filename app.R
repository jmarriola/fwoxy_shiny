# Shiny app to run fwoxy.R
# 2021-04-05 Jill Arriola
# fwoxy.R is housed at https://github.com/jmarriola/fwoxy
#
#
library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   titlePanel("Forward Oxygen Model"),
   
   sidebarLayout(
     sidebarPanel(
       h3("Parameters"),
     
       sliderInput("a_param", h4("Light efficiency"),
                        min = 0.1, max = 1.0, value = 0.2),
       
       sliderInput("er_param", h4("Ecosystem respiration"),
                        min = 0, max = 80, value = 20)
     ),
   
   mainPanel("Output")
  
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   
}

# Run the application 
shinyApp(ui = ui, server = server)

