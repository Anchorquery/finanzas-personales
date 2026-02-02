FROM python:3.10-slim

WORKDIR /app

# Instalar dependencias del sistema + nginx para servir webapp
RUN apt-get update && apt-get install -y \
    build-essential \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements e instalar
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el resto del código
COPY . .

# Configurar nginx para servir webapp
RUN echo 'server { \
    listen 80; \
    location /webapp/ { \
    alias /app/webapp/; \
    index index.html; \
    } \
    }' > /etc/nginx/sites-enabled/default

# Evitar que Python bufferee los logs y configurar zona horaria si fuera necesario
ENV PYTHONUNBUFFERED=1

# Configurar supervisor para correr bot + nginx
RUN echo '[supervisord] \n\
nodaemon=true \n\
user=root \n\
\n\
[program:nginx] \n\
command=nginx -g "daemon off;" \n\
autostart=true \n\
autorestart=true \n\
stdout_logfile=/dev/stdout \n\
stdout_logfile_maxbytes=0 \n\
stderr_logfile=/dev/stderr \n\
stderr_logfile_maxbytes=0 \n\
\n\
[program:bot] \n\
command=python bot.py \n\
autostart=true \n\
autorestart=true \n\
directory=/app \n\
stdout_logfile=/dev/stdout \n\
stdout_logfile_maxbytes=0 \n\
stderr_logfile=/dev/stderr \n\
stderr_logfile_maxbytes=0 \n\
' > /etc/supervisor/conf.d/supervisord.conf

# Exponer puerto 80 para webapp
EXPOSE 80

# Iniciar con supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
