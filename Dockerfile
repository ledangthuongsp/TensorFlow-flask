# Use a more lightweight base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements file and install dependencies in a single step
COPY requirements.txt .

# Install dependencies in a single step to reduce image layers
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    # Clean up unnecessary cache files to reduce image size
    rm -rf /root/.cache

# Copy the rest of the application files (excluding unnecessary files)
COPY . .

# Remove any unnecessary files, e.g., .git, node_modules, etc.
RUN rm -rf /app/.git /app/node_modules

# Expose the port Flask will run on
EXPOSE 5000

# Run the app using Gunicorn instead of Flask's built-in server
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
