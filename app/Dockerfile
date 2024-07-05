# Use the Rocker Shiny image as the base image
FROM rocker/r-ver:4.4.1

# Set the environment variable for renv configuration
ENV RENV_CONFIG_REPOS_OVERRIDE https://packagemanager.rstudio.com/cran/latest

# Copy the renv.lock file and .Rprofile to the Docker image
COPY renv.lock renv.lock

# Install renv and restore the environment
RUN Rscript -e "install.packages('renv')"
RUN Rscript -e "renv::restore()"

# Copy the Shiny app to the Docker image
COPY server.R /app/server.R
COPY ui.R /app/ui.R

# Expose the Shiny app port
EXPOSE 3838

# Run the Shiny app
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]
