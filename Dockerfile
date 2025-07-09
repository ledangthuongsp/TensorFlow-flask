# Use a minimal Python base image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Install necessary system dependencies (like gcc for building torch)
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Copy the requirements.txt into the container and install dependencies
COPY requirements.txt ./

# Install torch (CPU version)
RUN pip install --no-cache-dir torch==2.3.0+cpu -f https://download.pytorch.org/whl/torch_stable.html

# Install other required packages from the requirements.txt file
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project into the container
COPY . .

# Clean up unnecessary packages to reduce image size (optional)
RUN apt-get remove -y gcc && apt-get autoremove -y

# Expose the port that the application will run on
EXPOSE 10000

# Use gunicorn to serve the app
CMD ["gunicorn", "-b", "0.0.0.0:${PORT}", "app:app"]
