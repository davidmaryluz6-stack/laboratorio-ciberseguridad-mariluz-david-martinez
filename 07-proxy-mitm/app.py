"""Proxy Inverso Interceptor (Demostración Man-In-The-Middle Local).

Institución: IU Digital de Antioquia
Actividad: Unidad 2 — Laboratorio de Ciberseguridad
Estudiante: Mariluz David Martínez
Módulo: 07 — Proxy Interceptor / MITM
"""

import os
from flask import Flask, Response, request
import requests

app = Flask(__name__)

# Configuración del servidor DMZ objetivo (estrictamente red local interna)
TARGET_DMZ = os.environ.get("TARGET_DMZ", "http://servidor-dmz:8080")


def es_objetivo_local_seguro(url: str) -> bool:
    """Verifica que el target sea exclusivamente un servicio interno del laboratorio."""
    url_lower = url.lower()
    return any(
        url_lower.startswith(pref)
        for pref in ("http://servidor-dmz", "http://localhost", "http://127.0.0.1")
    )


@app.route("/", defaults={"path": ""}, methods=["GET", "POST"])
@app.route("/<path:path>", methods=["GET", "POST"])
def mitm_proxy(path):
    """Intercepta peticiones dirigidas a la DMZ e inyecta una alerta de demostración en tránsito."""
    print(f"\n[MITM INTERCEPTADO] Petición entrante hacia la ruta: /{path}")
    print(f"[CABECERAS INTERCEPTADAS] Método: {request.method} | User-Agent: {request.headers.get('User-Agent', '')}")

    if not es_objetivo_local_seguro(TARGET_DMZ):
        return (
            "<h3>[BLOQUEO DE SEGURIDAD] El proxy MITM solo puede comunicarse "
            "con el contenedor local del laboratorio.</h3>",
            403,
            {"Content-Type": "text/html; charset=utf-8"},
        )

    target_url = f"{TARGET_DMZ.rstrip('/')}/{path}"
    headers = {k: v for k, v in request.headers if k.lower() != "host"}

    try:
        resp = requests.request(
            method=request.method,
            url=target_url,
            headers=headers,
            params=request.args,
            data=request.get_data(),
            timeout=5,
            allow_redirects=False,
        )
        contenido_original = resp.text
        mimetype = resp.headers.get("Content-Type", "text/html; charset=utf-8")
    except Exception as e:
        contenido_original = f"<h3>[ERROR MITM] No fue posible conectar con la DMZ local: {e}</h3>"
        mimetype = "text/html; charset=utf-8"

    # Inyección demostrativa de código en la respuesta HTTP en tránsito
    alerta_mitm = (
        '\n\n<div style="background:#dc2626; color:#ffffff; padding:12px 16px; '
        'text-align:center; font-family:sans-serif; font-size:0.95rem; font-weight:bold; '
        'border-bottom:2px solid #991b1b;">'
        "⚠️ [ALERTA MITM - DEMOSTRACIÓN DIDÁCTICA] Este contenido fue interceptado y alterado "
        "en tránsito por el Proxy Interceptor del Módulo 07."
        "</div>"
        "\n<!-- [ALERTA MITM] Contenido alterado en tránsito por Proxy Interceptor - Laboratorio Mariluz David Martínez -->"
    )

    if "text/html" in mimetype and "<body>" in contenido_original:
        contenido_alterado = contenido_original.replace("<body>", f"<body>\n{alerta_mitm}", 1)
    else:
        contenido_alterado = contenido_original + alerta_mitm

    print("[MITM ALERTA] Respuesta modificada e inyectada con éxito.")
    return Response(contenido_alterado, status=200, mimetype=mimetype)


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)

