"""Pruebas automáticas para el módulo 00 — Servidor DMZ.

Estudiante: Mariluz David Martínez
Institución: IU Digital de Antioquia
"""

import io
import logging
import os
import sys
import unittest
from datetime import datetime

# Asegurar que el directorio de la aplicación esté en sys.path
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
APP_DIR = os.path.abspath(os.path.join(CURRENT_DIR, ".."))
if APP_DIR not in sys.path:
    sys.path.insert(0, APP_DIR)

from app import app, audit_logger  # noqa: E402


class ServidorDMZTestCase(unittest.TestCase):
    """Batería de pruebas unitarias y de integración para el Servidor DMZ."""

    def setUp(self):
        """Configuración previa a cada prueba."""
        self.client = app.test_client()
        self.app_context = app.app_context()
        self.app_context.push()

        # Configurar captura de logs de auditoría para pruebas
        self.log_stream = io.StringIO()
        self.test_handler = logging.StreamHandler(self.log_stream)
        self.test_handler.setLevel(logging.INFO)
        formatter = logging.Formatter("%(message)s")
        self.test_handler.setFormatter(formatter)
        audit_logger.addHandler(self.test_handler)

    def tearDown(self):
        """Limpieza posterior a cada prueba."""
        audit_logger.removeHandler(self.test_handler)
        self.test_handler.close()
        self.app_context.pop()

    def test_import_without_starting_server(self):
        """Verifica que la aplicación puede importarse sin iniciar el servidor de desarrollo."""
        import app as dmz_module
        self.assertIsNotNone(dmz_module.app)
        self.assertEqual(dmz_module.app.name, "app")

    def test_index_status_code(self):
        """Verifica que GET / devuelve estado HTTP 200."""
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertIn("text/html", response.headers.get("Content-Type", ""))

    def test_index_content_and_student_name(self):
        """Verifica que la página principal contiene los textos y datos requeridos."""
        response = self.client.get("/")
        html = response.get_data(as_text=True)

        # Título exacto y nombre de la estudiante
        self.assertIn("Servidor DMZ Activo - Laboratorio de Mariluz David Martínez", html)
        self.assertIn("Mariluz David Martínez", html)

        # Elementos requeridos de la DMZ
        self.assertIn("Zona Desmilitarizada (DMZ) Operativa", html)
        self.assertIn("Módulo 00 — Servidor Perimetral DMZ", html)
        self.assertIn("IU Digital de Antioquia", html)
        self.assertIn("Python / Gunicorn / Docker", html)
        self.assertIn("GET /health", html)
        self.assertIn("/health", html)

    def test_health_status_code(self):
        """Verifica que GET /health devuelve estado HTTP 200."""
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.is_json)

    def test_health_json_payload(self):
        """Verifica los campos exactos del JSON devuelto por /health."""
        response = self.client.get("/health")
        payload = response.get_json()

        self.assertEqual(payload.get("status"), "ok")
        self.assertEqual(payload.get("module"), "00-servidor-dmz")
        self.assertEqual(payload.get("service"), "servidor-dmz")
        self.assertEqual(payload.get("student"), "Mariluz David Martínez")
        self.assertEqual(payload.get("version"), "1.0.0")

        # Validar formato ISO 8601 del timestamp UTC
        timestamp_str = payload.get("timestamp_utc")
        self.assertIsNotNone(timestamp_str)
        # Parsear ISO 8601 (terminación Z)
        parsed_dt = datetime.fromisoformat(timestamp_str.replace("Z", "+00:00"))
        self.assertIsNotNone(parsed_dt)

    def test_audit_log_format_and_security(self):
        """Verifica el formato del registro de auditoría y la ausencia de datos sensibles."""
        # Enviar petición con parámetros sensibles y cabecera de autorización
        self.client.get(
            "/health?token=secreto123&password=superpassword",
            headers={"Authorization": "Bearer supersecrettoken"}
        )

        logs = self.log_stream.getvalue().strip()
        lines = logs.splitlines()
        self.assertTrue(len(lines) > 0)

        last_log = lines[-1]
        # Formato de referencia: AUDIT_LOG | timestamp_utc=... | method=GET | path=/health | status_code=200
        self.assertIn("AUDIT_LOG", last_log)
        self.assertIn("method=GET", last_log)
        self.assertIn("path=/health", last_log)
        self.assertIn("status_code=200", last_log)

        # Garantizar que no se filtren contraseñas, tokens ni query string
        self.assertNotIn("secreto123", last_log)
        self.assertNotIn("superpassword", last_log)
        self.assertNotIn("supersecrettoken", last_log)
        self.assertNotIn("Authorization", last_log)


if __name__ == "__main__":
    unittest.main(verbosity=2)

