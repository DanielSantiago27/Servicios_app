# Etapa 1: Construir la app Flutter Web
FROM cirrusci/flutter:latest

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar todos los archivos del proyecto al contenedor
COPY . .

# 👇 Instalar dependencias del proyecto
RUN flutter pub get

# Construir la app para web (release)
RUN flutter build web --release

# Etapa 2: Servir la app con nginx
FROM nginx:alpine

# Copiar los archivos construidos a la carpeta donde nginx sirve contenido
COPY --from=0 /app/build/web /usr/share/nginx/html

# Exponer el puerto 80 para el servicio web
EXPOSE 80

# Comando para arrancar nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]
