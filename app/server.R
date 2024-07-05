library(log4r)
library(httr2)
library(jsonlite)

api_url <- "http://model-api:8080/predict"
logger <- logger(appenders = file_appender("logs/app.log"))

function(input, output) {
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
      info(logger, paste("Sending Request to:", api_url))

      r <- request(api_url) %>%
        req_body_json(payload) %>%
        req_perform()

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