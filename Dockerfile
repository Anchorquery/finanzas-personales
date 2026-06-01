FROM nginx:alpine
COPY . /usr/share/nginx/html
RUN mv /usr/share/nginx/html/nginx.conf /etc/nginx/conf.d/default.conf && \
    rm -f /usr/share/nginx/html/Dockerfile
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s CMD wget -qO- http://localhost/healthz || exit 1
