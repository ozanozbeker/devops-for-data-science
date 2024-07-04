library(DBI)
library(duckdb)
library(palmerpenguins)

con = dbConnect(duckdb(), dbdir = "../do4ds.duckdb")
dbWriteTable(con, "penguins", penguins)
dbDisconnect(con)
