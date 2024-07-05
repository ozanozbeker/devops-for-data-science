fluidPage(
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