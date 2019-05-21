################################################################################
# Vendor Size Charts Interactive App
# L.Lipsey for DIIG May 2016
# test
################################################################################
library(readr)
require(shiny)
require(ggplot2)
library(dplyr)
require(scales)
require(Cairo)
require(grid)
require(gridExtra)
library(forcats)
library(shinyBS)
library(shinyjs)
library(stringr)

# Data.r.a <- filter(Data, Account == "RDT&E" & Organization == "Army")
# Data.p.a <- filter(Data, Account == "Procurement" & Organization == "Army")
# Data.r.n <- filter(Data, Account == "RDT&E" & Organization == "Navy")
# Data.p.n <- filter(Data, Account == "Procurement" & Organization == "Navy")
# Data.r.f <- filter(Data, Account == "RDT&E" & Organization == "Air Force")
# Data.p.f <- filter(Data, Account == "Procurement" & Organization == "Air Force")
# 
# # Data.r.a$PT <- fct_drop(Data.r.a$PT)
# # Data.p.a$PT <- fct_drop(Data.p.a$PT)
# # 
# # Data.r.n$PT <- fct_drop(Data.r.n$PT)
# # Data.p.n$PT <- fct_drop(Data.p.n$PT)
# # 
# # Data.r.f$PT <- fct_drop(Data.r.f$PT)
# # Data.p.f$PT <- fct_drop(Data.p.f$PT)
# 
# PT.r.a <- levels(as.factor(Data.r.a$PT))
# PT.p.a <- levels(as.factor(Data.p.a$PT))
# 
# PT.r.n <- levels(as.factor(Data.r.n$PT))
# PT.p.n <- levels(as.factor(Data.p.n$PT))
# 
# PT.r.f <- levels(as.factor(Data.r.f$PT))
# PT.p.f <- levels(as.factor(Data.p.f$PT))


################################################################################
# Visual settings for user interface
################################################################################
Data <- read_csv("O_and_M.csv")


####
# PT.r.a1 
# PT.r.a2 
# PT.r.a3 
# PT.r.a4 
# PT.r.a5 
# PT.r.a6 
# PT.r.a7 
# 
# PT.p.a1 
# PT.p.a2 
# PT.p.a3
# PT.p.a4 
# PT.p.a5 
# 
# PT.r.n1 
# PT.r.n2 
# PT.r.n3 
# PT.r.n4 
# PT.r.n5 
# PT.r.n6 
# PT.r.n7
# 
# PT.p.n1 
# PT.p.n2 
# PT.p.n3 
# PT.p.n4 
# PT.p.n5 
# PT.p.n6 
# 
# PT.r.f1 
# PT.r.f2 
# PT.r.f3
# PT.r.f4 
# PT.r.f5 
# PT.r.f6 
# PT.r.f7 
# 
# PT.p.f1 
# PT.p.f2 
# PT.p.f3 
# PT.p.f4 
# PT.p.f5 

Organization <- c(
  "Army", 
  "Navy",
  "Air Force")

Type <- c("Obligated",
  "PB", "Enacted")



AGtitle <- levels(as.factor(Data$AGtitle))

SAG.Title <- levels(as.factor(Data$SAG.Title))



# Category1 <-
#   c(
# "Advanced Component Development and Prototypes",
# "Advanced Technology Development",            
# "Air Force - Aircraft",                       
# "Air Force - Ammunition",                     
# "Air Force - Missiles",                       
# "Air Force - Other",                          
# "Air Force - Space",                          
# "Applied Research",                           
# "Army - Aircraft",                            
# "Army - Ammunition",                          
# "Army - Missiles",                            
# "Army - Other",                               
# "Army - Weapons/Vehicles",                    
# "Basic Research",                             
# "Navy - Aircraft",                            
# "Navy - Ammunition",                          
# "Navy - Marine Corps",                        
# "Navy - Other",                               
# "Navy - Shipbuilding",                        
# "Navy - Weapons",                             
# "Operational Systems Development",            
# "RDT&E Management Support",                   
# "System Development and Demonstration")  

Category2 <-
  c(
    "Air Force - Mobilization",    
    "Air Force - Administration and Servicewide Activities",   
    "Air Force - Operating Forces",     
    "Air Force - Training and Recruiting",
    "Air Force - Concept Obligations",
    "Air Force - Environmental Restoration",
    "Army - Afghanistan Infrastructure Fund",
    "Army - Mobilization",    
    "Army - Administration and Servicewide Activities", 
    "Army - Associated Activities",
    "Army - Defense Security Forces",
    "Army - Ministry of Defense",
    "Army - Ministry of Interior",
    "Army - Training and Recruiting",
    "Army - Detainee Ops",
    "Army - Syria Train and Equip Fund",
    "Army - Iraq Train and Equip Fund",
    "Army - Concept Obligations",
    "Army - Environmental Restoration",
    "Navy - Mobilization",    
    "Navy - Administration and Servicewide Activities",
    "Navy - Department Of The Navy", 
    "Navy - Concept Obligations",
    "Navy - Operating Forces",     
    "Navy - Training and Recruiting",
    "Navy - Environmental Restoration"
  )


# Category1 <-
#   c(
#     "Basic Research",    
#     "Applied Research",   
#     "Advanced Technology Development",     
#     "Advanced Component Development & Prototypes",
#     "System Development & Demonstration",  
#     "RDT&E Management Support",                    
#     "Operational Systems Development"                      
# ) 

# contract.type <- c("Combination", 
#                    "Cost Reimbursement", 
#                    "Fixed Price",
#                    "Time and Materials", 
#                    "Other",
#                    "Unlabeled")
# 
# classification <- c("Competition with single offer", 
#                     "Effective Competition", 
#                     "No competition", 
#                     "Unlabeled")

# here's the ui section - visual settings for the plot + widgets
ui <- fluidPage(
  
  tags$head(
    tags$style(HTML(
      ".well{ 
      background-color: #FCFCFC;
      border-color: #FCFCFC; 
      }"))),
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
  tags$style(type="text/css",
             ".shiny-output-error { visibility: hidden; }",
             ".shiny-output-error:before { visibility: hidden; }"
  ), 
  tags$style(HTML(".btn {background-color: #256A93}")),
  tags$style(HTML(".btn {color: white}")),
  tags$style(HTML(".btn:hover {background-color: #115175}")),
  tags$style(HTML(".btn:hover {color: white}")),
  tags$style(HTML(".btn:active:hover {background-color: #6BC6B5}")),
  tags$style(HTML(".btn:dropdown-toggle {background-color: red}")),
  
  tags$style(HTML(".popover({delay: {show: 500, hide: 100}})")), 
  tags$style(HTML(".btn-primary {background-color: #BDD4DE}")),
  tags$style(HTML(".btn-primary {color: #554449}")),
  tags$style(HTML(".btn-primary:hover {background-color: #A5B9C2}")),
  tags$style(HTML(".btn-primary:hover {color: #554449}")),
  tags$style(HTML(".btn-primary:active:hover{background-color: #6BC6B5}")),
  tags$style(HTML(".btn-primary:dropdown-toggle {background-color: #BDD4DE}")),
  
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
    sidebarPanel(
      shinyjs::useShinyjs(),
      id = "side-panel", 
      # column(, align = 'center'), 
      # left column - column sizes should add up to 12, this one is 3 so
      # the other one will be 9
      # column(4, align = 'center',
      # br(),
      

      
    
        # Type slider
        sliderInput('Yr', " ",
                    min = 2010, max = 2017,
                    value = c(2010,2017),
                    ticks = FALSE,
                    step = 1, width = '100%', sep = ""),
      
 
      selectizeInput("view", "", 
                     c("Standard View", 
                       "Info", 
                       "Difference"), selected = "Standard View"), 
      
      br(), 

          
        hr(), 
        
        
        
        conditionalPanel(
        condition = "input.view != 'Difference'",
          # div(style="display:inline-block;vertical-align:top",
          # div(style="display:inline-block;vertical-align:top",
              selectizeInput("PT2","Budget Type",
                             c(        "PB" ,
                                       "Enacted" ,
                                       "Obligated"), 
                             multiple = FALSE,
                             # selectize = FALSE,
                             selected = Type,
                             # width = '125px',
                             size = 25)),
      
      conditionalPanel(
        condition = "input.view == 'Info'",
        
        hr(), 
        
        helpText(
          HTML(
            # paste0(
            
            "<div align = 'center'>", 
            "<b> Background Information </b>", 
            "</div>",
            "<br/>",
            
            "<div align = 'left'>",
            "<br/>",
            "CSIS has embarked on a project to create a centralized FYDP database that is interpretable and universally accessible. This is part of a broader effort to create tools that make it easier to understand the defense budget and plans for defense investments.", 
            "<br/>",
            "<br/>", 
            
            "This app includes FYDP data from the president's budget requests for FY 2014 to FY 2018, for the Procurement and Research, Development, Test and Evaluation (RDT&E) accounts. The data was mined from P-40s (for Procurement) and R-2s (for RDT&E), as well as from the DoD Greenbook. ", 
            "<br/>",
            "<br/>", 
            "This is an ongoing project that we plan to build upon. If you have any questions or comments, please contact Gabriel Coll (gcoll@csis.org). ",
            
            "<br/>",
            "</div>"
            
          )),
        
        align = "center"), 
      
      

      bsButton(
        inputId = "info_btn",
        label = strong("Deep Dive - Budget Activity"),
        style = "default",
        type = "toggle", 
        size = "default",
        block = TRUE,
        width = '100%',
        value = FALSE), align = 'center',
      
      br(), 
      
      conditionalPanel(
        
        condition = "input.info_btn == 1",
        bsButton(
          inputId = "info_btn2",
          label = (strong("Deeper - Sub Activity")),
          style = "default",
          type = "toggle", 
          size = "default",
          block = TRUE,
          width = '90%'), align = 'center'),
      
      br(), 
      
      conditionalPanel(
        
        condition = "input.info_btn == 1 & input.info_btn2 == 1",
        bsButton(
          inputId = "info_btn3",
          label = (strong("Deepest - Program Title")),
          style = "default",
          type = "toggle", 
          size = "default",
          block = TRUE,
          width = '80%'), align = 'center'),
      
      conditionalPanel(
        
        condition = "input.info_btn == 0",
        # br(), 
        selectInput("Organization", "Organization", 
                    Organization, 
                    multiple = TRUE, 
                    selectize = FALSE,
                    selected = Organization,
                    # inline = TRUE,
                    width = '90%')),

      br(), 
      
      # selectInput("Category","Category",
      #             Category,
      #             multiple = TRUE,
      #             selectize = FALSE,
      #             selected = Category,
      #             width = '100%',
      #             size = 7),
      
      conditionalPanel(
        condition = "input.info_btn == 1 & input.info_btn2 == 0",
        selectInput("BudgetActivity","Budget Activity",
                    list(
                      'Air Force' = c("Air Force - Mobilization",    
                                      "Air Force - Administration and Servicewide Activities",   
                                      "Air Force - Operating Forces",     
                                      "Air Force - Training and Recruiting",
                                      "Air Force - Concept Obligations",
                                      "Air Force - Environmental Restoration"
                      ),
                      
                      'Army' = c(    "Army - Afghanistan Infrastructure Fund",
                                     "Army - Mobilization",    
                                     "Army - Administration and Servicewide Activities", 
                                     "Army - Associated Activities",
                                     "Army - Operating Forces", 
                                     "Army - Ministry of Defense",
                                     "Army - Ministry of Interior",
                                     "Army - Training and Recruiting",
                                     "Army - Detainee Ops",
                                     "Army - Syria Train and Equip Fund",
                                     "Army - Related Activities",
                                     "Army - Iraq Train and Equip Fund" ,
                                     "Army - Concept Obligations",
                                     "Army - Environmental Restoration"
                      ),
                      
                      'Navy' = c( "Navy - Mobilization",    
                                "Navy - Administration and Servicewide Activities",
                                  "Navy - Department Of The Navy", 
                                  "Navy - Concept Obligations",
                                  "Navy - Operating Forces",     
                                  "Navy - Training and Recruiting",
                                  "Navy - Environmental Restoration"
                      )
                      ), 
                    multiple = TRUE,
                    selectize = FALSE,
                    selected = Category2,
                    width = '100%',
                    size = 25),
        align = "center"), 
      
      conditionalPanel(
        condition = "input.info_btn == 1 & input.info_btn2 == 1 & input.info_btn3 == 0",
        selectizeInput("AGtitle","Sub Activity",
                        AGtitle,
                       multiple = TRUE,
                       # selectize = FALSE,
                       selected = " ",
                       width = '100%',
                       size = 25),
        align = "center"),
      
      conditionalPanel(
        condition = "input.info_btn == 1 & input.info_btn2 == 1 & input.info_btn3 == 1",
        selectizeInput("SAG.Title","Program Title",
                       # PT, 
                       SAG.Title,
                       multiple = TRUE,
                       # selectize = FALSE,
                       selected = " ",
                       width = '100%',
                       size = 25),
        align = "center"),
      
      br(), 
        
        selectizeInput("Checkbox", "Type",  
                       Type,
                       multiple = TRUE, 
                       # selectize = FALSE,
                       selected = c(
                         
                         "PB" ,
                         "Obligated" ,
                         "Enacted"),
                       # size = 7, 
                       width = '90%'),
        align = "center", 
      
      br(),
      
      
      conditionalPanel(
        
        condition = "input.info_btn != 3",
        # div(style="display:inline-block",
        bsButton(
          inputId = "reset_input",
          label = strong("Reset"),
          style = "primary",
          size = "default",
          width = '100%', 
          block = TRUE
        ), align = 'center'), 
      
      br(), 
      br(), 
      
      div(style="display:inline-block",
          
          radioButtons("Chart", "Dollars",
                       c("Then-Type", "Constant"),
                       inline = TRUE,
                       selected = "Then-Type",
                       width = '100%'), align = 'center'), 
      
      # br(), 
      # div(), 
      p(), 
      
      div(style="display:inline-block",
          radioButtons("Axis", "Y-Axis Min",
                       c("Zero", "Auto"),
                       inline = TRUE,
                       selected = "Zero"), align = 'center'), 
      
      # helpText(HTML("<strong>Directions:</strong>",
      #               "click on each bar for more detailed information"
      # ))
      
      
      
      br(),
      br(), 
      
      downloadLink('CSVDownloadBtn',
                   "Download Displayed Data (csv)", class = NULL)
    ),
    
    #br(),
    #br(), 
    #downloadButton('FullDownloadBtn',  
    #                "Download Full Data (csv)")
    #),
    
    # left column - column sizes should add up to 12, this one is 9 so
    # the other one will be 3 
    # column(8, align = "center",
    mainPanel(
      div(
        style = "position:relative",
        plotOutput("plot", height = "400px",  
                   hover = hoverOpts(id = "plot_hover", delay = 30)),
        uiOutput("hover_info"),
        
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # br(),
        # # hr(),
        # br(),
        # br(),
        
        # column(3, 
        # bsButton(
        #   inputId = "button_one",
        #   label = strong("Info"),
        #   style = "primary",
        #   type = "toggle", 
        #   size = "default",
        #   width = '100%', 
        #   block = TRUE
        # )),
        # 
        # column(6, 
        # bsButton(
        #   inputId = "button_two",
        #   label = strong("Standard View"),
        #   style = "default",
        #   type = "toggle", 
        #   size = "default",
        #   width = '100%', 
        #   block = TRUE
        # )),
        
        conditionalPanel(
          
          condition = "input.info_btn != 3 & input.view == 'NaN'",
        column(3, 
        bsButton(
          inputId = "Darkmatter",
          label = strong("Dark Matter"),
          style = "primary",
          type = "toggle", 
          size = "default",
          width = '100%', 
          block = TRUE
        )))
      ))))
  
  
  # end of ui section



# server function starts

server <- function(input, output, session){
  
  ################################################################################
  # Read in and clean up data
  ################################################################################      
  
  observeEvent(input$info_btn == 1,
  shinyjs::disable(input$view))
  # read in data            
  FullData <- read.csv("O_and_M.csv")
  FullData2 <- read.csv("O_and_M_div.csv")
  
  # load("FYDP.Rda")
  FullData <- FullData %>%
    filter(!is.na(Type))
  FullData$Type <- as.character(FullData$Type)
  

  
  colnames(FullData)[colnames(FullData) == "FiscalYear"] <- "FY"
  FullData$FY <- as.numeric(as.character(FullData$FY))
  FullData$Amount <- FullData$Amount * 10^3
  
  colnames(FullData2)[colnames(FullData2) == "FiscalYear"] <- "FY"
  FullData2$FY <- as.numeric(as.character(FullData2$FY))

  

  

 
  
  formaty1 <- function(x) {
    x <- gsub("000", "", x)
    x <- gsub("500", ".5", x)
    x <- gsub("250", ".25", x)
    x <- gsub("750", ".75", x)
    paste("$",x,"B",sep="")
  }
  
  label_one_value <- function(a_value, max_value, sig) {
    if(is.na(a_value)) return(NULL)
    if(max_value > 1e7){
      if(max_value > 1e11){
        if(max_value > 1e13){
          if(max_value > 1e15){
            return(as.character(a_value))
          } else if(max_value > 1e14){
            y_lab <- paste0(
              "$", formatC(a_value/1e12, max(sig, 0), format = "f"), "T")
          } else {
            y_lab <- paste0(
              "$", formatC(a_value/1e12, max(sig, 1), format = "f"), "T")
          }
        } else if(max_value > 1e12){
          y_lab <- paste0(
            "$", formatC(a_value/1e12, max(sig, 2), format = "f"), "T")
        } else {
          y_lab <- paste0(
            "$", formatC(a_value/1e9, max(sig, 0), format = "f"), "B")
        }
      } else if(max_value > 1e9){
        if(max_value > 1e10){
          y_lab <- paste0(
            "$", formatC(a_value/1e9, max(sig, 1), format = "f"), "B")
        } else {
          y_lab <- paste0(
            "$", formatC(a_value/1e9, max(sig, 2), format = "f"), "B")
        }
      } else {
        if(max_value > 1e8){
          y_lab <- paste0(
            "$", formatC(a_value/1e6, max(sig, 0), format = "f"), "M")
        } else {
          y_lab <- paste0(
            "$", formatC(a_value/1e6, max(sig, 1), format = "f"), "M")
        }
      }
    } else if(max_value > 1e3){
      if(max_value > 1e5){
        if(max_value > 1e6){
          y_lab <- paste0(
            "$", formatC(a_value/1e6, max(sig, 2), format = "f"), "M")
        } else {
          y_lab <- paste0(
            "$", formatC(a_value/1e3, max(sig, 0), format = "f"), "k")
        }
      } else if(max_value > 1e4){
        y_lab <- paste0(
          "$", formatC(a_value/1e3, max(sig, 1), format = "f"), "k")
      } else {
        y_lab <- paste0(
          "$", formatC(a_value/1e3, max(sig, 2), format = "f"), "k")
      }
    } else if(max_value > 10){
      if(max_value > 100){
        y_lab <- paste0("$", formatC(a_value, max(sig, 0), format = "f"))
      } else {
        y_lab <- paste0("$", formatC(a_value, max(sig, 1), format = "f"))
      }
    } else {
      y_lab <- paste0("$", formatC(a_value, max(sig, 2), format = "f"))
    }
    return(y_lab)
  }
  
  
  
  
  money_labels <- function(axis_values){
    
    if(class(axis_values) == "character"){
      warning(
        paste("money_labels() expects the axis to be a numeric variable",
              "but the axis is a character variable.  Coercing to numeric."))
      axis_values <- as.numeric(axis_values)
    } else if(class(axis_values) != "numeric" & class(axis_values)!= "integer"){
      stop(paste(
        "money_labels() expected a numeric axis, but got:",
        class(axis_values)))
    }
    axis_range <- max(axis_values, na.rm = TRUE) - min(axis_values, na.rm = TRUE)
    sig_digits <-  floor(log10(max(abs(axis_values), na.rm = TRUE))) -
      round(log10(axis_range))
    
    
    
    return(sapply(
      axis_values,
      label_one_value,
      max(abs(axis_values), na.rm = TRUE),
      sig_digits))
  }
  
  
  ################################################################################
  # Subset data based on user input
  ################################################################################
  
  dataset <- reactive({
    
    ## subset by Type, based on Type slider ##
    
    # input$Yr[1] is the user-selected minimum Type
    # input$Yr[2] is the user-selected maximum Type
    # as.numeric(levels(FY))[FY] is just FY, converted from a factor to
    # a numeric variable
 
    shown <- filter(FullData, FY >= input$Yr[1] & FY <= input$Yr[2])
    
  
    ## subset data based on which categories the user selected ##
    
    # the selectInput widget holds the selected choices as a vector of
    # strings. This code checks whether the each observation is in the
    # selected categories, and discards it if isn't in all three.  The %in%
    # operator is a nice way to avoid typing lots of conditional tests all
    # strung together 
   # shown <- filter(shown,
               #     grepl("Operation and Maitenance", AccountTitle) == TRUE )
    shown <- filter(shown, 
                    # Organization %in% input$Organization &
                    # Account %in% input$Account &
                    Type %in% input$Checkbox 
                    # Category2 %in% input$Category2
                    # Customer %in% input$Customer 
                    # Contract.Type %in% input$Contract & 
                    # Classification %in% input$Classification
    )

    
    if(input$info_btn == 0){
      shown <- filter(shown,
                      Organization %in% input$Organization)
          
      
    } else
      shown <- shown
    
    if(input$info_btn == 1 & input$info_btn2 == 0){
      shown <- filter(shown,
                      BudgetActivityTitle %in% input$BudgetActivity
      )
    } else
      shown <- shown
    
    # ##temp 
    if(input$info_btn == 1 & input$info_btn2 == 1 & input$info_btn3 == 0){
      shown <- filter(shown,
                      AGtitle %in% input$AGtitle
      )
      
    } else
      shown <- shown
    
    
    if(input$info_btn == 1 & input$info_btn2 == 1 & input$info_btn3 == 1){
      shown <- filter(shown,
                      SAG.Title %in% input$SAG.Title
      )
    } else
      shown <- shown
    
    
    # calculate percent of obligations for each VendorSize category
    shown <- shown %>%
      group_by(FY, Type) %>%
      summarise(Amount = sum(Amount, na.rm = TRUE))
    

    
 
    deflate <- c(
      "2010" = 0.8738,
      "2011" = 0.8916,
      "2012" = 0.9078,
      "2013" = 0.9232,
      "2014" = 0.9401,
      "2015" = 0.9511,
      "2016" = 0.9625,
      "2017" = 0.9802,
      "2018" = 1.0000,
      "2019" = 1.0199,
      "2020" = 1.0404,
      "2021" = 1.0612,
      "2022" = 1.0824)
    
    if(input$Chart == "Constant"){
      shown$Amount <- (shown$Amount / deflate[as.character(shown$FY)])
    } else 
      shown$Amount <- shown$Amount
    
    # return the subsetted dataframe to whatever called dataset()
    return(shown)
    
    # end of dataset() function      
  })
  
  
  dataset2 <- reactive({
    
    ## subset by Type, based on Type slider ##
    
    # input$Yr[1] is the user-selected minimum Type
    # input$Yr[2] is the user-selected maximum Type
    # as.numeric(levels(FY))[FY] is just FY, converted from a factor to
    # a numeric variable
    
    shown2 <- filter(FullData2, FY >= input$Yr[1] & FY <= input$Yr[2])
    
    
    ## subset data based on which categories the user selected ##
    
    # the selectInput widget holds the selected choices as a vector of
    # strings. This code checks whether the each observation is in the
    # selected categories, and discards it if isn't in all three.  The %in%
    # operator is a nice way to avoid typing lots of conditional tests all
    # strung together 
    # shown <- filter(shown,
    #     grepl("Operation and Maitenance", AccountTitle) == TRUE )
                    # Organization %in% input$Organization &
                    # Account %in% input$Account &
                    # Category2 %in% input$Category2
                    # Customer %in% input$Customer 
                    # Contract.Type %in% input$Contract & 
                    # Classification %in% input$Classification

    
    
    if(input$info_btn == 0){
      shown2 <- filter(shown2,
                      Organization %in% input$Organization)
      
      
    } else
      shown2 <- shown2
    shown2$Amount <- as.numeric(shown2$Amount)
    shown2$Amount2 <- as.numeric(shown2$Amount2)
    shown2$Amount3 <- as.numeric(shown2$Amount3)
    if(input$info_btn == 1 & input$info_btn2 == 0){
      shown2 <- filter(shown2,
                      BudgetActivityTitle %in% input$BudgetActivity
      )
    } else
      shown2 <- shown2
    
    # ##temp 
    if(input$info_btn == 1 & input$info_btn2 == 1 & input$info_btn3 == 0){
      shown2 <- filter(shown2,
                      AGtitle %in% input$AGtitle
      )
      
    } else
      shown2 <- shown2
    
    
    if(input$info_btn == 1 & input$info_btn2 == 1 & input$info_btn3 == 1){
      shown2 <- filter(shown2,
                      SAG.Title %in% input$SAG.Title
      )
    } else
      shown2 <- shown2
    
    
    # calculate percent of obligations for each VendorSize category
    shown2 <- shown2 %>%
      group_by(FY) %>%
      summarise(Amount = sum(Amount, na.rm = TRUE), Amount2 = sum(Amount2, na.rm = TRUE), 
                Amount3 = sum(Amount3, na.rm = TRUE))
    

    
    
    deflate <- c(
      "2010" = 0.8738,
      "2011" = 0.8916,
      "2012" = 0.9078,
      "2013" = 0.9232,
      "2014" = 0.9401,
      "2015" = 0.9511,
      "2016" = 0.9625,
      "2017" = 0.9802,
      "2018" = 1.0000,
      "2019" = 1.0199,
      "2020" = 1.0404,
      "2021" = 1.0612,
      "2022" = 1.0824)
    
    if(input$Chart == "Constant"){
      shown2$Amount <- (shown2$Amount / deflate[as.character(shown2$FY)])
    } else 
      shown2$Amount <- shown2$Amount
    
    if(input$Chart == "Constant"){
      shown2$Amount2 <- (shown2$Amount2 / deflate[as.character(shown2$FY)])
    } else 
      shown2$Amount2 <- shown2$Amount2
    
    if(input$Chart == "Constant"){
      shown2$Amount3 <- (shown2$Amount3 / deflate[as.character(shown2$FY)])
    } else 
      shown2$Amount3 <- shown2$Amount3
    
    # return the subsetted dataframe to whatever called dataset()
    return(shown2)
    View(shown2)
    # end of dataset() function      
  })
  
    
  

    plotsettings2 <- reactive({
      
      # ggplot call
    
        p <- ggplot(data = dataset(),
                    aes(x=FY, y=Amount, 
                        color=Type, group =Type, linetype = Type)) +
        geom_line(size = 1.5)  +
        ggtitle("Comparison of DoD FYDPs to FY18 Budget Request") +
        
        scale_linetype_manual(
          values = c(
            "PB" = "longdash",
            "Enacted" = "longdash",
            "Obligated" = "longdash"
          )) +
        
        scale_color_manual(
          values = c(
            "PB" = "#CE884E",
            "Enacted" =  "#C74F4F",
            "Obligated" = "#5F597C"
          )) +
        
        theme(plot.title = element_text(
          family = "Arial", color = "#554449", size = 22, face="bold",
          margin=margin(20,0,30,0), hjust = 0.5)) +
        
        theme(panel.border = element_blank(),
              panel.background = element_rect(fill = "#FCFCFC"),
              plot.background = element_rect(fill = "#FCFCFC", color="#FCFCFC"),
              #plot.background = element_rect(fill="#F9FBFF"), second choice
              #plot.background = element_rect(fill="#EFF1F5"),
              #plot.background = element_rect(fill="#ECF2F5"),
              panel.grid.major.x = element_blank(),
              panel.grid.minor.x = element_blank(),
              panel.grid.major.y = element_line(size=.1, color="lightgray"),
              panel.grid.minor.y = element_line(size=.1, color="lightgray")) +
        
        #scale_x_continuous() +
        scale_x_continuous(breaks = seq(input$Yr[1], input$Yr[2], by = 1),
                           labels = function(x) {substring(as.character(x), 3, 4)}) +
        
        theme(legend.position = "right") +
        theme(legend.title=element_blank()) +
        theme(legend.text = element_text(size = 18, color="#554449")) +
        theme(legend.text = element_text(size = 18, color="#554449")) +
        theme(legend.key = element_rect(fill="#fcfcfc", color = "#fcfcfc")) +
        theme(legend.background = element_rect(fill="#fcfcfc")) +
        theme(legend.key.width = unit(3,"line")) + 
        theme(axis.text.x = element_text(size = 14, color="#554449", margin=margin(-5,0,0,0))) +
        theme(axis.ticks.length = unit(.00, "cm")) +
        theme(axis.text.y = element_text(size = 14, color="#554449", margin=margin(0,5,0,0))) +
        theme(axis.title.x = element_text(size = 16, face = "bold", color="#554449", margin=margin(15,0,0,0))) +
        theme(axis.title.y = element_text(size = 16, face = "bold", color="#554449", margin=margin(0,15,0,0))) +
        
        xlab("Fiscal Type") +
        ylab((switch(input$Chart, 
                     Constant = "Constant FY18 Dollars", 
                     'Then-Type' = "Then-Type Dollars"))) + 
        
        theme(plot.caption = element_text(
          size = 12, face = "bold", color = "#554449", family = "Open Sans"
        )) +
        labs(caption = "Source: Future Types Defense Program; CSIS analysis", size = 30, family= "Open Sans") + 
        if(input$Axis == "Zero") {
          scale_y_continuous(breaks = scales::pretty_breaks(n = 8), labels = money_labels, limits = c(0, NA)) 
        } else if (input$Axis == "Auto") { 
          scale_y_continuous(breaks = scales::pretty_breaks(n = 8), labels = money_labels) 
        } else 
          scale_y_continuous(breaks = scales::pretty_breaks(n = 8), labels = money_labels, limits = c(0, NA))
      ##############################################################################facet above
      
      p     
    })
    
    plotsettings3 <- reactive({
      
      # ggplot call
      
      p <- ggplot(data = dataset2(),
                  aes(x=FY, y=Amount)) +
        geom_line(size = 1.5, aes( y = Amount, color = "Total"), linetype = "dashed")  + 
        geom_line(size = 1.5, aes(y = Amount2, color = "Base"), linetype = "dashed") +
        geom_line(size = 1.5, aes(y = Amount3, color = "OCO"), linetype = "dashed") +
        geom_ribbon(aes(ymin = Amount2, ymax = Amount), alpha = 0.75) +
        ggtitle("Comparison of DoD FYDPs to FY18 Budget Request") + 
       # scale_linetype_manual(values = c("Total" = "solid", "Base" = "dashed", "OCO" = "12345678" ))  +
        scale_color_manual(values = c("Total" = rgb(0.2,1,0.9), "Base" = rgb(0.4,0.6,1), "OCO" = rgb(0,0,1) )) +

        theme(plot.title = element_text(
          family = "Arial", color = "#554449", size = 22, face="bold",
          margin=margin(20,0,30,0), hjust = 0.5)) +
        
        theme(panel.border = element_blank(),
              panel.background = element_rect(fill = "#FCFCFC"),
              plot.background = element_rect(fill = "#FCFCFC", color="#FCFCFC"),
              #plot.background = element_rect(fill="#F9FBFF"), second choice
              #plot.background = element_rect(fill="#EFF1F5"),
              #plot.background = element_rect(fill="#ECF2F5"),
              panel.grid.major.x = element_blank(),
              panel.grid.minor.x = element_blank(),
              panel.grid.major.y = element_line(size=.1, color="lightgray"),
              panel.grid.minor.y = element_line(size=.1, color="lightgray")) +
        
        #scale_x_continuous() +
        scale_x_continuous(breaks = seq(input$Yr[1], input$Yr[2], by = 1),
                           labels = function(x) {substring(as.character(x), 3, 4)}) +
        
        theme(legend.position = "right") +
        theme(legend.title=element_blank()) +
        theme(legend.text = element_text(size = 18, color="#554449")) +
        theme(legend.text = element_text(size = 18, color="#554449")) +
        theme(legend.key = element_rect(fill="#fcfcfc", color = "#fcfcfc")) +
        theme(legend.background = element_rect(fill="#fcfcfc")) +
        theme(legend.key.width = unit(3,"line")) + 
        theme(axis.text.x = element_text(size = 14, color="#554449", margin=margin(-5,0,0,0))) +
        theme(axis.ticks.length = unit(.00, "cm")) +
        theme(axis.text.y = element_text(size = 14, color="#554449", margin=margin(0,5,0,0))) +
        theme(axis.title.x = element_text(size = 16, face = "bold", color="#554449", margin=margin(15,0,0,0))) +
        theme(axis.title.y = element_text(size = 16, face = "bold", color="#554449", margin=margin(0,15,0,0))) +
        
        xlab("Fiscal Type") +
        ylab((switch(input$Chart, 
                     Constant = "Constant FY18 Dollars", 
                     'Then-Type' = "Then-Type Dollars"))) + 
        
        theme(plot.caption = element_text(
          size = 12, face = "bold", color = "#554449", family = "Open Sans"
        )) +
        labs(caption = "Source: Future Types Defense Program; CSIS analysis", size = 30, family= "Open Sans") + 
        if(input$Axis == "Zero") {
          scale_y_continuous(breaks = scales::pretty_breaks(n = 8), labels = money_labels, limits = c(0, NA)) 
        } else if (input$Axis == "Auto") { 
          scale_y_continuous(breaks = scales::pretty_breaks(n = 8), labels = money_labels) 
        } else 
          scale_y_continuous(breaks = scales::pretty_breaks(n = 8), labels = money_labels, limits = c(0, NA))
      ##############################################################################facet above
      
      p     
    
    })
  
  ################################################################################
  # Output the built plot and start the app
  ################################################################################
  
  
  output$plot <- renderPlot({
    if(input$view == "Difference"){
      plotsettings3()}
      else{
      plotsettings2()}
  
    }, height = 700)
  
  output$CSVDownloadBtn <- downloadHandler(
    filename = paste('CSIS-FYDP-', Sys.Date(),'.csv', sep=''),
    content = function(file) {
      writedata <- dataset()
      writedata$Percent <- writedata$Percent * 100
      write.csv(writedata, file)
    }
  )
  
  
  # run full data download button
  output$FullDownloadBtn <- downloadHandler(
    filename = paste('CSIS-FYDP-', Sys.Date(),'.csv', sep=''),
    content = function(file) {
      writedata <- FullData
      writedata <- select(writedata, FY, Type, Organization,
                          Category2, BSA, PT, Amount)
      write.csv(writedata, file)
    }
  )
  
  # run displayed data download button
  #output$CSVDownloadBtn <- downloadHandler(
  #    filename = paste('DoD contract shares ', Sys.Date(),'.csv', sep=''),
  #    content = function(file) {
  #        writedata <- dataset()
  #        writedata$FY <- as.numeric(as.character(writedata$FY)) + 2000
  #        writedata$Percent <- writedata$Percent * 100
  #        writedata <- select(writedata, FY, VendorSize, Amount, Percent)
  #        write.csv(writedata, file)
  #    }
  #)
  
  ##############################################################################
  # Give details when user hovers the plot
  # See https://gitlab.com/snippets/16220
  ##############################################################################
  
  
  output$hover_info <- renderUI({
    hover <- input$plot_hover
    
    if(is.null(hover)) return(NULL)
    
    switch(
        input$Chart,
        # "Line" = {
        #   point <- nearPoints(dataset(), hover, xvar = "FY", yvar = "Percent",
        #                   threshold = (150 / (input$Yr[2] - input$Yr[1])) + 10,
        #                   maxpoints = 1, addDist = TRUE)
        # },
        "Constant" = {
          point <- nearPoints(dataset(), hover, xvar = "FY", yvar = "Amount",
                              threshold = 200,
                              maxpoints = 1, addDist = TRUE)
        },
        "Then-Type" = {
          point <- nearPoints(dataset(), hover, xvar = "FY", yvar = "Amount",
                              threshold = 200,
                              maxpoints = 1, addDist = TRUE)
        }
      )


    if(nrow(point) == 0) return(NULL)
      year <- round(hover$x)
      if(year < input$Yr[1] | year > input$Yr[2]) return(NULL)
      if(hover$y < 0) return(NULL)
      
      
      year <- point$FY
      hov_amount <- point$Amount
      


      
    
    # calculate point position INSIDE the image as percent of total dimensions
    # from left (horizontal) and from top (vertical)
    left_pct <- (hover$x - hover$domain$left) /
      (hover$domain$right - hover$domain$left)
    top_pct <- (hover$domain$top - hover$y) /
      (hover$domain$top - hover$domain$bottom)
    
    # calculate distance from left and bottom side of the picture in pixels
    left_px <- hover$range$left + left_pct *
      (hover$range$right - hover$range$left)
    top_px <- hover$range$top + top_pct *
      (hover$range$bottom - hover$range$top)
    
    # Use HTML/CSS to change style of tooltip panel here
    style <- paste0(
      "position:absolute; z-index:100; background-color: rgba(245, 245, 245, 0.85); ",
      "left:", left_px + 2, "px; top:", top_px + 2, "px;")
        wellPanel(
          style = style,
          p(HTML(paste0(
            "<b> Budget Type: </b>", point$Type, "<br/>",
            "<b> Fiscal Year: </b>", year, "<br/>",
            # "<b> Share: </b>", round(hov_percent*100,1), "%<br/>",
            "<b> Amount: </b> ",
            label_one_value(point$Amount, point$Amount, 0)
          ))))
  
          
  })
  
  observeEvent(input$reset_input, {
    shinyjs::reset("side-panel")
  })
  
  
  # end of the server function

}


# starts the app
shinyApp(ui= ui, server = server)