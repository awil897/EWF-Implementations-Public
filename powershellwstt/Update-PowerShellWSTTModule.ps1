Function Uninstall-OldPowerShellWSTTModules
{
    [CmdletBinding()]
    Param(
         )
    $ModuleName = "PowerShellWSTT"

    Write-Host "Uninstalling Old $ModuleName module versions." -ForegroundColor Yellow
    $Latest = Get-InstalledModule -name $ModuleName; 
    Get-InstalledModule -name $ModuleName -AllVersions | ? {$_.Version -ne $Latest.Version} | Uninstall-Module 

} # End Uninstall-OldPowerShellWSTTModules


Function Update-PowerShellWSTTModule
{
    [CmdletBinding()]
    Param(
         )
   
   
    $ModuleName = "PowerShellWSTT"

    #update
    Write-Host "Updating $ModuleName module to newest version." -ForegroundColor Yellow
    Update-Module -Name $ModuleName -Force

    #uninstall all old versions
    Uninstall-OldPowerShellWSTTModules

    Write-Host "Removing $ModuleName module." -ForegroundColor Yellow
    Remove-Module -Name $ModuleName -Force
    Write-Host "Reimporting $ModuleName module." -ForegroundColor Yellow
    Import-Module -Name $ModuleName -Force -Verbose
    $serverModuleVer = Find-Module -Name $ModuleName
    $localModuleVer = Get-Module -Name $ModuleName
    Write-Host "Server version is: $($serverModuleVer.Version) and Local Version is: $($localModuleVer.Version)" -ForegroundColor Yellow
    Write-Host "Please restart your Powershell session to reload the cmdlet dll properly." -ForegroundColor White -BackgroundColor Red
} # End Update-PowerShellWSTTModule