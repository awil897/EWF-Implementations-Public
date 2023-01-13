[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Continue"

if (Get-Module -ListAvailable -Name Carbon) {
    Write-Host "Carbon Module already installed"
    Import-Module carbon
} 
else {
    try {
        Write-Host "Downloading Carbon PowerShell module"
        Invoke-Expression ('$module="carbon";$user="awil897";$branch="main";$repo="EWF-Implementations-Public"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/awil897/EWF-Implementations-Public/main/download-EWFModules.ps1'))
        Import-Module carbon
    }
    catch [Exception] {
        $_.message 
        exit
    }
}



Write-Host "`nTesting connection to required websites" -ForegroundColor Yellow
Start-Sleep -Seconds 1
Write-Host "Checking jhadownloads.JackHenry.com"
Try {
    $response = (Invoke-WebRequest "https://jhadownloads.jackhenry.com" -UseBasicParsing).StatusCode
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
    $response = (Invoke-WebRequest "https://secure.jhahosted.com" -UseBasicParsing).StatusCode
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


Write-Host "`nChecking if Webex Remote Access is installed"
Try {
    $HNA = (Get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\WebEx\Config\RA\General -Name "HNA" -ErrorAction SilentlyContinue).HNA 
    If ($HNA -like $null){
        $HNA = "Not Installed"
        Write-Host "Successfully Checked" -ForegroundColor Green
    }
}
Catch {
    $HNA = "Error querying the Registry"
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1

$testResults = New-Object -TypeName PSObject -Property ([ordered]@{
    'JackHenry.com' = $jackhenryTest
    'JHAHosted.com' = $jhahostedTest
    'Server Hostname' = $env:COMPUTERNAME
    'SmartTech Entry Name' = $HNA
})

Write-Host "`nPlease screenshot or copy the results below and email to INeedASynergyEmail@jackhenry.com" -BackgroundColor Yellow -ForegroundColor Black
Write-Host "If you have multiple SynNode application servers, please repeat this process on those additional servers"

Start-Sleep -Seconds 2

#outputting the log to a csv file
$outputDir = "C:\SynergyTests"
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
        $filename = "$outputDir\Results_$(Get-Date -UFormat '%Y%m%d_%H%M%S')_EWF_appserver.$env:COMPUTERNAME.csv" 
        $testResults | Export-Csv -LiteralPath $filename -NoTypeInformation
        Write-Host "Log created"
        Write-Host "$filename"
    }
    catch {
        Write-Error -Message "Unable to create log file $filename"  -ErrorAction Continue
        Start-Sleep -Seconds 1
    }
}
Start-Sleep -Seconds 1

Write-Host "Loading Test UI"
Invoke-Expression (Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/awil897/EWF-Implementations-Public/main/ServerTests/Invoke-SynNodeUITests.ps1')


$testResults

Read-Host -Prompt “Press Enter to exit”