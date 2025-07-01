# Imagen base con Flutter SDK
FROM cirrusci/flutter:latest

# Directorio de trabajo
WORKDIR /app

# Copiar todo el proyecto
COPY . .

# Construir la app Flutter web
RUN flutter build web

# Usar nginx para servir la carpeta build/web
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
