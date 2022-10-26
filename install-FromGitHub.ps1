[CmdletBinding()]
param (
    [string]$Path,
    [switch]$Beta
)

function Write-LocalMessage {
    [CmdletBinding()]
    param (
        [string]$Message
    )

    if (Test-Path function:Write-Message) { Write-Message -Level Output -Message $Message }
    else { Write-Host $Message }
}

$url = 'https://dbatools.io/zip'
$branch = "master"

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

Write-LocalMessage -Message "Downloading archive from github"
try {
    (New-Object System.Net.WebClient).DownloadFile($url, $zipfile)
} catch {
    try {
        #try with default proxy and usersettings
        Write-LocalMessage -Message "Probably using a proxy for internet access, trying default proxy settings"
        $wc = (New-Object System.Net.WebClient)
        $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        $wc.DownloadFile($url, $zipfile)
    } catch {
        Write-Warning "Error downloading file :( $_"
        return
    }
}

# Unblock if there's a block
if (($PSVersionTable.PSVersion.Major -lt 6) -or ($PSVersionTable.Platform -and $PSVersionTable.Platform -eq 'Win32NT')) {
    Write-LocalMessage -Message "Unblocking"
    Unblock-File $zipfile -ErrorAction SilentlyContinue
}

Write-LocalMessage -Message "Unzipping"


$branchpath = Join-Path -Path $temp -ChildPath "dbatools-$branch"
$oldpath = Join-Path -Path $temp -ChildPath "dbatools-old"
$wildcardoldpath = Join-Path -Path $oldpath -ChildPath *
$wildcardbranchpath = Join-Path -Path $branchpath -ChildPath *

Remove-Item -ErrorAction SilentlyContinue $branchpath -Recurse -Force
Remove-Item -ErrorAction SilentlyContinue $oldpath -Recurse -Force
$null = New-Item $oldpath -ItemType Directory
if (($PSVersionTable.Keys -contains "Platform") -and $psversiontable.Platform -ne "Win32NT") {
    $destinationFolder = $temp
    Expand-Archive -Path $zipfile -DestinationPath $destinationFolder -Force
} else {
    # Keep it backwards compatible
    $shell = New-Object -ComObject Shell.Application
    $zipPackage = $shell.NameSpace($zipfile)
    $destinationFolder = $shell.NameSpace($temp)
    $destinationFolder.CopyHere($zipPackage.Items())
}

Write-LocalMessage -Message "Applying Update"
Write-LocalMessage -Message "1) Backing up previous installation"
Copy-Item -Path $wildcardpath -Destination $oldpath -ErrorAction Stop
try {
    Write-LocalMessage -Message "2) Cleaning up installation directory"
    Remove-Item $wildcardpath -Recurse -Force -ErrorAction Stop
} catch {
    Write-LocalMessage -Message @"
Failed to clean up installation directory, rolling back update.
This usually has one of two causes:
- Insufficient privileges (need to run as admin)
- A file is locked - generally a dll file from having the module imported in some process.

You can run the following line before importing dbatools to prevent file locking:
`$dbatools_copydllmode = `$true
But it increases the time needed to import the module, so we only recommend using it for updates.

Exception:
$_
"@
    Copy-Item -Path $wildcardoldpath -Destination $path -ErrorAction Ignore -Recurse
    Remove-Item $oldpath -Recurse -Force
    return
}
Write-LocalMessage -Message "3) Setting up current version"
Move-Item -Path $wildcardbranchpath -Destination $path -ErrorAction SilentlyContinue -Force
Remove-Item -Path $branchpath -Recurse -Force
Remove-Item $oldpath -Recurse -Force
Remove-Item -Path $zipfile -Recurse -Force

Write-LocalMessage -Message "Done! Please report any bugs to dbatools.io/issues"
if (Get-Module dbatools) {
    Write-LocalMessage -Message @"

Please restart PowerShell before working with dbatools.
"@
} else {
    $psd1 = Join-Path -Path $path -ChildPath "dbatools.psd1"
    Import-Module $psd1 -Force
    Write-LocalMessage @"

dbatools v $((Get-Module dbatools).Version)
# Commands available: $((Get-Command -Module dbatools -CommandType Function | Measure-Object).Count)

"@
}
[Net.ServicePointManager]::SecurityProtocol = $currentVersionTls
Write-LocalMessage -Message "`n`nIf you experience any function missing errors after update, please restart PowerShell or reload your profile."