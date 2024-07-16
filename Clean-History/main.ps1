# Borrar el contenido de la carpeta Temp
try {
    if (Test-Path $env:TEMP) {
        Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
} catch {
    # Manejo de errores
}

# Borrar el historial del cuadro de ejecución (Run box)
try {
    reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
} catch {
    # Manejo de errores
}

# Borrar el historial de PowerShell
try {
    $historyPath = (Get-PSReadlineOption).HistorySavePath
    if (Test-Path $historyPath) {
        Remove-Item $historyPath -Force -ErrorAction SilentlyContinue
    }
} catch {
    # Manejo de errores
}

# Borrar el contenido de la papelera de reciclaje
try {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
} catch {
    # Manejo de errores
}

