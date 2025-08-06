FROM python:3.10
RUN apt-get update && apt-get install -y netcat-traditional
# ADD THIS LINE HERE:
RUN apt-get update && apt-get install -y postgresql-client
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade flask -r requirements.txt
COPY . .
RUN chmod +x docker-entrypoint.sh
CMD ["/bin/bash", "docker-entrypoint.sh"]