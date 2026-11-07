# Laboratorio de Ciberseguridad en la Nube — Informe Académico Consolidado

**Institución:** Institución Universitaria Digital de Antioquia (IU Digital)  
**Programa Académico:** Tecnología en Desarrollo de Software / Ingeniería de Software  
**Curso:** Ciberseguridad  
**Actividad:** Unidad 2 — Demostración en vivo y evaluación de laboratorio en la nube  
**Estudiante:** Mariluz David Martínez  
**Correo Institucional / Contacto:** `davidmaryluz6@gmail.com`  
**Usuario de GitHub:** `davidmaryluz6-stack`  
**Fecha:** Noviembre de 2026  

---

## 1. Enlaces Oficiales del Entorno de Evaluación

- **Repositorio Oficial en GitHub:**  
  [https://github.com/davidmaryluz6-stack/laboratorio-ciberseguridad-mariluz-david-martinez](https://github.com/davidmaryluz6-stack/laboratorio-ciberseguridad-mariluz-david-martinez)
- **Servidor Perimetral DMZ en Render Cloud (Producción):**  
  [https://laboratorio-ciberseguridad-mariluz-david.onrender.com/](https://laboratorio-ciberseguridad-mariluz-david.onrender.com/)
- **Endpoint de Diagnóstico y Salud (/health):**  
  [https://laboratorio-ciberseguridad-mariluz-david.onrender.com/health](https://laboratorio-ciberseguridad-mariluz-david.onrender.com/health)

---

## 2. Resumen Ejecutivo y Alcance del Laboratorio

El presente proyecto académico aborda la reconstrucción, configuración, despliegue y auditoría técnica de un entorno perimetral de ciberseguridad basado en contenedores Docker y servicios cloud en Render.

El entorno se encuentra estructurado en dos capas operativas complementarias:
1. **Capa Pública Defensiva (Módulo 00):** Servidor DMZ en producción continua bajo Render, implementado en Python 3.11 con Flask y Gunicorn, ejecutándose en un contenedor con usuario no privilegiado (`appuser`) y sistema de auditoría estructurada (`AUDIT_LOG`) con higienización de cabeceras y parámetros.
2. **Capa Local Confinada (Módulos 01 a 07):** Siete módulos pedagógicos orquestados mediante Docker Compose sobre una red privada bridge aislada (`internal: true`). Esta arquitectura garantiza que las demostraciones de tráfico masivo (DoS), escaneo de puertos, enumeración web, exfiltración DNS en loopback, auditoría de cadena de suministro, credential stuffing y proxy MITM se ejecuten sin generar tráfico externo hacia internet ni hacia los servidores de Render.

---

## 3. Matriz Consolidada de Módulos y Evidencias

| Módulo | Denominación Oficial | Rol Técnico | Entorno de Ejecución | Archivo de Evidencia Gráfica | Registro de Auditoría | Estado |
|---|---|---|---|---|---|---|
| **00** | Servidor Perimetral DMZ | Servidor Web Objetivo | Render Cloud + Docker Local | `capturas/E01` a `E05` | `logs/E01_Registro_Servidor_DMZ.txt` | **100% Operativo** |
| **01** | Ataque DoS Controlado | Generación de Tráfico | Docker Local (`lab-dmz-net`) | `modulo-01-dos/E01_Simulacion_DoS.png` | `modulo-01-dos/log_ejecucion.txt` | **100% Validado** |
| **02** | Escaneo de Puertos | Reconocimiento Perimetral | Docker Local (`lab-dmz-net`) | `modulo-02-escaneo/E02_Escaneo_Puertos.png` | `modulo-02-escaneo/log_ejecucion.txt` | **100% Validado** |
| **03** | Fuerza Bruta de Rutas | Enumeración Web | Docker Local (`lab-dmz-net`) | `modulo-03-rutas/E03_Enumeracion_Rutas.png` | `modulo-03-rutas/log_ejecucion.txt` | **100% Validado** |
| **04** | Exfiltración por DNS | Canal Encubierto Simulado | Docker Local (Loopback 1053) | `modulo-04-dns/E04_Exfiltracion_DNS.png` | `modulo-04-dns/log_ejecucion.txt` | **100% Validado** |
| **05** | Cadena de Suministro | Integridad de Artefactos | Docker Local (Build Phase) | `modulo-05-cadena-suministro/E05_Cadena_Suministro.png` | `modulo-05-cadena-suministro/log_ejecucion.txt` | **100% Validado** |
| **06** | Credential Stuffing | Ataque de Autenticación | Docker Local (`lab-dmz-net`) | `modulo-06-credential-stuffing/E06_Credential_Stuffing.png` | `modulo-06-credential-stuffing/log_ejecucion.txt` | **100% Validado** |
| **07** | Proxy Interceptor MITM | Manipulación en Tránsito | Docker Local (Puerto 8089) | `modulo-07-proxy-mitm/E07_Proxy_MITM.png` | `modulo-07-proxy-mitm/log_ejecucion.txt` | **100% Validado** |

---

## 4. Hallazgos y Dictámenes Técnicos de Auditoría

1. **Aislamiento Estricto de Red:**
   La inclusión de `internal: true` en la red Docker previene que el kernel de Linux realice enrutamiento NAT hacia redes públicas. Esto asegura que ningún contenedor ofensivo pueda interactuar con direcciones IP de internet.
2. **Auditoría de Exfiltración DNS:**
   Se determinó que un código `NXDOMAIN` emitido por un resolvedor DNS estándar no prueba por sí mismo el aislamiento, ya que puede originarse por reenvío recursivo a servidores raíz públicos. En consecuencia, el Módulo 04 fue provisto de un receptor DNS simulado interno en loopback (`127.0.0.1:1053`), capturando el payload Base64 sin emitir paquetes al exterior.
3. **Auditoría de Credential Stuffing (HTTP 200 vs Autenticación):**
   Se documentó formalmente que la recepción de respuestas HTTP 200 ante peticiones con cabeceras `Authorization` en el servidor DMZ no constituye una autenticación exitosa, sino la respuesta estándar de un endpoint público desprotegido. Esto fundamenta la necesidad de mecanismos de autenticación robustos (MFA, Account Lockout) en endpoints sensibles.
4. **Seguridad en Tránsito (MITM):**
   La demostración del Módulo 07 evidencia cómo un proxy intermediario puede alterar código HTML en canales no protegidos, confirmando la criticidad de HTTPS con HSTS.

---

## 5. Conclusiones Generales

El laboratorio satisface rigurosamente los requerimientos de la Unidad 2, conjugando un despliegue cloud funcional y documentado con un banco de pruebas local aislado, reproducible y alineado con las buenas prácticas de ciberseguridad y ética profesional.

