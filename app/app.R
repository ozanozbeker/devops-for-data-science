library(shiny)
library(log4r)
library(httr2)
library(jsonlite)

api_url <- "http://127.0.0.1:8080/predict"
logger <- logger(appenders = file_appender("logs/app.log"))

ui <- fluidPage(
  titlePanel("Penguin Mass Predictor"),

  sidebarLayout(
    sidebarPanel(
      selectInput("species", "Species", c("Adelie", "Chinstrap", "Gentoo")),
      selectInput("island", "Island", c("Torgersen", "Biscoe", "Dream")),
      sliderInput("bill_length", "Bill Length (mm)", min = 30, max = 60, value = 45, step = 0.1),
      sliderInput("bill_depth", "Bill Depth (mm)", min = 13, max = 21, value = 17, step = 0.1),
      sliderInput("flipper_length", "Flipper Length (mm)", min = 170, max = 230, value = 200, step = 1),
      selectInput("sex", "Sex", c("Male" = "male", "Female" = "female")),
      numericInput("year", "Year", value = 2007, min = 2007, max = 2009, step = 1),
      actionButton("predict", "Predict")
    ),

    mainPanel(
      h2("Penguin Parameters"),
      verbatimTextOutput("vals"),
      h2("Predicted Penguin Mass (g)"),
      textOutput("pred"),
      verbatimTextOutput("error_message")
    )
  )
)

server <- function(input, output, session) {
  info(logger, "App Started")

  vals <- reactive({
    data.frame(
      species = input$species,
      island = input$island,
      bill_length_mm = input$bill_length,
      bill_depth_mm = input$bill_depth,
      flipper_length_mm = as.integer(input$flipper_length),
      sex = input$sex,
      year = as.integer(input$year),
      stringsAsFactors = FALSE
    )
  })

  pred <- eventReactive(input$predict, {
    info(logger, "Prediction Requested")

    payload <- vals()
    info(logger, paste("Request Payload:", toJSON(payload, pretty = TRUE)))

    tryCatch({
      r <- request(api_url) %>%
        req_body_json(payload) %>%
        req_perform()

      info(logger, "Prediction Returned")

      if (resp_is_error(r)) {
        error(logger, "HTTP Error")
        return(list(prediction = NA, error = "HTTP Error: Internal Server Error"))
      }

      response <- resp_body_json(r)
      info(logger, paste("API Response:", toJSON(response, pretty = TRUE)))

      if (!is.null(response[[1]]$.pred)) {
        return(list(prediction = response[[1]]$.pred[[1]], error = NULL))
      } else {
        error(logger, "Prediction value not found in response")
        return(list(prediction = NA, error = "Prediction value not found in response"))
      }
    }, error = function(e) {
      error(logger, paste("Error: ", e$message))
      return(list(prediction = NA, error = e$message))
    })
  }, ignoreInit = TRUE)

  output$pred <- renderText({
    result <- pred()
    if (is.null(result$error)) {
      return(result$prediction)
    } else {
      return("No prediction available")
    }
  })

  output$error_message <- renderText({
    result <- pred()
    if (!is.null(result$error)) {
      return(result$error)
    }
  })

  output$vals <- renderPrint({
    vals()
  })
}
