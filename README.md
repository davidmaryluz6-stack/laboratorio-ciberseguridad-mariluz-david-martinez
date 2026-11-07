# Laboratorio de Ciberseguridad — IU Digital de Antioquia

**Estudiante:** Mariluz David Martínez  
**Institución:** Institución Universitaria Digital de Antioquia (IU Digital)  
**Actividad:** Unidad 2 — Demostración en vivo y evaluación de laboratorio en la nube  
**Repositorio Oficial:** [laboratorio-ciberseguridad-mariluz-david-martinez](https://github.com/davidmaryluz6-stack/laboratorio-ciberseguridad-mariluz-david-martinez)  

---

## 1. Objetivo General del Laboratorio

Diseñar, implementar y evaluar un entorno integral de ciberseguridad perimetral y simulación controlada de amenazas en contenedores Docker y computación en la nube (Render). El proyecto articula un nodo defensivo en Zona Desmilitarizada (DMZ) expuesto de forma segura en la nube, junto con siete módulos de experimentación pedagógica confinados en redes locales privadas para el análisis de vectores de ataque y sus correspondientes contramedidas defensivas.

---

## 2. Arquitectura del Proyecto (8 Módulos Completos)

```text
laboratorio-ciberseguridad-mariluz-david-martinez/
│
├── docker-compose.yml              # Orquestador del laboratorio local en red privada aislada
├── .gitignore                      # Exclusión de credenciales, llaves y artefactos temporales
├── README.md                       # Documentación maestra del laboratorio
│
├── 00-servidor-dmz/                # Módulo 00 — Servidor Perimetral DMZ (Nube Render + Local)
│   ├── app.py                      # Aplicación Flask, endpoints y middleware de auditoría
│   ├── Dockerfile                  # Empaquetado en python:3.11-slim con usuario no privilegiado
│   ├── .dockerignore               # Contexto optimizado para compilación Docker
│   ├── requirements.txt            # Dependencias fijadas (Flask, Gunicorn, Werkzeug)
│   ├── README.md                   # Documentación específica del servidor DMZ
│   └── tests/                      # Suite de validación automatizada
│       └── test_app.py             # Pruebas unitarias y de integridad perimetral
│
├── 01-ataque-dos/                  # Módulo 01 — Simulación de Tráfico Masivo (DoS Controlado)
│   ├── entrypoint.sh               # Ráfaga concurrente limitada con salvaguarda de seguridad
│   └── Dockerfile                  # Imagen Alpine con curl y bind-tools
│
├── 02-escaneo-puertos/             # Módulo 02 — Reconocimiento y Escaneo de Puertos
│   ├── entrypoint.sh               # Escaneo netcat confinado a la red interna de contenedores
│   └── Dockerfile                  # Imagen Alpine con netcat-openbsd
│
├── 03-fuerza-bruta-rutas/          # Módulo 03 — Enumeración Controlada de Rutas Web
│   ├── entrypoint.sh               # Sondeo de endpoints conocidos sobre el servidor DMZ
│   └── Dockerfile                  # Imagen Alpine con curl
│
├── 04-exfiltracion-dns/            # Módulo 04 — Demostración de Exfiltración Encubierta DNS
│   ├── entrypoint.sh               # Codificación Base64 y consulta a resolvedor interno Docker
│   └── Dockerfile                  # Imagen Alpine con bind-tools (nslookup)
│
├── 05-cadena-suministro/           # Módulo 05 — Compromiso en Cadena de Suministro (Supply Chain)
│   ├── entrypoint.sh               # Verificación de integridad y alerta educativa en runtime
│   └── Dockerfile                  # Inyección didáctica e inocua durante el build
│
├── 06-credential-stuffing/         # Módulo 06 — Simulación de Credential Stuffing / Brute Force
│   ├── entrypoint.sh               # Pruebas controladas de autenticación con identidades demo
│   └── Dockerfile                  # Imagen Alpine con curl
│
├── 07-proxy-mitm/                  # Módulo 07 — Proxy Interceptor Man-In-The-Middle (MITM)
│   ├── app.py                      # Proxy inverso Flask con inyección inocua de alerta en tránsito
│   ├── requirements.txt            # Dependencias Flask y Requests
│   └── Dockerfile                  # Imagen python:3.11-slim no privilegiada
│
├── evidencias/                     # Repositorio central de soportes y evidencias académicas
│   ├── capturas/                   # Evidencias gráficas oficiales (E01 a E05 en Render y GitHub)
│   ├── logs/                       # Trazas de auditoría reales de Render
│   ├── modulo-01-dos/              # Logs de ejecución de la ráfaga DoS
│   ├── modulo-02-escaneo/          # Logs del escaneo de puertos local
│   ├── modulo-03-rutas/            # Logs de la enumeración de rutas
│   ├── modulo-04-dns/              # Logs de la simulación DNS
│   ├── modulo-05-cadena-suministro/# Logs de la auditoría de build
│   ├── modulo-06-credential-stuffing/# Logs de pruebas de autenticación
│   ├── modulo-07-proxy-mitm/       # Logs de intercepción proxy MITM
│   ├── Informe_Evidencias_Modulo_00.md  # Informe técnico oficial del Servidor DMZ
│   └── Informe_Evidencias_Fase_02.md    # Informe de ejecución y análisis de los Módulos 01–07
│
└── entrega-final/                  # Carpeta designada para entregables y reportes finales
```

---

## 3. Matriz de Clasificación Operativa: Docker Local vs. Nube (Render)

| Módulo | Nombre | Rol Pedagógico | Despliegue en Render Cloud | Ejecución en Docker Local |
|---|---|---|---|---|
| **00** | `00-servidor-dmz` | Nodo defensivo público | **SÍ (Activo / Live)** | **SÍ (Nodo objetivo)** |
| **01** | `01-ataque-dos` | Tráfico masivo simulado | **NO** (Viola AUP / Anti-DDoS) | **SÍ** (Confinado a `servidor-dmz`) |
| **02** | `02-escaneo-puertos` | Reconocimiento de puertos | **NO** (Bloqueado por WAF) | **SÍ** (Red privada Docker) |
| **03** | `03-fuerza-bruta-rutas`| Enumeración de rutas web | **NO** (Tráfico ofensivo) | **SÍ** (Sondeo controlado) |
| **04** | `04-exfiltracion-dns` | Fuga encubierta DNS | **NO** (Genera NXDOMAIN público) | **SÍ** (Resolvedor interno) |
| **05** | `05-cadena-suministro` | Integridad de artefactos | Demostración pasiva local | **SÍ** (Auditoría de build) |
| **06** | `06-credential-stuffing`| Ataque de autenticación | **NO** (Tráfico ofensivo) | **SÍ** (Credenciales ficticias) |
| **07** | `07-proxy-mitm` | Interceptación de tráfico | Demostración pasiva local | **SÍ** (Proxy en puerto 8089) |

> **Principio de Seguridad Ética:** La infraestructura pública de Render aloja exclusivamente el componente perimetral **`00-servidor-dmz`**. Ningún módulo ofensivo o de escaneo debe apuntar a la nube para salvaguardar la reputación de la red y cumplir la política de uso aceptable del proveedor.

---

## 4. Instrucciones de Ejecución en Docker Compose

### 4.1. Construcción de todas las imágenes
```bash
docker compose build
```

### 4.2. Iniciar el Servidor DMZ local
```bash
docker compose up -d servidor-dmz
```
El servidor DMZ estará disponible en la red privada de Docker (`http://servidor-dmz:8080`) y expuesto localmente en `http://localhost:8088/`.

### 4.3. Ejecutar las demostraciones pedagógicas de forma individual

- **Módulo 01 (DoS Simulado):**
  ```bash
  docker compose run --rm -e STANDALONE=true 01-ataque-dos
  ```

- **Módulo 02 (Escaneo de Puertos):**
  ```bash
  docker compose run --rm -e STANDALONE=true 02-escaneo-puertos
  ```

- **Módulo 03 (Fuerza Bruta de Rutas):**
  ```bash
  docker compose run --rm -e STANDALONE=true 03-fuerza-bruta-rutas
  ```

- **Módulo 04 (Exfiltración DNS):**
  ```bash
  docker compose run --rm -e STANDALONE=true 04-exfiltracion-dns
  ```

- **Módulo 05 (Cadena de Suministro):**
  ```bash
  docker compose run --rm -e STANDALONE=true 05-cadena-suministro
  ```

- **Módulo 06 (Credential Stuffing):**
  ```bash
  docker compose run --rm -e STANDALONE=true 06-credential-stuffing
  ```

- **Módulo 07 (Proxy Interceptor MITM):**
  ```bash
  docker compose up -d 07-proxy-mitm
  ```
  Acceda a través del proxy en `http://localhost:8089/` y observe la inyección del banner de alerta MITM en el HTML de la DMZ.

### 4.4. Detención del entorno local
```bash
docker compose down
```

---

## 5. Servicio Desplegado en la Nube (Módulo 00)

- **URL Pública:** [https://laboratorio-ciberseguridad-mariluz-david.onrender.com/](https://laboratorio-ciberseguridad-mariluz-david.onrender.com/)
- **Health Check Endpoint:** [https://laboratorio-ciberseguridad-mariluz-david.onrender.com/health](https://laboratorio-ciberseguridad-mariluz-david.onrender.com/health)
- **Estado en Render:** `Live` (Docker, Plan Free, Commit `3432e9d`).
- **Evidencias Gráficas:** Documentadas en [`evidencias/Informe_Evidencias_Modulo_00.md`](evidencias/Informe_Evidencias_Modulo_00.md).
