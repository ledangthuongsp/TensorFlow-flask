FROM python:3.11-slim

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files into container
COPY . .

# Install gunicorn
RUN pip install --no-cache-dir gunicorn

# Expose port
EXPOSE 5000

# Use gunicorn to serve the app
CMD ["gunicorn", "-b", "0.0.0.0:${PORT}", "app:app"]
