# Borrar el contenido de la carpeta Temp
try {
    if (Test-Path $env:TEMP) {
        Write-Output "Borrando archivos en $env:TEMP..."
        Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction Stop
        Write-Output "Archivos en $env:TEMP borrados exitosamente."
    } else {
        Write-Output "La carpeta $env:TEMP no existe."
    }
} catch {
    Write-Output "Error al borrar archivos en $env:TEMP: $_"
}

# Borrar el historial del cuadro de ejecución (Run box)
try {
    reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
    Write-Output "Historial del cuadro de ejecución borrado exitosamente."
} catch {
    Write-Output "Error al borrar el historial del cuadro de ejecución: $_"
}

# Borrar el historial de PowerShell
try {
    $historyPath = (Get-PSReadlineOption).HistorySavePath
    if (Test-Path $historyPath) {
        Remove-Item $historyPath -Force -ErrorAction Stop
        Write-Output "Historial de PowerShell borrado exitosamente."
    } else {
        Write-Output "No se encontró el archivo de historial de PowerShell."
    }
} catch {
    Write-Output "Error al borrar el historial de PowerShell: $_"
}

# Borrar el contenido de la papelera de reciclaje
try {
    Clear-RecycleBin -Force -ErrorAction Stop
    Write-Output "Contenido de la papelera de reciclaje borrado exitosamente."
} catch {
    Write-Output "Error al borrar el contenido de la papelera de reciclaje: $_"
}

