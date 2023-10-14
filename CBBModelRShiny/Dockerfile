# Use an official R Shiny image
FROM rocker/shiny:latest

# Set the working directory in Docker
WORKDIR /app

# Copy R Shiny apps into the container
COPY . .

# Install necessary R packages
# You can create a script or list them here directly
RUN Rscript -e "install.packages(c('list', 'of', 'packages'))"

# Expose port 3838 for Shiny
EXPOSE 3838

# Command to run the shiny app
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]

