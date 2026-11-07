# Guion Técnico para Sustentación en Video (Máximo 7 Minutos)

**Institución:** Institución Universitaria Digital de Antioquia (IU Digital)  
**Actividad:** Unidad 2 — Demostración en vivo y evaluación de laboratorio en la nube  
**Estudiante:** Mariluz David Martínez  
**Duración Total Estimada:** 6 minutos y 45 segundos  
**Recursos a Mostrar en Pantalla:** Navegador web (Render, GitHub), terminal PowerShell/Docker Desktop, logs en vivo.

---

## Estructura Temporal del Video

```text
[0:00 - 1:00]  Bloque 1: Presentación institucional y arquitectura del laboratorio.
[1:00 - 2:30]  Bloque 2: Servidor DMZ perimetral en vivo en Render Cloud (Módulo 00).
[2:30 - 4:00]  Bloque 3: Módulos de reconocimiento y tráfico (Módulos 01, 02 y 03).
[4:00 - 5:30]  Bloque 4: Vectores avanzados (Módulos 04, 05 y 06).
[5:30 - 6:30]  Bloque 5: Proxy Interceptor Man-In-The-Middle (Módulo 07).
[6:30 - 6:45]  Bloque 6: Conclusiones técnicas y cierre formal.
```

---

## Guion Detallado por Bloques

### Bloque 1: Introducción y Contexto Académico (0:00 - 1:00)
- **Pantalla:** Repositorio en GitHub ([laboratorio-ciberseguridad-mariluz-david-martinez](https://github.com/davidmaryluz6-stack/laboratorio-ciberseguridad-mariluz-david-martinez)).
- **Locución (Estudiante):**
  > "Cordial saludo al docente y compañeros de la IU Digital de Antioquia. Mi nombre es Mariluz David Martínez. En esta demostración de la Unidad 2, presento la implementación y validación integral de nuestro Laboratorio de Ciberseguridad en la Nube.
  > La arquitectura consta de ocho módulos organizados de manera modular: un servidor perimetral público en Zona Desmilitarizada (DMZ) alojado en la plataforma Render, y siete módulos de experimentación pedagógica confinados bajo una red privada Docker con aislamiento estricto `internal: true`, garantizando que ninguna prueba ofensiva afecte redes públicas ni servicios de terceros."

---

### Bloque 2: Servidor DMZ en Render Cloud (1:00 - 2:30)
- **Pantalla:** Navegador abriendo:
  1. `https://laboratorio-ciberseguridad-mariluz-david.onrender.com/`
  2. `https://laboratorio-ciberseguridad-mariluz-david.onrender.com/health`
  3. Consola de logs en Render Dashboard.
- **Locución (Estudiante):**
  > "Comenzamos con el Módulo 00: nuestro Servidor Perimetral DMZ. Como observamos en pantalla, el servicio está en estado Live en Render, construido en Python 3.11 con Gunicorn y empaquetado en un contenedor Docker con usuario no privilegiado `appuser`.
  > La interfaz web presenta un panel limpio con el texto exacto requerido: 'Servidor DMZ Activo - Laboratorio de Mariluz David Martínez' y el indicador verde de operatividad.
  > Al consultar el endpoint `/health`, obtenemos el diagnóstico JSON en tiempo real con status `ok`, versión `1.0.0` y marca de tiempo UTC.
  > En la consola de logs de Render, verificamos el middleware de auditoría estructurada que registra cada petición bajo el formato `AUDIT_LOG`, higienizando rutas y protegiendo contra la fuga de credenciales o tokens."

---

### Bloque 3: Módulos de Red y Reconocimiento Local (2:30 - 4:00)
- **Pantalla:** Terminal ejecutando `docker compose run` para los módulos 01, 02 y 03.
- **Locución (Estudiante):**
  > "Pasamos a la red local privada en Docker Compose.
  > En el Módulo 01, ejecutamos una simulación de ráfaga concurrente de 30 solicitudes hacia la DMZ local. El servidor responde con código 200 sin saturación, permitiéndonos analizar cómo implementar Rate Limiting para prevenir la denegación de servicio.
  > En el Módulo 02, corremos el escaneo de puertos mediante `netcat`. Vemos con total claridad que únicamente el puerto 8080 del servicio web está abierto, mientras que FTP, SSH y MySQL se encuentran cerrados, aplicando el principio de reducción de superficie de ataque.
  > En el Módulo 03, simulamos la enumeración de rutas. El servidor DMZ responde con 404 a rutas inexistentes como `/admin` o `/backup.zip`, protegiendo archivos de configuración."

---

### Bloque 4: Vectores Avanzados — DNS, Build y Autenticación (4:00 - 5:30)
- **Pantalla:** Terminal mostrando la ejecución de los módulos 04, 05 y 06.
- **Locución (Estudiante):**
  > "En el Módulo 04 demostramos la exfiltración encubierta por DNS. Codificamos un dato ficticio en Base64 incrustado en el subdominio. Para garantizar que no exista fuga hacia internet, levantamos un receptor DNS interno en loopback en el puerto 1053, capturando el payload dentro del contenedor.
  > En el Módulo 05 abordamos la seguridad en la cadena de suministro. Durante el `docker build` simulamos la inyección de una dependencia no autorizada, la cual es detectada por el control de integridad en runtime, demostrando la necesidad de herramientas de análisis como Docker Scout y Trivy.
  > En el Módulo 06 probamos intentos de Credential Stuffing con identidades ficticias. Es fundamental destacar una conclusión de nuestra auditoría técnica: el servidor devuelve HTTP 200 porque la ruta raíz es pública; recibir código 200 no significa una autenticación exitosa, lo que resalta la urgencia de implementar autenticación multifactor (MFA) y bloqueo por intentos fallidos."

---

### Bloque 5: Proxy Interceptor Man-In-The-Middle (5:30 - 6:30)
- **Pantalla:** Navegador abriendo `http://localhost:8089/` y terminal del proxy.
- **Locución (Estudiante):**
  > "En el Módulo 07 implementamos un Proxy Interceptor en Flask. Al acceder a través del puerto del proxy, observamos cómo se captura el tráfico en tránsito y se inyecta dinámicamente un banner visual de alerta roja en el HTML original de la DMZ. Esta prueba demuestra de forma gráfica el peligro de transmitir datos sin cifrar en redes internas y fundamenta la obligatoriedad de HTTPS con HSTS y mTLS."

---

### Bloque 6: Conclusiones y Cierre (6:30 - 6:45)
- **Pantalla:** Cámara web o diapositiva final con datos de la estudiante y repositorio.
- **Locución (Estudiante):**
  > "En conclusión, este laboratorio integra de manera rigurosa la teoría perimetral con la práctica forense, validando tanto la defensa en la nube como el análisis controlado de vectores de ataque. Muchas gracias por su atención."

