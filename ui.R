
library(shiny)
library(TSA)
library(zoo)
library(quantmod)
library(forecast)
library(lubridate)
library(ggplot2)
library(dplyr)

output_dates = c()

# Define UI for application 
shinyUI(fluidPage(
  
  titlePanel("Anomaly Detection using ARIMA Models"),
  
    mainPanel(
      div(style="display: inline-block;vertical-align:top; width: 90px;",
      textInput(inputId = "ticker", 
                label = "Stock Ticker", 
                value = "TSLA", 
                width = NULL, placeholder = "FB, AAPL, MSFT, etc")),
      
      div(style="display: inline-block;vertical-align:top; width: 80px;",
      numericInput("alpha",
                  label ="Sensitivity",
                  min = 0.025,
                  max = 0.1,
                  step = 0.05,
                  value = 0.04)),
      
      div(style="display: inline-block;vertical-align:top; width: 300px;",
          
      dateRangeInput('dateRange',
                     label = 'Date Range',
                     start = Sys.Date() - 800, end = Sys.Date() - 750
      )),
      
      tabsetPanel(
       
        tabPanel("Anomaly Dates",
                 plotOutput("distPlot")
        ),
        
        tabPanel("Details",
               
                 htmlOutput("selectUI"),
                 #plot output from quantmod
                 
                 plotOutput("quantPlot")
                 
                 )
                 
    )
  )
))
