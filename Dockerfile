FROM python:3.10
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade flask -r requirements.txt
COPY . .
RUN chmod +x docker-entrypoint.sh
CMD ["/bin/bash", "docker-entrypoint.sh"]