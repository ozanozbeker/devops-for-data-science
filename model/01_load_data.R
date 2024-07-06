library(palmerpenguins)
library(DBI)
library(duckdb)
library(pins)
library(paws)

con = dbConnect(duckdb(), dbdir = "penguins.duckdb")
dbWriteTable(con, "penguins", penguins)
dbDisconnect(con)

board = board_s3("do4ds")

board |>
  pin_upload(
    paths = "penguins.duckdb",
    name = "penguins_data",
    description = "A DuckDB database contain the `penguins` table from {palmerpenguins}.")
