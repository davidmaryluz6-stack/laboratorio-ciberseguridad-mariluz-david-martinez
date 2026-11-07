# Laboratorio de Ciberseguridad — IU Digital de Antioquia

**Estudiante:** Mariluz David Martínez  
**Institución:** Institución Universitaria Digital de Antioquia (IU Digital)  
**Actividad:** Unidad 2 — Demostración en vivo y evaluación de laboratorio en la nube  
**Repositorio Oficial:** [laboratorio-ciberseguridad-mariluz-david-martinez](https://github.com/davidmaryluz6-stack/laboratorio-ciberseguridad-mariluz-david-martinez)  

---

## 1. Objetivo General del Laboratorio

Diseñar, estructurar e implementar un entorno controlado de simulación perimetral en la nube para el análisis, experimentación y evaluación de defensas ante incidentes de ciberseguridad, iniciando con la puesta en marcha de un Servidor Perimetral en Zona Desmilitarizada (DMZ) funcional, auditado y empaquetado para despliegue automatizado.

---

## 2. Arquitectura Modular del Proyecto

El repositorio está organizado de forma modular, permitiendo el desacoplamiento progresivo de escenarios y laboratorios perimetrales:

```text
laboratorio-ciberseguridad-mariluz-david-martinez/
│
├── .gitignore                      # Exclusión de credenciales, binarios y temporales
├── README.md                       # Documentación maestra del laboratorio
│
├── 00-servidor-dmz/                # Módulo 00 — Servidor Perimetral DMZ (Activo y Operativo)
│   ├── app.py                      # Aplicación Flask con endpoints y auditoría perimetral
│   ├── Dockerfile                  # Empaquetado Docker multi-plataforma (python:3.11-slim)
│   ├── .dockerignore               # Optimización de contexto de compilación Docker
│   ├── requirements.txt            # Dependencias fijadas (Flask, Gunicorn, Werkzeug)
│   ├── README.md                   # Documentación técnica específica del servidor DMZ
│   └── tests/                      # Suite de validación automatizada
│       └── test_app.py             # Pruebas unitarias y de integridad perimetral
│
├── 01-ataque-dos/                  # Módulo provisional 01 (Pendiente validación docente)
│   └── .gitkeep
├── 02-escaneo-puertos/             # Módulo provisional 02 (Pendiente validación docente)
│   └── .gitkeep
├── 03-modulo-por-confirmar/        # Módulo provisional 03 (Pendiente validación docente)
│   └── .gitkeep
├── 04-modulo-por-confirmar/        # Módulo provisional 04 (Pendiente validación docente)
│   └── .gitkeep
├── 05-modulo-por-confirmar/        # Módulo provisional 05 (Pendiente validación docente)
│   └── .gitkeep
├── 06-modulo-por-confirmar/        # Módulo provisional 06 (Pendiente validación docente)
│   └── .gitkeep
├── 07-proxy-mitm/                  # Módulo provisional 07 (Pendiente validación docente)
│   └── .gitkeep
│
└── evidencias/                     # Repositorio central de soportes académicos
    ├── capturas/                   # Capturas de pantalla de despliegues y pruebas
    │   └── .gitkeep
    ├── logs/                       # Trazas de auditoría y registros de ejecución
    │   └── .gitkeep
    └── entrega-final/              # Reporte consolidado y entregables finales
        └── .gitkeep
```

> **Nota Metodológica:** Los módulos `01` a `07` corresponden a estructuras provisionales que preservan la arquitectura sin implementar funcionalidades no autorizadas, a la espera de las especificaciones oficiales suministradas por el docente.

---

## 3. Módulo 00 — Servidor Perimetral DMZ

El **Módulo 00** implementa la primera línea de defensa y presencia pública del laboratorio:
- **Tecnologías:** Python 3.11, Flask 3.0.3, Gunicorn 22.0.0 y contenedores Docker.
- **Interfaz Web Perimetral:** Panel limpio con fondo azul oscuro (`#0a1128`), tarjeta informativa centralizada e indicador verde pulsante de estado operativo.
- **Endpoints Expuestos:**
  - `GET /`: Panel HTML perimetral con los datos oficiales de la estudiante e institución.
  - `GET /health`: Monitoreo en formato JSON con estado (`status: "ok"`), versión, módulo y fecha en UTC.
- **Registro de Auditoría en Tiempo Real:**
  Salida estructurada hacia `stdout`/`stderr` con formato:
  ```text
  AUDIT_LOG | timestamp_utc=<ISO_8601> | method=<METODO> | path=<RUTA> | status_code=<CODIGO>
  ```
  El registro omite conscientemente parámetros de consulta y credenciales sensibles para evitar fugas (*information disclosure*).

---

## 4. Guía de Ejecución Rápida

### 4.1. Pruebas Automatizadas
Desde la raíz del repositorio, ejecute la batería de pruebas unitarias:
```bash
python -m unittest discover -s 00-servidor-dmz/tests -p "test_*.py" -v
```

### 4.2. Ejecución Local con Python
```bash
cd 00-servidor-dmz
python -m venv .venv
# Activar entorno (Windows: .venv\Scripts\Activate.ps1 | Linux: source .venv/bin/activate)
pip install -r requirements.txt
python app.py
```
El servidor escuchará en `http://localhost:8080/`.

### 4.3. Ejecución con Docker
```bash
# Construir la imagen
docker build -t servidor-dmz:1.0.0 00-servidor-dmz

# Iniciar contenedor asignando puerto dinámico
docker run -d --name dmz-node -p 8080:8080 -e PORT=8080 servidor-dmz:1.0.0

# Verificar logs
docker logs -f dmz-node

# Detener contenedor
docker stop dmz-node && docker rm dmz-node
```

---

## 5. Parámetros para Despliegue en Render

Al publicar el servicio en la plataforma [Render](https://render.com):
1. **Tipo de Servicio:** Web Service conectado al repositorio de GitHub.
2. **Entorno / Runtime:** `Docker`.
3. **Directorio Raíz / Docker Build Context:** `00-servidor-dmz`.
4. **Ruta del Dockerfile:** `Dockerfile` (relativo a la carpeta del módulo) o `00-servidor-dmz/Dockerfile` si la raíz es el proyecto completo.
5. **Ruta de Verificación de Salud (Health Check Path):** `/health`.
6. **Puerto Dinámico:** La variable `PORT` es detectada e inyectada por Render y Gunicorn se enlaza a ella automáticamente.

---

## 6. Evidencias Académicas a Conservar

Para la sustentación de la Unidad 2, se deben almacenar en la carpeta `evidencias/`:
- **`evidencias/capturas/`**:
  - Captura del panel web en `http://localhost:8080/` o URL de Render.
  - Captura de la respuesta JSON del endpoint `/health`.
  - Captura de la ejecución satisfactoria de los tests unitarios.
  - Captura del contenedor en ejecución (`docker ps`) y sus logs.
- **`evidencias/logs/`**:
  - Archivos de texto con las trazas `AUDIT_LOG` generadas durante las pruebas.
- **`evidencias/entrega-final/`**:
  - Informe final en PDF o Markdown según la rúbrica de evaluación.

---

## 7. Principios y Medidas de Ciberseguridad

1. **Aislamiento en DMZ:** Los servicios perimetrales no exponen puertos internos ni credenciales de backend.
2. **Principio de Menor Privilegio:** El contenedor Docker opera bajo el usuario sin privilegios `appuser` (UID 1000).
3. **Auditoría Higienizada:** Previene el logueo accidental de tokens o datos sensibles a través de la URI o headers.
4. **Gestión de Secretos:** Política estricta en `.gitignore` para impedir la publicación de archivos `.env`, llaves privadas (`*.key`, `*.pem`) o certificados.
