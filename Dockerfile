# Sử dụng image Python slim để giảm kích thước
FROM python:3.11-slim as builder

# Cài đặt các dependencies cần thiết như gcc (nếu cần để build các package C++ như torch)
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Thiết lập thư mục làm việc
WORKDIR /app

# Copy requirements.txt vào container và cài đặt dependencies
COPY requirements.txt .

# Cài đặt dependencies Python (chỉ cài những gì cần thiết)
RUN pip install --no-cache-dir -r requirements.txt

# Tiến hành sao chép code vào final image
FROM python:3.11-slim

WORKDIR /app

# Copy các package đã cài đặt từ builder vào final image
COPY --from=builder /app /app

# Copy toàn bộ source code vào container
COPY . .

# Cài đặt gunicorn, nếu chưa cài từ requirements.txt
RUN pip install --no-cache-dir gunicorn

# Expose port
EXPOSE 5000

# Chạy ứng dụng bằng gunicorn (WSGI server)
CMD ["gunicorn", "-b", "0.0.0.0:${PORT}", "app:app"]
