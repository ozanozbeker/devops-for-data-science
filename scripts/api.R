# Initialize
library(vetiver)
library(pins)
library(plumber)
library(log4r)

# Initialize log4r logger
log <- logger("INFO", appenders = file_appender("logs/api.log"))

# Pull model
model_board <- board_folder("data/model")

v <- vetiver_pin_read(
  board = model_board,
  name = "penguin_lm"
)

# Create a function to log requests and responses
log_request_response <- function(req, res) {
  info(log, paste("Request:", req$REQUEST_METHOD, req$PATH_INFO))
  info(log, paste("Response status:", res$status))
}

# Turn model into API with custom logging
api <- vetiver_api(pr = pr(), vetiver_model = v, debug = TRUE)

# Add logging middleware
api <- pr_hook(api, "preroute", function(req, res) {
  log_request_response(req, res)
})

# Add error handling
api <- pr_set_error(api, function(req, res, err) {
  error(log, paste("Error:", err$message))
  res$status <- 500
  res$body <- list(error = err$message)
  res
})

# Run API
pr_run(api, port = 8080, debug = TRUE)
