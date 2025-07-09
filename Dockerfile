# Sử dụng base image Python slim để giảm kích thước image
FROM python:3.11-slim

# Thiết lập thư mục làm việc trong container
WORKDIR /app

# Cài đặt các dependencies hệ thống như gcc (để build các package C++ như torch)
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Cập nhật pip lên phiên bản mới nhất (tốt nhất khi cài đặt các thư viện)
RUN pip install --upgrade pip

# Copy requirements.txt vào container
COPY requirements.txt ./

# Cài đặt các thư viện từ requirements.txt (bao gồm torch)
RUN pip install --no-cache-dir -r requirements.txt

# Copy toàn bộ project vào container
COPY . .

# Dọn dẹp các gói không cần thiết để giảm kích thước image (optional)
RUN apt-get remove -y gcc && apt-get autoremove -y

# Expose port 5000
EXPOSE 5000

# Sử dụng gunicorn để chạy app Flask
CMD ["gunicorn", "-b", "0.0.0.0:${PORT}", "app:app"]
