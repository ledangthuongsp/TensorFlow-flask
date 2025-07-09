FROM python:3.11-slim

# Cài đặt thư viện hệ thống
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Cập nhật pip
RUN pip install --upgrade pip

# Set working directory
WORKDIR /app

# Copy requirements file vào container
COPY requirements.txt .

# Cài đặt dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy app files vào container
COPY . .

# Cài gunicorn
RUN pip install --no-cache-dir gunicorn

# Expose port
EXPOSE 5000

# Use gunicorn to serve the app
CMD ["gunicorn", "-b", "0.0.0.0:${PORT}", "app:app"]
