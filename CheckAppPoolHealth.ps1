###Edit this drive and location to change where the log file is saved
$path = "C:\Logs"

###Add any app pool names to this array to exclude them from being checked. 
###Any app pool that does not publish its svc endpoints in its web.config file need to be excluded
$dontCheck = @("DefaultAppPool","Infrastructure",".NET v4.5 Classic",".NET v4.5","Classic .NET AppPool",".NET v2.0 Classic",".NET v2.0","RemoteApproval","WcfRoutingService","WCFRoutingServiceProd","ReconService","IrisImageApplication","IrisImageSystem")

###Do not edit below this line
###Checking if required modules exist, and trying to auto-install if not
if (Get-Module -ListAvailable -Name Carbon) {
    Write-Host "Carbon module installed. Importing..."
    Import-Module Carbon
} 
else {
    Write-Host "Carbon module does not exist"
    Write-Host "Trying to install"

    Try {
        Install-Module Carbon -Confirm:$False -Force
    }
    Catch {
        Write-Host "Carbon module could not be installed but is required."
        Write-Host "Please install Carbon from PSGallery manually"
        Read-Host -Prompt "Press Enter to exit"
        exit
    }
}
Import-Module WebAdministration

#Creating Log file
If(!(test-path -PathType container $path))
{
      New-Item -ItemType Directory -Path $path
}
$filename = (get-date -f yyyyMMdd-HHmmss) + ".txt"
$log = New-Item "$path\$filename"

###Attempting to prevent expired certificate from stopping app pool checks. We also check the app pools on the local http port and need to avoid errors
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$code= @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
Add-Type -TypeDefinition $code -Language CSharp
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

###Retrieving all svc endpoints from EWF
Write-Host "Submitting Job to check all Workflow SVC endpoints"
$appPools = (Get-CIISAppPool -NoWarn).name | Where-Object {($_ -like "WSP*" -or $_ -eq "WorkflowSystem") -and $_ -notin $dontCheck}
$siteInfo = Get-CIISWebSite "Default Web Site" -NoWarn

#Get status of each app pool
$allstatus = foreach ($appPool in $appPools) {
    $pool = Get-CIISAppPool -Name $appPool -NoWarn
    $state = (Get-WebAppPoolState -Name $appPool).Value
    $results = @()
    $counter = 0
    $resultErrors = 0
    $exitCondition = "No"
    ###if stopped, attempt to restart app pool first
    if ($state -like "Stopped"){
        try{
            Write-Host "$appPool appears to be down and we will attempt to start it. If you get this error multiple times, $appPool could not be restarted automatically."
            Add-Content $log -Value "$appPool appears to be down and we will attempt to start it. If you get this error multiple times, $appPool could not be restarted automatically."
            Start-WebAppPool -Name $apppool
            Start-Sleep -Seconds 5
            Write-Host "Pausing for 15 seconds to let App Pool start up completely"
            Add-Content $log -Value "Pausing for 30 seconds to let App Pool start up completely"
            $state = (Get-WebAppPoolState -Name $appPool).Value
            if ($state -like "Started"){
                $exitCondition = "No"
                Write-Host "$appPool is now online"
                Add-Content $log -Value "$appPool is now online"
            }
        }
        catch{
            Write-Host "I'm having trouble starting $appPool"
            Add-Content $log -Value "I'm having trouble starting $appPool"
            $exitCondition = "Yes" 
        }
    }
    ##if started, checking each available svc endpoint on each app pool
    if ($state -like "Started"){
        Write-Host "Checking $appPool Application Pool"
        Add-Content $log -Value "Checking $appPool Application Pool"
        [string]$sitePath = (($siteInfo.Applications | Where-Object {$_.ApplicationPoolName -like $appPool}).path) | Where-Object {$_ -like "*JHAWF*"}
        $wspconfig = Get-WebApplication $sitePath 
        $wspconfigfile = $wspconfig.physicalpath + "\web.config"
        $wspwebConfigFile = [xml](Get-Content $wspconfigfile)
        $serviceEndpoints = $wspwebConfigFile.configuration.'system.serviceModel'.serviceHostingEnvironment.serviceActivations.add.relativeAddress | where {$_ -NotLike "~/PresentationMetadata.svc"}
        $serviceEndpoints = $serviceEndpoints -replace "~/",""
        $serviceEndpoints = $serviceEndpoints | Where-Object {$_ -notlike "*ClientXhsHostedDeployment*"}
        $resultErrors = 0
        $output = foreach ($endpoint in $serviceEndpoints){
            $counter++
            try {
                $domain = (Get-CimInstance Win32_ComputerSystem).Domain
                [string]$fullURI = "http://jhawf" + $sitePath + "/" + "$endpoint"
                [string]$localURI = "https://" + $env:COMPUTERNAME + "." + $domain + $sitePath + "/" + "$endpoint"
                $response = Invoke-WebRequest -Uri "$fullURI" -UseBasicParsing
                $results += $response
                
                if($response.StatusCode -ne "200"){
                    $resultErrors++
                    $psobj = [pscustomobject]@{
                        ServerName = $localURI
                        Result = $response.StatusCode
                        Description = "Error"
                    }
                    $psobj
                    }
                else {
                    #$resultErrors++
                    $psobj = [pscustomobject]@{
                        ServerName = $localURI
                        Result = $response.StatusCode
                        Description = $response.StatusDescription
                    }
                    $psobj
                }
            }
            catch {
                $resultErrors++      
                Write-Host "$endpoint is down" 
                Add-Content $log -Value "$endpoint is down" 
                Write-Host $PSItem.Exception.Message -ForegroundColor RED 
            }
        }
        $output | ForEach-Object {
            Write-Host "$($_.ServerName) $($_.Result) $($_.Description)"
            Add-Content $log -Value "$($_.ServerName) $($_.Result) $($_.Description)"
        }
    }
    ###If app pool was either already started, or successfully restarted
    if($exitCondition -like "No"){
        $resultsHash = @{
            Total_Tests = $counter
            Errors = $resultErrors
        }
        if($resultsHash.errors -gt 0 ){
            Write-Host "$($resultsHash.Total_Tests) Endpoints Tested"
            Add-Content $log -Value "$($resultsHash.Total_Tests) Endpoints Tested"
            Write-Host "$($resultsHash.Errors) Errors"
            Add-Content $log -Value "$($resultsHash.Errors) Errors"
            Write-Host "$appPool is Unhealthy and will be recycled"  
            Add-Content $log -Value "$appPool is Unhealthy and will be recycled" 
            $pool = Get-CIISAppPool -Name $appPool -NoWarn
            try {
                $pool.Recycle()
                Write-Host "$appPool recycled"  
                Add-Content $log -Value "$appPool recycled`n" 
                Add-Content $log -Value ""
            }
            catch{
                Write-Host "$appPool could not be Recycled`n"
                Add-Content $log -Value "$appPool could not be Recycled"
                Add-Content $log -Value ""
            }
        }
        else{
            Write-Host "$($resultsHash.Total_Tests) Endpoints Tested"
            Add-Content $log -Value "$($resultsHash.Total_Tests) Endpoints Tested"
            Write-Host "$($resultsHash.Errors) Errors"
            Add-Content $log -Value "$($resultsHash.Errors) Errors"
            Write-Host "$appPool is Healthy`n"
            Add-Content $log -Value "$appPool is Healthy"
            Add-Content $log -Value ""
        }   
    }
    ###If app pool was offline, and could not be restarted automatically
    if($exitCondition -like "Yes"){
        Write-Host "Something is wrong with $appPool and it cannot be recovered automatically`n" 
        Add-Content $log -Value "Something is wrong with $appPool and it cannot be recovered automatically"
        Add-Content $log -Value ""
    }
}