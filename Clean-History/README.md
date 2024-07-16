# Script de Limpieza del Sistema

Este script de PowerShell realiza varias tareas de limpieza en el sistema, incluyendo la eliminación de archivos temporales, el historial del cuadro de ejecución, el historial de PowerShell y el contenido de la papelera de reciclaje. También muestra mensajes en ventanas emergentes para informar al usuario sobre el estado de cada operación.

## Funcionalidades

- Elimina el contenido de la carpeta `Temp`.
- Elimina el historial del cuadro de ejecución (Run box).
- Elimina el historial de PowerShell.
- Elimina el contenido de la papelera de reciclaje.
- Muestra mensajes en ventanas emergentes para informar sobre el éxito o error de cada operación.

## Uso

1. **Clona el repositorio**:
    ```bash
    git clone https://github.com/tuusuario/nombre-del-repositorio.git
    cd nombre-del-repositorio
    ```

2. **Ejecuta el script**:
    - Abre PowerShell con privilegios de administrador.
    - Navega hasta el directorio donde se encuentra el script.
    - Ejecuta el script:
      ```powershell
      .\nombre-del-script.ps1
      ```

## Código del Script

```powershell
# Función para mostrar mensajes en una ventana emergente
function Show-MessageBox {
    param (
        [string]$message,
        [string]$title
    )
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show($message, $title, 'OK', 'Information')
}

# Función para eliminar archivos de una carpeta
function Clear-Folder {
    param (
        [string]$folderPath
    )
    try {
        if (Test-Path $folderPath) {
            Remove-Item "$folderPath\*" -Recurse -Force -ErrorAction SilentlyContinue
            Show-MessageBox "Archivos en $folderPath borrados exitosamente." "Éxito"
        } else {
            Show-MessageBox "La carpeta $folderPath no existe." "Error"
        }
    } catch {
        Show-MessageBox "Error al borrar archivos en $folderPath: $_" "Error"
    }
}

# Borrar el contenido de la carpeta Temp
Clear-Folder $env:TEMP

# Borrar el historial del cuadro de ejecución (Run box)
try {
    reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
    Show-MessageBox "Historial del cuadro de ejecución borrado exitosamente." "Éxito"
} catch {
    Show-MessageBox "Error al borrar el historial del cuadro de ejecución: $_" "Error"
}

# Borrar el historial de PowerShell
try {
    $historyPath = (Get-PSReadlineOption).HistorySavePath
    if (Test-Path $historyPath) {
        Remove-Item $historyPath -Force -ErrorAction SilentlyContinue
        Show-MessageBox "Historial de PowerShell borrado exitosamente." "Éxito"
    } else {
        Show-MessageBox "No se encontró el archivo de historial de PowerShell." "Error"
    }
} catch {
    Show-MessageBox "Error al borrar el historial de PowerShell: $_" "Error"
}

# Borrar el contenido de la papelera de reciclaje
try {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Show-MessageBox "Contenido de la papelera de reciclaje borrado exitosamente." "Éxito"
} catch {
    Show-MessageBox "Error al borrar el contenido de la papelera de reciclaje: $_" "Error"
}
