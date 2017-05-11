
library(shiny)
library(TSA)
library(zoo)
library(quantmod)
library(forecast)
library(lubridate)
library(ggplot2)
library(dplyr)

#Function to fit armima model, detect largest residuals, and create plot
detect_anom = function(cur_symb = "FB", 
                       alpha = 0.05, 
                       start.date = "01-01-2014",
                       end.date = "02-01-2014"){  
  
  cur_ts = getSymbols(cur_symb, from = start.date, to = end.date)
  cur_data = get(cur_symb)[, 6]
  dates = ymd(start.date) + days(1:length(cur_data))
  #A model is fit the the log of the adjusted closing price
  model = auto.arima(log(cur_data))
  estimate = fitted(model)
  #outliers are classified by those above the sensitivity level
  anom_index = which( residuals(model) > alpha) 
  anom_dates = ymd(start.date) + days(anom_index)
  
  mydata = data_frame(date = dates, value = as.vector(cur_data))
  points = data_frame(date = anom_dates, value = as.vector(cur_data)[anom_index])
  
  point.size = residuals(model)[anom_index]*100
  
  #plot object is created
  ggplot_1 = 
    ggplot(mydata, aes( date, value)) +
    geom_line(col = "chartreuse4") + 
    geom_point( data = points, aes( date, value), size = point.size , col = "red", alpha = 0.5) + 
    geom_text(data = points, aes( date, value), hjust = 0, vjust = 0, label = points$date) + 
    ggtitle(paste(cur_symb, "adjusted closing price")) +
    xlab("Date") + 
    ylab("Adjusted Close (USD)") + 
    theme_linedraw() + 
    theme(axis.text=element_text(size=12),
          axis.title=element_text(size=14,face="bold"))
  
  
   output = list(date = anom_dates, plot = ggplot_1, model = model)  
   
  return(output)
}

#Creates stock info for "details" page
stockinfo = function(ticker, date){
  start.date =  ymd(date) - months(1)
  end.date = ymd(date) + months(1)
  #a function to get some info on a stock at a given date
  stock_object = getSymbols(ticker, from = start.date, to = end.date)
  chartSeries(get(stock_object), 
              name = ticker, 
              theme = "white")
}

output_dates = NULL

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  #allows for fast updating based on input
  dataInput <- reactive({
    detect_anom(cur_symb = input$ticker,
                alpha = input$alpha,
                start.date = input$dateRange[1],
                end.date = input$dateRange[2])
  })
  
  output$distPlot <- renderPlot({
    #main plot with labeled anomalies
      dataInput()$plot
  })
  
  #reactive input selection 
  output$selectUI <- renderUI({
    selectInput("anomDates", "Select date", as.character(dataInput()$date))
  })
  
  output$quantPlot <- renderPlot({
    #stock information 
    stockinfo( ticker = input$ticker, date = input$anomDates)
  })
  
})
