# Use an official lightweight Python image.
FROM python:3.12-slim

# Install Nginx and Supervisor
RUN apt-get update && apt-get install -y nginx supervisor netcat-traditional && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# Copy Python dependencies and install them
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code and configs
COPY src/ /app/src
COPY stress/ /app/stress
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose the public port
EXPOSE 8080

# Start Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
