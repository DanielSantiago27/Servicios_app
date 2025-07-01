FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY pagos_app_flutter/build/web /usr/share/nginx/html

EXPOSE 80
