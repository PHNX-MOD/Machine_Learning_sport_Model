# Use an official Python runtime as the parent image
FROM python:3.8

# Set the working directory in Docker
WORKDIR /app

# Copy the requirements.txt alone into the container at /app
COPY requirements.txt requirements.txt

# Install Django dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the current directory contents into the container at /app
COPY . .

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Define the command to run on container start
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

