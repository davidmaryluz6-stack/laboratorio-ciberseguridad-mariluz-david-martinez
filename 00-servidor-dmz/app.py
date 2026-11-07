"""Servidor DMZ - Laboratorio de Ciberseguridad.

Institución: IU Digital de Antioquia
Actividad: Unidad 2 — Demostración en vivo y evaluación de laboratorio en la nube.
Estudiante: Mariluz David Martínez
Módulo: 00 — Servidor Perimetral DMZ
"""

from datetime import datetime, timezone
import logging
import os
import sys
from flask import Flask, jsonify, make_response, render_template_string, request

# Configuración de logger estructurado para auditoría hacia stdout
audit_logger = logging.getLogger("dmz.audit")
audit_logger.setLevel(logging.INFO)

if not audit_logger.handlers:
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.INFO)
    formatter = logging.Formatter("%(message)s")
    handler.setFormatter(formatter)
    audit_logger.addHandler(handler)

# Evitar propagación a root para no duplicar mensajes de gunicorn/werkzeug
audit_logger.propagate = False

app = Flask(__name__)

HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Servidor DMZ Activo - Laboratorio de Mariluz David Martínez</title>
    <style>
        :root {
            --bg-color: #0a1128;
            --bg-gradient: linear-gradient(135deg, #070d1e 0%, #0a1128 50%, #101c3d 100%);
            --card-bg: rgba(16, 26, 54, 0.92);
            --card-border: #1e3a6d;
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --accent-green: #10b981;
            --accent-green-glow: rgba(16, 185, 129, 0.35);
            --accent-blue: #38bdf8;
            --btn-bg: #2563eb;
            --btn-hover: #1d4ed8;
            --detail-bg: #0c152e;
            --detail-border: #1d2e56;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: var(--bg-gradient);
            background-attachment: fixed;
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px 16px;
        }

        .container {
            width: 100%;
            max-width: 640px;
        }

        .card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 18px;
            padding: 36px 32px;
            box-shadow: 0 20px 45px rgba(0, 0, 0, 0.55), 0 0 25px rgba(37, 99, 235, 0.15);
            backdrop-filter: blur(10px);
        }

        .header {
            text-align: center;
            margin-bottom: 28px;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: rgba(16, 185, 129, 0.12);
            border: 1px solid rgba(16, 185, 129, 0.4);
            color: #34d399;
            padding: 8px 18px;
            border-radius: 9999px;
            font-size: 0.88rem;
            font-weight: 600;
            letter-spacing: 0.3px;
            margin-bottom: 20px;
        }

        .pulse-indicator {
            width: 11px;
            height: 11px;
            background-color: var(--accent-green);
            border-radius: 50%;
            box-shadow: 0 0 0 0 var(--accent-green-glow);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% {
                transform: scale(0.95);
                box-shadow: 0 0 0 0 var(--accent-green-glow);
            }
            70% {
                transform: scale(1);
                box-shadow: 0 0 0 10px rgba(16, 185, 129, 0);
            }
            100% {
                transform: scale(0.95);
                box-shadow: 0 0 0 0 rgba(16, 185, 129, 0);
            }
        }

        h1 {
            font-size: 1.55rem;
            font-weight: 700;
            line-height: 1.35;
            color: var(--text-main);
            margin-bottom: 8px;
        }

        .subtitle {
            color: var(--accent-blue);
            font-size: 0.98rem;
            font-weight: 500;
        }

        .info-grid {
            display: grid;
            gap: 14px;
            margin: 26px 0;
        }

        .info-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--detail-bg);
            border: 1px solid var(--detail-border);
            border-radius: 10px;
            padding: 13px 18px;
            font-size: 0.92rem;
        }

        .info-label {
            color: var(--text-muted);
            font-weight: 500;
        }

        .info-value {
            color: var(--text-main);
            font-weight: 600;
            text-align: right;
        }

        .actions {
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-top: 28px;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            background: var(--btn-bg);
            color: #ffffff;
            text-decoration: none;
            padding: 14px 22px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.35);
            text-align: center;
        }

        .btn:hover {
            background: var(--btn-hover);
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(37, 99, 235, 0.45);
        }

        .footer {
            margin-top: 24px;
            text-align: center;
            font-size: 0.8rem;
            color: var(--text-muted);
        }

        @media (max-width: 600px) {
            .card {
                padding: 26px 20px;
            }
            h1 {
                font-size: 1.35rem;
            }
            .info-item {
                flex-direction: column;
                align-items: flex-start;
                gap: 4px;
            }
            .info-value {
                text-align: left;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <main class="card">
            <header class="header">
                <div class="status-badge" role="status">
                    <span class="pulse-indicator" aria-hidden="true"></span>
                    <span>Zona Desmilitarizada (DMZ) Operativa</span>
                </div>
                <h1>Servidor DMZ Activo - Laboratorio de Mariluz David Martínez</h1>
                <p class="subtitle">Módulo 00 — Servidor Perimetral DMZ</p>
            </header>

            <section class="info-grid">
                <div class="info-item">
                    <span class="info-label">Estudiante</span>
                    <span class="info-value">Mariluz David Martínez</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Institución</span>
                    <span class="info-value">IU Digital de Antioquia</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Entorno de Ejecución</span>
                    <span class="info-value">Python / Gunicorn / Docker</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Endpoint de monitoreo</span>
                    <span class="info-value">GET /health</span>
                </div>
            </section>

            <footer class="actions">
                <a href="/health" class="btn" title="Consultar estado de salud en formato JSON">
                    Consultar estado JSON (/health)
                </a>
            </footer>

            <div class="footer">
                Laboratorio de Ciberseguridad &bull; Unidad 2 &bull; Demostración en vivo
            </div>
        </main>
    </div>
</body>
</html>
"""


@app.after_request
def audit_request_logger(response):
    """Registra en stdout cada solicitud entrante en formato estructurado de auditoría.

    Por seguridad perimetral, únicamente se registra el path limpio (request.path),
    omitiendo cadenas de consulta, credenciales, tokens y cookies para prevenir fugas.
    """
    now_utc = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    # request.path solo contiene la ruta URL, omitiendo query strings sensibles
    audit_msg = (
        f"AUDIT_LOG | timestamp_utc={now_utc} | "
        f"method={request.method} | path={request.path} | "
        f"status_code={response.status_code}"
    )
    audit_logger.info(audit_msg)
    return response


@app.route("/", methods=["GET"])
def index():
    """Ruta raíz que presenta la interfaz web perimetral del servidor DMZ."""
    response = make_response(render_template_string(HTML_TEMPLATE))
    response.headers["Content-Type"] = "text/html; charset=utf-8"
    return response, 200


@app.route("/health", methods=["GET"])
def health():
    """Endpoint de monitoreo perimetral que devuelve el estado del servidor DMZ en JSON."""
    now_utc = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    data = {
        "module": "00-servidor-dmz",
        "service": "servidor-dmz",
        "status": "ok",
        "student": "Mariluz David Martínez",
        "timestamp_utc": now_utc,
        "version": "1.0.0",
    }
    return jsonify(data), 200


if __name__ == "__main__":
    server_port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=server_port)

