# Export-WiFiKeys

Este script de PowerShell exporta las contraseñas de las redes WiFi almacenadas en tu computadora, las guarda en archivos de texto, las comprime en un archivo ZIP y luego sube el archivo ZIP a Dropbox. Después de completar el proceso, los archivos temporales se eliminan.

## Requisitos

- PowerShell 5.0 o superior
- Acceso a Internet
- Una cuenta de Dropbox y un token de acceso a la API de Dropbox

## Instalación

1. Clona este repositorio o descarga los archivos necesarios.

2. Define tu token de acceso a Dropbox en el script antes de ejecutarlo:

    ```powershell
    $db = "tu_token_de_dropbox"
    ```

## Uso

1. Abre PowerShell con permisos de administrador.

2. Navega al directorio donde se encuentra el script.

3. Ejecuta el script:

    ```powershell
    .\Export-WiFiKeys.ps1
    ```

El script creará un directorio con la fecha y hora actual en tu carpeta de Documentos, almacenará las contraseñas WiFi en archivos de texto dentro de este directorio, comprimirá el directorio en un archivo ZIP y subirá el archivo ZIP a tu cuenta de Dropbox. Después de completar estos pasos, el script eliminará los archivos temporales creados durante el proceso.

## Detalles del Script

### Export-WiFiKeys

Esta función realiza los siguientes pasos:

1. Crea un directorio con la fecha y hora actual en la carpeta de Documentos del usuario.
2. Recoge las contraseñas de las redes WiFi almacenadas en el sistema y las guarda en archivos de texto en el directorio creado.
3. Comprime el directorio en un archivo ZIP.
4. Llama a la función `DropBox-Upload` para subir el archivo ZIP a Dropbox.
5. Elimina los archivos temporales creados durante el proceso.

### DropBox-Upload

Esta función realiza los siguientes pasos:

1. Toma la ruta del archivo fuente como parámetro.
2. Define los encabezados y parámetros necesarios para la solicitud a la API de Dropbox.
3. Usa `Invoke-RestMethod` para subir el archivo a Dropbox.

## Notas

- Asegúrate de tener suficiente espacio en tu cuenta de Dropbox para el archivo ZIP que se subirá.
- El script debe ejecutarse con permisos de administrador para acceder a las contraseñas WiFi almacenadas en el sistema.

## Licencia

Este proyecto está licenciado bajo los términos de la licencia MIT. Consulta el archivo `LICENSE` para más detalles.
