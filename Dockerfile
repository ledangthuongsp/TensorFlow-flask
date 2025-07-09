# Use a more lightweight base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install dependencies in a single step to reduce image layers
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files
COPY . .

# Clean up unnecessary files to reduce image size
RUN rm -rf /root/.cache

# Expose port and run app
EXPOSE 5000
CMD ["python", "app.py"]
