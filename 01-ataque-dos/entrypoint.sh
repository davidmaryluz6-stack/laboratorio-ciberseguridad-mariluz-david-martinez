#!/bin/sh
set -e

# Configuración del objetivo perimetral (confinado a red local privada de Docker)
TARGET="${TARGET:-http://servidor-dmz:8080}"

echo "=================================================================="
echo " LABORATORIO DE CIBERSEGURIDAD — IU DIGITAL DE ANTIOQUIA"
echo " Estudiante: Mariluz David Martínez"
echo " Módulo 01: Simulación de Tráfico Masivo (DoS Controlado)"
echo "=================================================================="
echo "[INFO] Objetivo local asignado: $TARGET"

# Salvaguarda de seguridad: impedir tráfico contra internet o infraestructura de terceros
case "$TARGET" in
  http://servidor-dmz*|http://localhost*|http://127.0.0.1*)
    echo "[SEGURIDAD OK] El objetivo pertenece a la red privada y controlada del laboratorio."
    ;;
  *)
    echo "[BLOQUEO DE SEGURIDAD] Solo se permite la simulación sobre la red local interna del laboratorio."
    echo "[BLOQUEO DE SEGURIDAD] Abortando ráfaga para evitar afectación a redes externas."
    exec python3 -m http.server 8080
    ;;
esac

echo "[SIMULACIÓN] Iniciando ráfaga controlada de 30 solicitudes HTTP concurrentes..."
START_TIME=$(date +%s)
SUCCESS=0
FAILED=0

for i in $(seq 1 30); do
  (
    CODE=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET" || echo "ERR")
    if [ "$CODE" = "200" ]; then
      echo "  -> Petición #$i: HTTP $CODE [Recibida por DMZ]"
    else
      echo "  -> Petición #$i: Estado $CODE"
    fi
  ) &
done

wait
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "=================================================================="
echo " [RESULTADO] Ráfaga controlada finalizada en ${DURATION}s."
echo " [ANÁLISIS FORENSE] En un escenario DoS no controlado:"
echo "   1. El consumo de workers y descriptores de archivo satura el servicio."
echo "   2. Mecanismos de defensa: Rate Limiting en Nginx/WAF, CDN y fail2ban."
echo "=================================================================="

# Si se ejecuta en modo standalone para pruebas automatizadas, finalizar aquí
if [ "$STANDALONE" = "true" ]; then
  exit 0
fi

# Mantiene el servicio activo y expone panel informativo para Docker
cat <<EOF > /app/index.html
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Módulo 01 - Tráfico DoS Simulado</title></head>
<body style="font-family: sans-serif; background: #0f172a; color: #f8fafc; padding: 2rem;">
  <h2>Módulo 01: Simulación de Tráfico Masivo (DoS)</h2>
  <p>Estudiante: Mariluz David Martínez - IU Digital</p>
  <p>Estado: Simulación completada sobre red local privada.</p>
</body>
</html>
EOF

exec python3 -m http.server 8080
