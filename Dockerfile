# Start from an official R image and python image
FROM rocker/shiny:latest
FROM python:3.8

# Set the working directory in Docker
WORKDIR /Machine_Learning_sport_Model

# Copy the dependencies file to the working directory
COPY CBBModelPyDjango/CBBModel/requirements.txt .

# Install Django dependencies
RUN pip install -r requirements.txt

# Copy R Shiny files and Django files to the working directory
COPY CBBModelRShiny/ .
COPY CBBModelPyDjango/CBBModel/ .

# Install R Shiny dependencies
# You might need a file like `install.R` in `CBBModelRShiny/` which lists the required R packages
# and their installation commands, or you can specify them here directly.
COPY CBBModelRShiny/install.R .
RUN Rscript install.R

# Start both the R Shiny and Django app
# You can use a script that starts both, or pick one as your main service and start the other manually
# Here's an example where we primarily start Django:
CMD ["python", "CBBModelPyDjango/CBBModel/manage.py", "runserver"]
