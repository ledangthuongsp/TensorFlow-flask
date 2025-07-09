# Sử dụng image Python
FROM python:3.11-slim

# Cài đặt các phụ thuộc hệ thống
RUN apt-get update && apt-get install -y libglib2.0-0

# Tạo môi trường làm việc
WORKDIR /app

# Copy requirements và cài đặt
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copy mã nguồn vào
COPY . .

# Expose port 5000
EXPOSE 5000

# Sử dụng Gunicorn để chạy ứng dụng Flask
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
