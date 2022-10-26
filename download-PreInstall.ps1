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


Write-Output "Checking if Chocolatey is installed"
Write-Output "$($apikey)"

$testchoco = powershell choco -v
if(-not($testchoco)){
    Write-Output "Seems Chocolatey is not installed, installing now"
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
else{
    Write-Output "Chocolatey Version $testchoco is already installed"
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
