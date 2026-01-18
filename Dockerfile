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

# Configurar supervisor para correr bot + nginx
RUN echo '[supervisord] \n\
    nodaemon=true \n\
    \n\
    [program:nginx] \n\
    command=nginx -g "daemon off;" \n\
    autostart=true \n\
    autorestart=true \n\
    \n\
    [program:bot] \n\
    command=python bot.py \n\
    autostart=true \n\
    autorestart=true \n\
    directory=/app \n\
    ' > /etc/supervisor/conf.d/supervisord.conf

# Exponer puerto 80 para webapp
EXPOSE 80

# Iniciar con supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
