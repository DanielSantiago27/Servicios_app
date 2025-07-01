# Etapa 1: construir la app con Flutter 3.22 (Dart 3.8)
FROM ghcr.io/cirruslabs/flutter:3.22

WORKDIR /app

COPY . .

RUN flutter pub get

RUN flutter build web --release

# Etapa 2: servir con nginx
FROM nginx:alpine

COPY --from=0 /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
