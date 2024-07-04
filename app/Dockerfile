# Use the Rocker Shiny image as the base image
FROM rocker/shiny:4.4.1

# Set the environment variable for renv configuration
ENV RENV_CONFIG_REPOS_OVERRIDE https://packagemanager.rstudio.com/cran/latest

# Copy the renv.lock file and .Rprofile to the Docker image
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile

# Install renv and restore the environment
RUN Rscript -e "install.packages('renv')"
RUN Rscript -e "renv::restore()"

# Copy the Shiny app to the Docker image
COPY app.R /srv/shiny-server/

# Expose the Shiny app port
EXPOSE 3838

# Run the Shiny app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server', host = '0.0.0.0', port = 3838)"]
