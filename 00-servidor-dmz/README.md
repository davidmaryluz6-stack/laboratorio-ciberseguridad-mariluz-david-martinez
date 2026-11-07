# Módulo 00 — Servidor Perimetral DMZ

**Institución:** IU Digital de Antioquia  
**Programa / Curso:** Laboratorio de Ciberseguridad  
**Actividad:** Unidad 2 — Demostración en vivo y evaluación de laboratorio en la nube  
**Estudiante:** Mariluz David Martínez  
**Estado:** Operativo y Validado  

---

## 1. Descripción y Propósito

El módulo **00-servidor-dmz** representa el nodo de entrada perimetral o Zona Desmilitarizada (DMZ) dentro de la arquitectura del laboratorio. Su función es servir como interfaz pública expuesta de forma controlada a redes externas (Internet), aislando los recursos internos más críticos y centralizando los registros de auditoría de tráfico entrante.

El servicio está construido con **Python 3.11**, el microframework **Flask**, el servidor de aplicaciones WSGI **Gunicorn** para producción y empaquetado en contenedores ligeros con **Docker**.

---

## 2. Características Principales

- **Interfaz Perimetral Visual:** Presenta un panel web limpio, profesional y responsivo con estética de ciberseguridad (paleta azul oscuro, tarjeta de control centrada e indicador visual de operatividad en tiempo real).
- **Endpoint de Monitoreo (`/health`):** Entrega el diagnóstico operativo del servidor en formato JSON con información del módulo, servicio, estado, estudiante y marca de tiempo UTC en estándar ISO 8601.
- **Auditoría Estructurada de Solicitudes:** Implementa un middleware de registro que emite eventos estandarizados por `stdout`/`stderr` siguiendo el formato:
  ```text
  AUDIT_LOG | timestamp_utc=<ISO_8601> | method=<METODO> | path=<RUTA_LIMPIA> | status_code=<CODIGO_HTTP>
  ```
- **Protección de Datos Sensibles:** La auditoría excluye de forma estricta parámetros de consulta (`query strings`), contraseñas, tokens y cabeceras de autorización para prevenir fugas de información (*information disclosure*).
- **Ejecución con Mínimo Privilegio:** El contenedor Docker opera bajo un usuario de sistema no privilegiado (`appuser`, UID 1000).
- **Compatibilidad Dinámica de Puerto:** Permite la inyección dinámica de la variable de entorno `PORT` requerida por plataformas de nube como Render.

---

## 3. Endpoints del Servicio

| Método | Endpoint | Tipo de Contenido | Código HTTP | Descripción |
|---|---|---|---|---|
| `GET` | `/` | `text/html; charset=utf-8` | `200 OK` | Panel visual del Servidor DMZ con indicación operativa. |
| `GET` | `/health` | `application/json` | `200 OK` | Monitoreo perimetral y comprobación de estado de salud. |

### Ejemplo de respuesta `/health`:
```json
{
  "module": "00-servidor-dmz",
  "service": "servidor-dmz",
  "status": "ok",
  "student": "Mariluz David Martínez",
  "timestamp_utc": "2026-11-07T04:39:24Z",
  "version": "1.0.0"
}
```

---

## 4. Requisitos Previos

- **Python:** Versión 3.11.x instalada.
- **Docker:** Docker Desktop o Docker Engine (opcional para ejecución en contenedores).
- **Git:** Para control de versiones.

---

## 5. Instrucciones de Ejecución Local

### Opción A: Ejecución con Entorno Virtual Python

1. Posicionarse en la carpeta del módulo:
   ```bash
   cd 00-servidor-dmz
   ```

2. Crear y activar un entorno virtual:
   - **En Windows (PowerShell):**
     ```powershell
     python -m venv .venv
     .\.venv\Scripts\Activate.ps1
     ```
   - **En Linux / macOS:**
     ```bash
     python3 -m venv .venv
     source .venv/bin/activate
     ```

3. Instalar dependencias:
   ```bash
   pip install -r requirements.txt
   ```

4. Ejecutar la aplicación:
   - **Modo Desarrollo:**
     ```bash
     python app.py
     ```
   - **Modo Producción con Gunicorn (Linux/WSL):**
     ```bash
     gunicorn --bind 0.0.0.0:8080 --workers 2 app:app
     ```

5. Abrir en el navegador:
   - `http://localhost:8080/`
   - `http://localhost:8080/health`

---

## 6. Ejecución y Despliegue con Docker

### Construir la imagen Docker:
Desde la raíz del repositorio o dentro de `00-servidor-dmz`:
```bash
docker build -t servidor-dmz:1.0.0 00-servidor-dmz
```

### Ejecutar el contenedor:
```bash
docker run -d --name dmz-service -p 8080:8080 -e PORT=8080 servidor-dmz:1.0.0
```

### Consultar los logs de auditoría en vivo:
```bash
docker logs -f dmz-service
```

### Detener y remover el contenedor:
```bash
docker stop dmz-service
docker rm dmz-service
```

---

## 7. Despliegue en Render

Para desplegar este módulo en **Render**:
1. Conectar el repositorio de GitHub: `https://github.com/davidmaryluz6-stack/laboratorio-ciberseguridad-mariluz-david-martinez`.
2. Crear un nuevo servicio de tipo **Web Service**.
3. Configurar los parámetros:
   - **Language / Runtime:** `Docker`.
   - **Root Directory:** `00-servidor-dmz` (o seleccionar Dockerfile path `00-servidor-dmz/Dockerfile`).
   - **Health Check Path:** `/health`.
   - **Auto-Deploy:** Opcional (activar si se desea despliegue continuo tras push a `main`).
4. Render inyectará automáticamente la variable de entorno `PORT`, la cual es gestionada dinámicamente por la directiva `CMD` del `Dockerfile`.

---

## 8. Pruebas Automáticas

El módulo cuenta con una suite de pruebas unitarias automatizadas con `unittest` que validan respuestas HTTP, renderizado del HTML, estructura JSON y seguridad de logs de auditoría.

Para ejecutar las pruebas:
```bash
python -m unittest discover -s tests -p "test_*.py" -v
```

---

## 9. Medidas de Seguridad Implementadas

1. **Usuario No Privilegiado:** La imagen Docker crea y ejecuta bajo el usuario `appuser` (UID 1000), mitigando riesgos de escalamiento de privilegios.
2. **Minimización de Superficie:** Uso de `python:3.11-slim` como imagen base libre de compiladores y paquetes innecesarios.
3. **Aislamiento Perimetral (DMZ):** El servidor actúa como barrera frontal, evitando conexiones directas hacia servicios internos no autenticados.
4. **Sanitización de Trazas:** Las bitácoras registran únicamente la ruta base de recursos solicitados, eliminando credenciales en query strings o encabezados de autorización.

