#!/bin/sh
set -e

echo "=================================================================="
echo " LABORATORIO DE CIBERSEGURIDAD — IU DIGITAL DE ANTIOQUIA"
echo " Estudiante: Mariluz David Martínez"
echo " Módulo 05: Simulación de Ataque a la Cadena de Suministro (Supply Chain)"
echo "=================================================================="

echo "[INSPECCIÓN] Verificando integridad del artefacto y dependencias del contenedor..."

if [ -f "/app/malicious_dependency.sh" ]; then
  echo ""
  echo "⚠️  [ALERTA DE SEGURIDAD - AUDITORÍA DE BUILD]"
  echo "    Se detectó una dependencia/script no autorizado inyectado durante"
  echo "    la etapa de construcción (build phase) de la imagen Docker."
  echo ""
  echo "--- Inicio de traza simulada ---"
  sh /app/malicious_dependency.sh
  echo "--- Fin de traza simulada ---"
  echo ""
else
  echo "[OK] Artefacto verificado. No se detectaron dependencias anómalas."
fi

echo "=================================================================="
echo " [ANÁLISIS FORENSE] Seguridad en la Cadena de Suministro de Software:"
echo "   - Amenaza: Inyección de código malicioso en repositorios de paquetes o Dockerfiles."
echo "   - Mitigaciones:"
echo "       1. Firma y verificación de imágenes con Docker Content Trust (Notary / Cosign)."
echo "       2. Escaneo de vulnerabilidades en CI/CD (Trivy, Grype, Docker Scout)."
echo "       3. Fijación estricta de versiones y hashes en dependencias (Lockfiles)."
echo "       4. Principio de menor privilegio y uso de imágenes base mínimas/endurecidas."
echo "=================================================================="

# Si se ejecuta en modo standalone para pruebas automatizadas, finalizar aquí
if [ "$STANDALONE" = "true" ]; then
  exit 0
fi

cat <<EOF > /app/index.html
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Módulo 05 - Cadena de Suministro</title></head>
<body style="font-family: sans-serif; background: #0f172a; color: #f8fafc; padding: 2rem;">
  <h2>Módulo 05: Compromiso Simulado en Cadena de Suministro</h2>
  <p>Estudiante: Mariluz David Martínez - IU Digital</p>
  <p>Estado: Demostración pedagógica completada de forma inocua en el contenedor.</p>
</body>
</html>
EOF

exec python3 -m http.server 8080
