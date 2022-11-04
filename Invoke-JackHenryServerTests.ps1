Function Test-InternetConnection {
[cmdletbinding(
    DefaultParameterSetName = 'Site'
)]
param(
    [Parameter(
        Mandatory = $True,
        ParameterSetName = '',
        ValueFromPipeline = $True)]
        [string]$Site,
    [Parameter(
        Mandatory = $True,
        ParameterSetName = '',
        ValueFromPipeline = $False)]
        [Int]$Wait
    )
    #Clear the screen
    Clear
    #Start testing the connection and continue until the connection is good.
    While (!(Test-Connection -computer $site -count 1 -quiet)) {
        Write-Host -ForegroundColor Red -NoNewline "Connection down..."
        Start-Sleep -Seconds $wait
        }
    #Connection is good
    Write-Host -ForegroundColor Green "$(Get-Date): Connection up!"
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Continue"

Write-Host "Please enter the EWF application farm URL" -ForegroundColor Yellow 
$ewfFarm = Read-Host

Write-host "`nChecking DNS for $ewfFarm"
Try {
    $dns = (Resolve-DnsName $ewfFarm -DnsOnly -ErrorAction Stop).Ipaddress -join ', '
    if ($dns){
        $ewfFarmTest = $dns
        Write-Host "Success!" -ForegroundColor Green
    }
    else {
    $ewfFarmTest = $dns
    Write-Host "There was an issue verifying DNS records for $ewfFarm" 
    }
}
Catch {
    Write-Host "There was an issue verifying DNS records for $ewfFarm"
    if($_.ErrorDetails.Message) {
        $ewfFarmTest = $_.ErrorDetails.Message
    } else {
        $ewfFarmTest = $_
    }
}
Start-Sleep -Seconds 1

Write-Host "`nTesting connection to required websites" -ForegroundColor Yellow
Start-Sleep -Seconds 1
Write-Host "Checking jhadownloads.JackHenry.com"
Try {
    $response = (Invoke-WebRequest "https://jhadownloads.jackhenry.com").StatusCode
    if ($response -like "200"){
        $jackhenryTest = "Successful"
        Write-Host "Success!" -ForegroundColor Green
    }
    else {
    $jackhenryTest = $response
    }
}
Catch {
    Write-Host "There was an issue verifying this URL"
    if($_.ErrorDetails.Message) {
        $jackhenryTest = $_.ErrorDetails.Message
    } else {
        $jackhenryTest = $_
    }
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1
Write-Host "Checking secure.JHAHosted.com"
Try {
    $response = (Invoke-WebRequest "https://secure.jhahosted.com").StatusCode
    if ($response -like "200"){
        $jhahostedTest = "Successful"
        Write-Host "Success!" -ForegroundColor Green
    }
    else {
    $jhahostedTest = $response
    }
}
Catch {
    Write-Host "There was an issue verifying this URL"
    if($_.ErrorDetails.Message) {
        $jhahostedTest = $_.ErrorDetails.Message
    } else {
        $jhahostedTest = $_
    }
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1
Write-Host "Checking go.Microsoft.com"
Try {
    $response = (Invoke-WebRequest "https://go.Microsoft.com").StatusCode
    if ($response -like "200"){
        $MicrosoftTest = "Successful"
        Write-Host "Success!" -ForegroundColor Green
    }
    else {
    $MicrosoftTest = $response
    }
}
Catch {
    Write-Host "There was an issue verifying this URL"
    if($_.ErrorDetails.Message) {
        $MicrosoftTest = $_.ErrorDetails.Message
    } else {
        $MicrosoftTest = $_
    }
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1
Write-Host "Checking api.Github.com"
Try {
    $response = (Invoke-WebRequest "https://api.Github.com").StatusCode
    if ($response -like "200"){
        $GithubTest = "Successful"
        Write-Host "Success!" -ForegroundColor Green
    }
    else {
    $GithubTest = $response
    }
}
Catch {
    Write-Host "There was an issue verifying this URL"
    if($_.ErrorDetails.Message) {
        $GithubTest = $_.ErrorDetails.Message
    } else {
        $GithubTest = $_
    }
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1

Write-Host "`nChecking if .NET 4.8 is installed"
Try {
    $dotNetInstalled = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 528040
    Write-Host "Confirmed!" -ForegroundColor Green
}
Catch{
    $dotNetInstalled = ".NET Version Unavailable"
    Write-Host "There was an issue verifying this application"
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1


#Getting full list of installed software
$installedSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
$installedList = foreach($obj in $InstalledSoftware){$obj.GetValue('DisplayName') + " - " + $obj.GetValue('DisplayVersion')}

Write-Host "`nChecking if XCA is installed"
Try {
    $xcaInstalled = $installedList | Where-Object {$_ -like "*xperience*"}
    if (!$xcaInstalled){$xcaInstalled = "Not Installed"}
    Write-Host "Confirmed!" -ForegroundColor Green
}
Catch{
    $xcaInstalled = "XCA Version Unavailable"
    Write-Host "There was an issue verifying this application"
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1

Write-Host "Checking if Support Account is a member of the local administrators group"
Try {
    $members = ((Get-LocalGroupMember -Group Administrators) |  Where-Object {($_.name -like "*jxsupport*" -or  $_.name -like "*eissupport*") }).name -join ', '
    if (!$members){
        $members = "Not Present"
        Write-Host "Accounts Not Found"
        }
    if ($members){
        Write-Host "Success!" -ForegroundColor Green
        }
    
}
Catch{
    $members = "Error"
        Write-Host "Error verifying group membership"
        Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1

$testResults = New-Object -TypeName PSObject -Property ([ordered]@{
    'JackHenry.com' = $jackhenryTest
    'JHAHosted.com' = $jhahostedTest
    'Microsoft.com' = $MicrosoftTest
    'Github.com' = $GithubTest
    '.NET 4.8 Installed' = $dotNetInstalled
    'XCA Installed' = $xcaInstalled
    'EWF URL' = $ewfFarm
    'EWF DNS Records' = $ewfFarmTest
    'Support Accounts as Admin' = $members
    'Server Hostname' = $env:COMPUTERNAME
})

Write-Host "`nPlease screenshot or copy the results below to jhaenterpriseworkflowimplementation@jackhenry.com" -BackgroundColor Yellow -ForegroundColor Black
Write-Host "If you have multiple EWF application servers, please repeat this process on those additional servers"

Start-Sleep -Seconds 2

#outputting the log to a csv file
$outputDir = "C:\EWFTests"
Write-Host "`nAttempting to output a log file to $outputDir"
if (-not (Test-Path -LiteralPath $outputDir)) {
    Write-Host "Folder does not exist"
    try {
        New-Item -Path $outputDir -ItemType Directory -ErrorAction Stop | Out-Null #-Force
        Write-Host "folder Created"
    }
    catch {
        Write-Error -Message "Unable to create directory '$outputDir'. Error was: $_" -ErrorAction Stop
    }
}
if (Test-Path -LiteralPath $outputDir) {
    try {
        $filename = "$outputDir\Resulst_$(Get-Date -UFormat '%Y%m%d-%H%M%S')_EWF_appserver.$env:COMPUTERNAME.csv" 
        $testResults | Export-Csv -LiteralPath $filename -NoTypeInformation
        Write-Host "Log created in $outputDir"
        Write-Host "$filename"
    }
    catch {
        Write-Error -Message "Unable to create log file $filename"  -ErrorAction Continue
        Start-Sleep -Seconds 1
    }
}
Start-Sleep -Seconds 1
return $testResults
