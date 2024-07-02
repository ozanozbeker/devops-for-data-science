library(shiny)
library(log4r)
library(httr2)

api_url <- "http://127.0.0.1:8080/predict"
log <- logger()

ui <- fluidPage(
  titlePanel("Penguin Mass Predictor"),

  sidebarLayout(
    sidebarPanel(
      selectInput(
        "species",
        "Species",
        c("Adelie", "Chinstrap", "Gentoo")
      ),
      selectInput(
        "island",
        "Island",
        c("Torgersen", "Biscoe", "Dream")
      ),
      sliderInput(
        "bill_length",
        "Bill Length (mm)",
        min = 30,
        max = 60,
        value = 45,
        step = 0.1
      ),
      sliderInput(
        "bill_depth",
        "Bill Depth (mm)",
        min = 13,
        max = 21,
        value = 17,
        step = 0.1
      ),
      sliderInput(
        "flipper_length",
        "Flipper Length (mm)",
        min = 170,
        max = 230,
        value = 200,
        step = 1
      ),
      selectInput(
        "sex",
        "Sex",
        c("Male" = "male", "Female" = "female")
      ),
      numericInput(
        "year",
        "Year",
        value = 2007,
        min = 2007,
        max = 2009,
        step = 1
      ),
      actionButton(
        "predict",
        "Predict"
      )
    ),

    mainPanel(
      h2("Penguin Parameters"),
      verbatimTextOutput("vals"),
      h2("Predicted Penguin Mass (g)"),
      textOutput("pred"),
      h2("Log Output"),
      verbatimTextOutput("log_output")
    )
  )
)

server <- function(input, output, session) {
  log_messages <- reactiveVal("")

  append_log <- function(message) {
    isolate({
      old_logs <- log_messages()
      new_logs <- paste(old_logs, message, sep = "\n")
      log_messages(new_logs)
    })
  }

  info(log, "App Started")
  append_log("App Started")

  vals <- reactive({
    list(
      species = input$species,
      island = input$island,
      bill_length_mm = input$bill_length,
      bill_depth_mm = input$bill_depth,
      flipper_length_mm = as.integer(input$flipper_length),
      sex = input$sex,
      year = as.integer(input$year)
    )
  })

  pred <- eventReactive(input$predict, {
    info(log, "Prediction Requested")
    append_log("Prediction Requested")

    r <- request(api_url) |>
      req_body_json(list(vals())) |>
      req_perform()

    info(log, "Prediction Returned")
    append_log("Prediction Returned")

    if (resp_is_error(r)) {
      error(log, paste("HTTP Error"))
      append_log("HTTP Error")
      return(NULL)
    }

    response <- resp_body_json(r)
    info(log, paste("API Response:", jsonlite::toJSON(response, pretty = TRUE)))
    append_log(paste("API Response:", jsonlite::toJSON(response, pretty = TRUE)))

    if (!is.null(response[[1]]$.pred) && length(response[[1]]$.pred) > 0) {
      return(response[[1]]$.pred[[1]])
    } else {
      error(log, "Prediction value not found in response")
      append_log("Prediction value not found in response")
      return(NA)
    }
  }, ignoreInit = TRUE)

  output$pred <- renderText({
    pred_val <- pred()
    req(pred_val)
    if (!is.na(pred_val)) {
      paste("Predicted Penguin Mass (g):", pred_val)
    } else {
      "Prediction could not be retrieved."
    }
  })

  output$vals <- renderPrint({
    vals()
  })

  output$log_output <- renderText({
    log_messages()
  })

  # Update log output every second to keep it in sync
  autoInvalidate <- reactiveTimer(1000)
  observe({
    autoInvalidate()
    session$sendCustomMessage(type = 'log_output', message = log_messages())
  })
}

shinyApp(ui = ui, server = server)
