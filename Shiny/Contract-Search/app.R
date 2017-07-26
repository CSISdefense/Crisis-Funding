library(shiny)
library(tidyverse)
source("lookup_function.R")
options(shiny.maxRequestSize=3000*1024^2)

ui <- fluidPage(
    ####CSS Import of Google Font "Open Sans" for body  
    tags$style(HTML("
                    @import url('//fonts.googleapis.com/css?family=Open+Sans');
                    body {
                    font-family: 'Open Sans',  sans-serif;
                    font-weight: 500;
                    line-height: 1.1;
                    color: #554449;
                    }
                    ")),
    tags$head(
      tags$style(HTML("body{background-color: #fcfcfc;}"))),
    tags$div(HTML("<div class='fusion-secondary-header'>
                  <div class='fusion-row'>
                  <div class='fusion-alignleft'><div class='fusion-contact-info'><center style=' padding:20px;'><a href='http://csis.org/program/international-security-program' target='_blank'><img class='logo' src='https://defense360.csis.org/wp-content/uploads/2015/08/ISP_new.png' width='40%'></a></center><a href='mailto:'></a></div></div>
                  </div>
                  </div>")),
    tags$style(HTML(".fusion-secondary-header {border-bottom: 3px solid #6F828F}")),
    br(), 
    ####Copy below to change slider color     
    tags$style(HTML(".irs-bar {background: #63c5b8}")),
    tags$style(HTML(".irs-bar {border-top: 1px #63c5b8}")),
    tags$style(HTML(".irs-bar {border-bottom: 1px #63c5b8}")),
    tags$style(HTML(".irs-single, .irs-to, .irs-from {background: #628582}")),
    #tags$style(HTML(".irs-slider {background: black}")),
    #  tags$style(HTML(".irs-grid-pol {display: absolute;}")),
    tags$style(HTML(".irs-max {color: #554449}")),
    tags$style(HTML(".irs-min {color: #554449}")),
    tags$style(HTML(".irs-bar-edge {border: 1px #63c5b8}")),
    tags$style(HTML(".irs-bar-edge {border-color: 1px #63c5b8}")),
    tags$style(HTML(".irs-bar-edge {border-color: 1px #63c5b8}")),
    ####         
    fluidRow(
      
      # left column - column sizes should add up to 12, this one is 3 so
      # the other one will be 9
      column(3, align = 'center',

             br(),

             fileInput('file1', 'Choose CSIS RData File',
                       accept=c('.RData')),
             
             textInput("num", label = "Please input Contract ID", value = ""),
             
             actionButton(inputId="Search","Search")
             ),

      # left column - column sizes should add up to 12, this one is 9 so
      # the other one will be 3 
      column(9, align = "center",
             div(
               style = "position:relative",
               tableOutput("table")
             )
      )
    )
  )

server <- function(input, output, session){
    
    observeEvent(input$Search,{
                 
            if (is.null(input$file1)) return(NULL)
            inFile <- isolate({input$file1})
            file <- inFile$datapath
                 
            # load the file into new environment and get it from there
            e = new.env()
            name <- load(file, envir = e)
            data <- e[[name]]
                 
            output$table <- renderTable({
              Contract_Id_Lookup(data,input$num)
            })
    }         
 )
}  

# Run the application 
shinyApp(ui = ui, server = server)

