FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Cài torch bản CPU riêng (giảm size hơn pip default)
RUN pip install --no-cache-dir torch==2.3.0+cpu -f https://download.pytorch.org/whl/torch_stable.html

# Cài các package còn lại
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Clean up (optional)
RUN apt-get remove -y gcc && apt-get autoremove -y

CMD ["python", "app.py"]
