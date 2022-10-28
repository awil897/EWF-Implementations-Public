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
            write-host '$repoFileName cannot be found in repository' -ForegroundColor Red

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
$zipfile = Join-Path -Path $temp -ChildPath "EWF_2021.0_Upgrade.zip"

$credentials = $apiKey
$repo = "JHAEISIS/EWF-Implementations-Install"
$file = "EWF_2021.0_Upgrade.zip"

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

$destinationFolder = $temp + 'EWF_2021.0_Upgrade'
Write-Host Extracting release files
Expand-Archive $zipfile -DestinationPath $destinationFolder -Force

$copyFolder = $temp + 'EWF_2021.0_Upgrade'
Copy-Item -Path $copyFolder -Destination "C:\JX\Install Files" -Recurse -force

Write-Host Cleaning up target dir
Remove-Item "$zipfile" -Force

Write-Host "Install Package Loaded Successfully"
Get-ChildItem -Path "C:\JX\Install Files" -Recurse | Unblock-File
