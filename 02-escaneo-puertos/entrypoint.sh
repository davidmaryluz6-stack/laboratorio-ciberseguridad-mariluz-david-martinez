#!/bin/sh
set -e

HOST="${HOST:-servidor-dmz}"

echo "=================================================================="
echo " LABORATORIO DE CIBERSEGURIDAD — IU DIGITAL DE ANTIOQUIA"
echo " Estudiante: Mariluz David Martínez"
echo " Módulo 02: Reconocimiento y Escaneo de Puertos en DMZ"
echo "=================================================================="
echo "[INFO] Host objetivo local asignado: $HOST"

# Salvaguarda de seguridad: únicamente permitir escaneo en red privada de contenedores
case "$HOST" in
  servidor-dmz*|localhost*|127.0.0.1*|172.*)
    echo "[SEGURIDAD OK] El host pertenece a la red Docker aislada del laboratorio."
    ;;
  *)
    echo "[BLOQUEO DE SEGURIDAD] Solo se permite el escaneo sobre la red local privada."
    echo "[BLOQUEO DE SEGURIDAD] Prohibido escanear infraestructura externa."
    exec python3 -m http.server 8080
    ;;
esac

echo "[RECONOCIMIENTO] Analizando puertos estándar en el contenedor objetivo ($HOST)..."
PUERTOS="21 22 80 443 8080 3306"

for port in $PUERTOS; do
  case "$port" in
    21) SERVICIO="FTP" ;;
    22) SERVICIO="SSH" ;;
    80) SERVICIO="HTTP" ;;
    443) SERVICIO="HTTPS" ;;
    8080) SERVICIO="DMZ-WEB" ;;
    3306) SERVICIO="MySQL" ;;
    *) SERVICIO="UNKNOWN" ;;
  esac

  echo -n "  -> Probando puerto $port ($SERVICIO)... "
  if nc -z -w 2 "$HOST" "$port" 2>/dev/null; then
    echo "[ABIERTO / OPEN]"
  else
    echo "[CERRADO / FILTERED]"
  fi
done

echo "=================================================================="
echo " [ANÁLISIS FORENSE] Reducción de Superficie de Ataque:"
echo "   Solo el puerto 8080 (servicio DMZ) debe estar expuesto."
echo "   Servicios administrativos o bases de datos no deben ser accesibles en la DMZ."
echo "=================================================================="

# Si se ejecuta en modo standalone para pruebas automatizadas, finalizar aquí
if [ "$STANDALONE" = "true" ]; then
  exit 0
fi

cat <<EOF > /app/index.html
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Módulo 02 - Escaneo de Puertos</title></head>
<body style="font-family: sans-serif; background: #0f172a; color: #f8fafc; padding: 2rem;">
  <h2>Módulo 02: Escaneo de Puertos Local</h2>
  <p>Estudiante: Mariluz David Martínez - IU Digital</p>
  <p>Estado: Escaneo finalizado sobre red Docker privada.</p>
</body>
</html>
EOF

exec python3 -m http.server 8080
