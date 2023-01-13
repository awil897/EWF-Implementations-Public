[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Continue"

#download modules
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

Write-Host "`nChecking for certificate issues" -ForegroundColor Yellow
#wrap these if if/else/try/catch
Try {
    
    Write-Host "`nGetting Certificate bound to port 443"
    $sslCertObject = (Get-SslCertificateBinding -port 443)
    $cert = Get-CCertificate -Thumbprint $sslCertObject.CertificateHash -StoreName $sslcertobject.CertificateStoreName -StoreLocation LocalMachine -NoWarn
    $certname = ($cert.DnsNameList.unicode).tolower()
    Write-Host "Success!" -ForegroundColor Green
    Write-Host "Certificate Found for "$($certname)""
    $hostFQDN = (([System.Net.Dns]::GetHostByName($env:computerName)).hostname).tolower()
    
    If ($certname -match $hostFQDN){
        Write-Host "The CN on the Certificate matches the FQDN of this server" -ForegroundColor Green
    }
    Else {
        Write-Host "The CN on the Certificate does not match the Hostname of this server. `nVerify that the certificate bound to port 443 should be named $($certname)" -ForegroundColor Yellow
    }
}
Catch {
    Write-Host "I'm having trouble verify the certificates automatically, you will need to check these manually" -ForegroundColor Yellow
}

Try {
    $sslCertObject = (Get-SslCertificateBinding -port 443)
    $cert = Get-CCertificate -Thumbprint $sslCertObject.CertificateHash -StoreName $sslcertobject.CertificateStoreName -StoreLocation LocalMachine -NoWarn
    $certname = ($cert.DnsNameList.unicode).tolower()
    $dnsQuery = Resolve-DnsName -Name $certname -DnsOnly -NoHostsFile
    Write-Host "DNS Exists" -ForegroundColor Green
}
Catch{
    Write-Host "DNS Bad" -ForegroundColor Red
}

Try {
    [Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    $url = "https://" + $certname
    $req = [Net.HttpWebRequest]::Create($url)
    $req.GetResponse() | Out-Null
    $certStart = [DateTime]($req.ServicePoint.Certificate.GetEffectiveDateString()).toString()
    $certEnd = [DateTime]($req.ServicePoint.Certificate.GetExpirationDateString()).toString()
    $Now = Get-Date 
    if (($certStart -lt $now) -and ($certEnd -gt $now)){
        Write-Host "The SSL Certificate bound to port 443 dates are valid" -ForegroundColor Green
    }
    if ($certStart -gt $now){
        Write-Host "The SSL Certificate bound to port 443 is not valid until $certStart" -ForegroundColor Yellow
    }
    if ($certEnd -lt $now){
        $expiredDays = (New-TimeSpan -Start $certEnd -End $Now).Days
        Write-Host "The SSL Certificate bound to port 443 expired $expiredDays ago on $certEnd" -ForegroundColor Red
    }
}
Catch {
    
}


#test web access
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
$testResults

Start-Sleep -Seconds 1
Write-Host "Loading Test UI"
Invoke-Expression (Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/awil897/EWF-Implementations-Public/main/ServerTests/Invoke-SynNodeUITests.ps1')

Read-Host -Prompt “Press Enter to exit”