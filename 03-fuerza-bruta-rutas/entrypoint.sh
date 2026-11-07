#!/bin/sh
set -e

TARGET="${TARGET:-http://servidor-dmz:8080}"
RUTAS="/ /health /admin /config.php /login /secret /backup.zip /index.html"

echo "=================================================================="
echo " LABORATORIO DE CIBERSEGURIDAD — IU DIGITAL DE ANTIOQUIA"
echo " Estudiante: Mariluz David Martínez"
echo " Módulo 03: Enumeración de Rutas Web (Detección de Directorios)"
echo "=================================================================="
echo "[INFO] Objetivo local asignado: $TARGET"

# Salvaguarda de seguridad
case "$TARGET" in
  http://servidor-dmz*|http://localhost*|http://127.0.0.1*)
    echo "[SEGURIDAD OK] El objetivo pertenece a la red Docker privada del laboratorio."
    ;;
  *)
    echo "[BLOQUEO DE SEGURIDAD] Solo se permite enumeración sobre la red local privada."
    echo "[BLOQUEO DE SEGURIDAD] Prohibido enviar solicitudes a servidores externos."
    exec python3 -m http.server 8080
    ;;
esac

echo "[ENUMERACIÓN] Probando rutas conocidas sobre el servidor DMZ..."

for ruta in $RUTAS; do
  CODE=$(curl -o /dev/null -s -w "%{http_code}" "$TARGET$ruta" || echo "ERR")
  case "$CODE" in
    200) ESTADO="ENCONTRADO / DISPONIBLE (200)" ;;
    404) ESTADO="NO ENCONTRADO (404)" ;;
    403) ESTADO="PROHIBIDO / ACCESO DENEGADO (403)" ;;
    *)   ESTADO="RESPUESTA: $CODE" ;;
  esac
  echo "  -> Ruta probada: $ruta  =>  $ESTADO"
done

echo "=================================================================="
echo " [ANÁLISIS FORENSE] Detección de Reconocimiento Web:"
echo "   Una ráfaga de respuestas 404 consecutivas indica escaneo de directorios."
echo "   Defensas: Reglas en WAF (ModSecurity), monitoreo de logs con Fail2ban."
echo "=================================================================="

# Si se ejecuta en modo standalone para pruebas automatizadas, finalizar aquí
if [ "$STANDALONE" = "true" ]; then
  exit 0
fi

cat <<EOF > /app/index.html
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Módulo 03 - Enumeración de Rutas</title></head>
<body style="font-family: sans-serif; background: #0f172a; color: #f8fafc; padding: 2rem;">
  <h2>Módulo 03: Enumeración Controlada de Rutas</h2>
  <p>Estudiante: Mariluz David Martínez - IU Digital</p>
  <p>Estado: Enumeración completada sobre servidor local.</p>
</body>
</html>
EOF

exec python3 -m http.server 8080
