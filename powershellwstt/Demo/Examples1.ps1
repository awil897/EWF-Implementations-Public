cd..
cd bin
cd debug

Register-PSRepository -Name EisArtifactory -SourceLocation https://artifactory.jkhy.com/api/nuget/techserv-eis-powershellget -InstallationPolicy Trusted
#Import-Module .\PowershellWSTT.dll -Verbose #eg of old import
install-module -Name PowerShellWSTT -Repository EisArtifactory
#update-module -Name PowerShellWSTT -Force #eg for update
Import-Module PowerShellWSTT
(Get-Module -ListAvailable PowerShellWSTT*).path #is it installed?

get-help Send-XmlOperation -Full
get-help New-ServiceConnection -Full
get-help Get-XmlOperation -Full

#[Xml]$testRequest = Get-Content -Path .\Demo\PingSampleXML.txt
$testRequest = Get-XmlOperation -Path .\PingSampleXML.txt -CleanXml

$cred = Get-Credential -Message "Provide credentials for the service connection." -UserName "matt_m@qa.edn"
$connection = New-ServiceConnection -UserName $cred.UserName -Password $cred.Password -ServerName "jx15padapter.idg.jha-sys.com" #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

$data = Import-Excel -Path '.\Demo\OOB Load List.xlsx'

if($false)
{
    $rec = $data[0]
    $testRequest.Ping.PingRq = "$($rec.aba) - $($rec.Environment) - $($rec.Name) - UserTest$($counter)"
    $response = Send-XmlOperation -XmlRequest $testRequest -ServiceConnection $connection -Verbose
}

$results = @()
$counter = 0
$resultErrors = @()
foreach ($rec in $data)
{
    $counter++
    $testRequest.Ping.PingRq = "$($rec.aba) - $($rec.Environment) - $($rec.Name) - UserTest$($counter)"
    $response = Send-XmlOperation -XmlRequest $testRequest -ServiceConnection $connection -Verbose
    $results += $response

    #simulate an error bucket catcher
    if($counter % 2 -eq 0)
    {
        $response.HeaderStatusCode = "404" #simulate error 404 https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
        $response.HeaderStatusCodeDescription = "Not Found"
    }

    if($response.HeaderStatusCode -ne '200'){
        $resultErrors += $response
        Write-Warning -Message "$($testRequest.FirstChild.Name) received error '$($response.HeaderStatusCodeDescription)' for institution $($rec.aba)/$($rec.Environment)"
    }

    Write-Host "Sent $counter XML(s) for $($rec.aba)/$($rec.Environment)"
}

$results.Count
$resultErrors.Count
$results[0]
$resultErrors[0]


#test tls 1.2
if($false)
{
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
    cd..
    cd bin
    cd debug
    Import-Module .\PowerShellWSTT.dll
    $pass = ConvertTo-SecureString -String "nG51Sq3fF" -AsPlainText -Force
    $connection = New-ServiceConnection -UserName "jDestination@jxtest.local" -Password $pass -ServerName "jxtest.jackhenry.com" #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"
    $testRequest = Get-XmlOperation -Path .\PingSampleXML.txt -CleanXml
    $testRequest.Ping.PingRq = "123456 - PROD - MONETT - UserTest1"
    $response = Send-XmlOperation -XmlRequest $testRequest -ServiceConnection $connection -Verbose
}

#test tls 1
{
    cd..
    cd bin
    cd debug
    Import-Module .\PowerShellWSTT.dll
    #$pass = ConvertTo-SecureString -String "????" -AsPlainText -Force
    $connection = New-ServiceConnection -UserName "matt_m@qa.edn" -Password $pass -ServerName "jx15padapter.idg.jha-sys.com" #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"
    $testRequest = Get-XmlOperation -Path .\PingSampleXML.txt -CleanXml
    $testRequest.Ping.PingRq = "123456 - PROD - MONETT - UserTest1"
    $response = Send-XmlOperation -XmlRequest $testRequest -ServiceConnection $connection -Verbose
    $response
}