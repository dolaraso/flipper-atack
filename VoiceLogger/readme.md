# Script de Registro de Voz y Subida a Dropbox

Este script de PowerShell graba audio durante un período de tiempo especificado, transcribe el audio en texto y luego sube el archivo de registro resultante a Dropbox.

## Características

- Graba audio utilizando el dispositivo de audio predeterminado del sistema.
- Transcribe el audio en texto.
- Guarda la transcripción en un archivo de texto.
- Sube el archivo de texto a Dropbox.
- Elimina el archivo de registro local después de la subida.

## Requisitos

- PowerShell
- Conexión a Internet
- Token de API de Dropbox
- Permisos para ejecutar scripts de PowerShell
- Sistema con soporte para .NET y bibliotecas de reconocimiento de voz de Windows

## Uso

### Función DropBox-Upload

Esta función sube un archivo a Dropbox.

#### Parámetros

- **RutaArchivoOrigen**: La ruta del archivo que se va a subir.

#### Ejemplo

```powershell
DropBox-Upload -RutaArchivoOrigen "C:\ruta\al\archivo.txt"

Función voiceLogger

Esta función graba audio, transcribe el audio en texto y guarda la transcripción en un archivo de texto. Luego sube el archivo a Dropbox.
Parámetros

    duracionMinutos: La duración en minutos de la grabación de audio (valor predeterminado: 5 minutos).

Ejemplo

powershell

voiceLogger -duracionMinutos 5

Instalación

    Clona el repositorio:

    bash

    git clone https://github.com/tuusuario/registro-voz-dropbox.git
    cd registro-voz-dropbox

    Asegúrate de tener los permisos necesarios para ejecutar scripts de PowerShell en tu sistema.

Detalles del Script

El script incluye las siguientes funciones:

    DropBox-Upload: Sube un archivo a Dropbox utilizando la API de Dropbox.
    voiceLogger: Graba audio durante el tiempo especificado, transcribe el audio en texto y sube el archivo resultante a Dropbox.

Nota

Para que la función de subida a Dropbox funcione correctamente, asegúrate de configurar la variable de entorno db con tu token de API de Dropbox.
