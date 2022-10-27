[CmdletBinding()]
param (
    [string]$apiKey
)

function Write-LocalMessage {
    [CmdletBinding()]
    param (
        [string]$Message
    )

    if (Test-Path function:Write-Message) { Write-Message -Level Output -Message $Message }
    else { Write-Host $Message }
}


$temp = ([System.IO.Path]::GetTempPath())
$zipfile = Join-Path -Path $temp -ChildPath "Preinstall.zip"

$credentials = $apiKey
$repo = "JHAEISIS/EWF-Implementations-PreInstall"
$file = "Preinstall.zip"

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "token $credentials")
$releases = "https://api.github.com/repos/$repo/releases"

Write-Host Determining latest release
$id = ((Invoke-WebRequest $releases -Headers $headers | ConvertFrom-Json)[0].assets | where-object { $_.name -eq $file })[0].id

$download = "https://" + $credentials + ":@api.github.com/repos/$repo/releases/assets/$id"

Write-Host Dowloading latest release
$headers.Add("Accept", "application/octet-stream")
Invoke-WebRequest -Uri $download -Headers $headers -OutFile $zipfile

if (($PSVersionTable.PSVersion.Major -lt 6) -or ($PSVersionTable.Platform -and $PSVersionTable.Platform -eq 'Win32NT')) {
    Write-LocalMessage -Message "Unblocking"
    Unblock-File $zipfile -ErrorAction SilentlyContinue
}

$destinationFolder = $temp
Write-Host Extracting release files
Expand-Archive $zipfile -DestinationPath $destinationFolder -Force

$copyFolder = $temp + 'JX'
Copy-Item -Path $copyFolder -Destination "C:\" -Recurse -force

Write-Host Cleaning up target dir
Remove-Item "$zipfile" -Force

Write-Host "PreInstall Loaded Successfully"
Write-Host "Starting Setup.ps1"
Start-Process powershell -verb runas -ArgumentList "-file C:\JX\Preinstall\Setup.ps1"
