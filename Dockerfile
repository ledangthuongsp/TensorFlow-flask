# Bước 1: Build image
FROM python:3.11-slim as build

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Cài đặt dependencies trong bước này
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Bước 2: Final image (image chạy ứng dụng)
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy các dependencies đã cài đặt từ bước trước
COPY --from=build /root/.cache /root/.cache
COPY --from=build /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copy mã nguồn vào
COPY . .

# Expose port 5000
EXPOSE 5000

# Chạy Flask's built-in server
CMD ["python", "app.py"]
