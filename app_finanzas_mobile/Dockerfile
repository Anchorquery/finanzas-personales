FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .

ARG DIRECTUS_URL
ARG GEMINI_API_KEY
ARG FLUTTER_BASE_HREF=/

RUN flutter build web --release \
    --base-href "${FLUTTER_BASE_HREF}" \
    --dart-define=DIRECTUS_URL=${DIRECTUS_URL} \
    --dart-define=GEMINI_API_KEY=${GEMINI_API_KEY} \
    --no-tree-shake-icons \
    --no-source-maps

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY web/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD wget -qO- http://localhost/ || exit 1
