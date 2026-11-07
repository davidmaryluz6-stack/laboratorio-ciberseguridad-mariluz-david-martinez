FROM alpine:latest

# Utilidades bind-tools (nslookup, dig) y python3 para el servidor de estado
RUN apk add --no-cache bind-tools curl python3

WORKDIR /app

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]

