# Stage 1: Build stage
FROM python:3.11-slim as build

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies (like gcc) for building some packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip to the latest version
RUN pip install --upgrade pip

# Copy only requirements.txt first to leverage Docker cache
COPY requirements.txt .

# Install the dependencies (including torch and transformers)
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Final image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Install only runtime dependencies (no gcc here)
RUN apt-get update && \
    apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Copy the installed packages from the build stage to the final stage
COPY --from=build /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copy the entire project (excluding unnecessary files)
COPY . .

# Expose the port that the app will run on
EXPOSE 5000

# Run the Flask app with Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:${PORT}", "-w", "4", "app:app"]
