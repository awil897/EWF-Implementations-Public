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
function download-file-from-github-repo($repoPath, $repoFilename, $repoName, $repoOwner, $message, $token, $destination) {


    $url = "https://api.github.com/repos/$repoOwner/$repoName/contents/$repoPath/$repoFilename"

    try {
        $response = invoke-restMethod $url -headers @{Authorization = "bearer $token"}
    }
    catch {
            write-host "$($repoFileName) cannot be found in repository" -ForegroundColor Red

            return
    }
    write-output "$repoFilename found. Copying to $destination"
    $fullDestination = "$destination\$repofilename"
    $base64 = $response.content
    $bytes = [Convert]::FromBase64String($base64)
    [IO.File]::WriteAllBytes($fullDestination, $bytes)
    Write-Host "$repoFilename successfully copied to $destination" -ForegroundColor Green
    
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
Get-ChildItem -Path C:\JX -Recurse | Unblock-File
Set-ExecutionPolicy Unrestricted -Scope currentuser -Force -Confirm:$false

Write-Host "Attempting to download certificates"
$ewfFarm = Read-Host "Enter EWF Farm URL" 

$filename = $ewfFarm.Substring($ewfFarm.LastIndexOf("/") + 1)
$prefix = $filename.Split('.')[0]

if ($prefix -clike "ewf"){
    $rpName = $ewfFarm.Replace('ewf','rp-ewf')
    $rpName = $rpName.Replace('.com','.com.pfx')
    $ewfFarm = $ewfFarm.Replace('.com','.com.pfx')
}

if ($prefix -clike "EWF"){
    $rpName = $ewfFarm.Replace('EWF','RP-EWF')
    $rpName = $rpName.Replace('.com','.com.pfx')
    $ewfFarm = $ewfFarm.Replace('.com','.com.pfx')
}

if ($prefix -clike "ewf-uat"){
    $rpName = $ewfFarm.Replace('ewf-uat','rp-ewf')
    $rpName = $rpName.Replace('.com','.com.pfx')
    $ewfFarm = $ewfFarm.Replace('.com','.com.pfx')
}

if ($prefix -clike "EWF-UAT"){
    $rpName = $ewfFarm.Replace('EWF-UAT','RP-EWF')
    $rpName = $rpName.Replace('.com','.com.pfx')
    $ewfFarm = $ewfFarm.Replace('.com','.com.pfx')
}


$certsToDownload = @($ewfFarm,$rpName)
$certsString = $certsToDownload -join ", "


Write-Host "Checking Repository for $certsString"
foreach ($cert in $certsToDownload){
    download-file-from-github-repo -repoPath "certs" -repoFilename $cert -repoName "EWF-Implementations-Certificates" -repoOwner "JHAEISIS"  -token $apikey -destination "C:\JX\Preinstall\Certs"
}

Write-Host "Starting Setup.ps1"
Start-Process powershell -verb runas -ArgumentList "-file C:\JX\Preinstall\Setup.ps1"
