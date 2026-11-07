FROM python:3.11-slim

# Evitar generación de archivos .pyc y forzar salida inmediata por stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app

# Instalar dependencias del proyecto
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código de la aplicación
COPY app.py /app/app.py

# Crear y asignar usuario no privilegiado para mitigar riesgos en DMZ
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 8080

# Inicio dinámico con Gunicorn leyendo PORT en tiempo de ejecución
CMD ["sh", "-c", "exec gunicorn --bind 0.0.0.0:${PORT:-8080} --workers 2 --threads 2 --access-logfile - --error-logfile - app:app"]

