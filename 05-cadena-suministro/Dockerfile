FROM alpine:latest

RUN apk add --no-cache curl python3

WORKDIR /app

# Inyección simulada e inocua durante la construcción (demostración didáctica)
RUN echo "echo '[PAYLOAD DEMO] Alerta: Dependencia no autorizada ejecutada en tiempo de ejecución (Runtime).'" > /app/malicious_dependency.sh && \
    chmod +x /app/malicious_dependency.sh

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]

