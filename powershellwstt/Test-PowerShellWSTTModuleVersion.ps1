function Get-ScriptDirectory
{
$Invocation = (Get-Variable MyInvocation -Scope 1).Value
Split-Path $Invocation.MyCommand.Path
}

. "$(Get-ScriptDirectory)\Update-PowerShellWSTTModule.ps1"

#Write-Host "Getting installed modules" -ForegroundColor Yellow
$modules = Get-Module -ListAvailable PowerShellWSTT*

#Write-Host "Comparing to online versions" -ForegroundColor Yellow
foreach ($module in $modules) {

     #find the current version in the gallery
     Try {
        $online = Find-Module -Name $module.name -Repository EisArtifactory -ErrorAction Stop
     }
     Catch {
        Write-Warning "Module $($module.name) was not found in the EisArtifactory"
     }

     #compare versions
     if ($online.version -gt $module.version) {
        $UpdateAvailable = $True
     }
     else {
        $UpdateAvailable = $False
     }

     if($UpdateAvailable -eq $True)
     {
        Write-Warning "There is a new version of the PowerShellWSTT available, to update use the below command. Current Version is $($module.version). New Version is $($online.version)."
        Write-Warning "PS> Update-PowerShellWSTTModule"
     }
} #foreach
