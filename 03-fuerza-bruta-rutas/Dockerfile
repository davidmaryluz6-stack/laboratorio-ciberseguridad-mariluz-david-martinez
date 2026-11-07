FROM alpine:latest

# Herramientas mínimas para la enumeración HTTP
RUN apk add --no-cache curl bind-tools python3

WORKDIR /app

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]

