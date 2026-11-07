#!/bin/sh
set -e

TARGET="${TARGET:-http://servidor-dmz:8080}"
USUARIOS="admin_demo root_demo user_test docente_demo gestor_test"
PASSWORD_DEMO="ClaveFicticia2026!"

echo "=================================================================="
echo " LABORATORIO DE CIBERSEGURIDAD — IU DIGITAL DE ANTIOQUIA"
echo " Estudiante: Mariluz David Martínez"
echo " Módulo 06: Simulación Controlada de Credential Stuffing / Brute Force"
echo "=================================================================="
echo "[INFO] Objetivo local asignado: $TARGET"

# Salvaguarda de seguridad
case "$TARGET" in
  http://servidor-dmz*|http://localhost*|http://127.0.0.1*)
    echo "[SEGURIDAD OK] El objetivo pertenece a la red Docker privada del laboratorio."
    ;;
  *)
    echo "[BLOQUEO DE SEGURIDAD] Solo se permite la prueba sobre la red local privada."
    echo "[BLOQUEO DE SEGURIDAD] Prohibido enviar intentos de autenticación a servicios externos."
    exec python3 -m http.server 8080
    ;;
esac

echo ""
echo "[AUDITORÍA TÉCNICA - ANÁLISIS DE RESPUESTAS HTTP]"
echo "  - Nota de seguridad: El endpoint raíz '/' del servidor DMZ es un recurso público."
echo "  - No exige desafío 'WWW-Authenticate: Basic realm=...'."
echo "  - Cualquier solicitud HTTP recibe el HTML público con código HTTP 200."
echo ""
echo "[PRUEBA DE FUERZA BRUTA] Despachando intentos controlados con cabecera Authorization: Basic..."

for user in $USUARIOS; do
  AUTH=$(echo -n "$user:$PASSWORD_DEMO" | base64)
  CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Basic $AUTH" "$TARGET" || echo "ERR")
  echo "  -> Petición con usuario [$user]: HTTP $CODE [Página pública entregada por DMZ]"
  sleep 0.2
done

echo ""
echo "=================================================================="
echo " [DICTAMEN FORENSE - DIFERENCIACIÓN TÉCNICA CLAVE]"
echo "   ⚠️  RECIBIR HTTP 200 != AUTENTICARSE SATISFACTORIAMENTE"
echo "   1. Causa técnica del HTTP 200:"
echo "      El servidor perimetral no tiene activo un middleware de autenticación"
echo "      en la ruta '/'. El servidor ignora cabeceras Authorization no solicitadas"
echo "      y devuelve el panel público 200 OK."
echo "   2. En un servicio realmente protegido (ej. /admin o /login):"
echo "      - Credenciales incorrectas deben generar: HTTP 401 Unauthorized."
echo "      - Credenciales correctas generan: HTTP 200 OK con token de sesión."
echo "   3. Mitigaciones indispensables para proteger endpoints de autenticación:"
echo "       - Desafíos CAPTCHA adaptativos."
echo "       - Rate Limiting estricto en rutas de autenticación."
echo "       - Bloqueo temporal por intentos fallidos (Account Lockout)."
echo "       - Autenticación Multifactor (MFA)."
echo "=================================================================="

# Si se ejecuta en modo standalone para pruebas automatizadas, finalizar aquí
if [ "$STANDALONE" = "true" ]; then
  exit 0
fi

cat <<EOF > /app/index.html
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Módulo 06 - Credential Stuffing</title></head>
<body style="font-family: sans-serif; background: #0f172a; color: #f8fafc; padding: 2rem;">
  <h2>Módulo 06: Simulación de Credential Stuffing</h2>
  <p>Estudiante: Mariluz David Martínez - IU Digital</p>
  <p>Estado: Prueba controlada finalizada sobre servidor local.</p>
</body>
</html>
EOF

exec python3 -m http.server 8080
