con = DBI::dbConnect(duckdb::duckdb(), dbdir = "do4ds.duckdb")
DBI::dbWriteTable(con, "penguins", palmerpenguins::penguins)
DBI::dbDisconnect(con)
