# Initialize
library(vetiver)
library(pins)
library(plumber)

# Pull model
model_board = board_folder("data/model")

v = vetiver_pin_read(
  board = model_board,
  name = "penguin_lm"
)

# Turn model into API
api = vetiver_api(pr = pr(), vetiver_model = v)

# Run API
pr_run(api, port = 8080, debug = TRUE)
