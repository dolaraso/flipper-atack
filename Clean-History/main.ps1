<#
########################################################################################################################
#  __  __ _____      ______ _      _____ _____  _____  ______ _____  __  __ ______ _   _ 			      #
# |  \/  |  __ \    |  ____| |    |_   _|  __ \|  __ \|  ____|  __ \|  \/  |  ____| \ | |			      #
# | \  / | |__) |   | |__  | |      | | | |__) | |__) | |__  | |__) | \  / | |__  |  \| |			      #
# | |\/| |  _  /    |  __| | |      | | |  ___/|  ___/|  __| |  _  /| |\/| |  __| |     |			      #
# | |  | | | \ \ _  | |    | |____ _| |_| |    | |    | |____| | \ \| |  | | |____| |\  |			      #
# |_|  |_|_|  \_(_) |_|    |______|_____|_|    |_|    |______|_|  \_\_|  |_|______|_| \_|                             #
#    _______     ______  ______ _____  ______ _      _____ _____  _____  ______ _____   _____ 			      # 
#   / ____\ \   / /  _ \|  ____|  __ \|  ____| |    |_   _|  __ \|  __ \|  ____|  __ \ / ____|                        # 
#  | |     \ \_/ /| |_) | |__  | |__) | |__  | |      | | | |__) | |__) | |__  | |__) | (___                          # 
#  | |      \   / |  _ <|  __| |  _  /|  __| | |      | | |  ___/|  ___/|  __| |  _  / \___ \                         # 
#  | |____   | |  | |_) | |____| | \ \| |    | |____ _| |_| |    | |    | |____| | \ \ ____) |                        # 
#   \_____|  |_|  |____/|______|_|  \_\_|    |______|_____|_|    |_|    |______|_|  \_\_____/ 			      # 
 #########################################################################################################################           
#>
# Definir la ruta de la carpeta Temp específica
$tempPath = "C:\Users\Usuario\AppData\Local\Temp"

# Borrar el contenido de la carpeta Temp específica
try {
    if (Test-Path $tempPath) {
        Write-Output "Borrando archivos en $tempPath..."
        Remove-Item "$tempPath\*" -Recurse -Force -ErrorAction Stop
        Write-Output "Archivos en $tempPath borrados exitosamente."
    } else {
        Write-Output "La carpeta $tempPath no existe."
    }
} catch {
    Write-Output "Error al borrar archivos en $tempPath: $_"
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
