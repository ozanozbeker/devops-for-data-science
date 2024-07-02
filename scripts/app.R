library(shiny)
library(log4r)
library(httr2)

api_url <- "http://127.0.0.1:8080/predict"
log = logger()

ui <- fluidPage(
  titlePanel("Penguin Mass Predictor"),

  # Model input values
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "bill_length",
        "Bill Length (mm)",
        min = 30,
        max = 60,
        value = 45,
        step = 0.1
      ),
      selectInput(
        "sex",
        "Sex",
        c("Male", "Female")
      ),
      selectInput(
        "species",
        "Species",
        c("Adelie", "Chinstrap", "Gentoo")
      ),
      # Get model predictions
      actionButton(
        "predict",
        "Predict"
      )
    ),

    mainPanel(
      h2("Penguin Parameters"),
      verbatimTextOutput("vals"),
      h2("Predicted Penguin Mass (g)"),
      textOutput("pred")
    )
  )
)

server <- function(input, output) {
  info(log, "App Started")

  # Input params
  vals <- reactive(
    list(
      bill_length_mm = input$bill_length,
      species_Chinstrap = input$species == "Chinstrap",
      species_Gentoo = input$species == "Gentoo",
      sex_male = input$sex == "Male"
    )
  )

  # Fetch prediction from API
  pred <- eventReactive(
    input$predict,
    {
      info(log, "Prediction Requested")

      r <- request(api_url) |> 
        req_body_json(vals()) |> 
        req_perform()

      info(log, "Prediction Returned")

      if(resp_is_error(r)) {
        error(log, paste("HTTP Error"))
      }

      resp_body_json(r)
    },
    ignoreInit = TRUE
  )

  # Render to UI
  output$pred <- renderText(pred()$predict[[1]])
  output$vals <- renderPrint(vals())
}

# Run the application
shinyApp(ui = ui, server = server)
