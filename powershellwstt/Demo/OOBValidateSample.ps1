#Play List
cd..
cd bin
cd debug
Import-Module .\PowershellWSTT.dll -Verbose

#user parms
$UserInputCred = Get-Credential -Message "Endpoint Authorized User" -UserName "matt_m@qa.edn"
$UserInputServerName = "jx15padapter.idg.jha-sys.com"
$UserInputOOBValidateRqXmlPath = Resolve-Path .\Demo\OOBValidateSampleXML.txt
$UserInputLOADERSHEET = Resolve-Path '.\Demo\OOB Load List.xlsx'

#bring in sample xml and load it into memory
$testRequest = Get-XmlOperation -Path $UserInputOOBValidateRqXmlPath.Path -CleanXml

#set connection
$connection = New-ServiceConnection -UserName $UserInputCred.UserName -Password $UserInputCred.Password -ServerName "jx15padapter.idg.jha-sys.com" #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

#import FI data
$data = Import-Excel -Path $UserInputLOADERSHEET.Path

#single test before mass
if($false)
{
    $rec = $data[0]
    $testRequest.OOBValidate.InstRtId = $rec.aba
    $testRequest.OOBValidate.MsgRqHdr.jXchangeHdr.InstRtId = $rec.aba
    $testRequest.OOBValidate.MsgRqHdr.jXchangeHdr.InstEnv = $rec.Environment
    $testRequest.OOBValidate.SMSText = "$($rec.Name) - Sending $counter"
    $response = Send-XmlOperation -XmlRequest $testRequest -ServiceConnection $connection -Verbose
}

$results = @()
$counter = 0
$resultErrors = @()
foreach ($rec in $data)
{
    $counter++
    $testRequest.OOBValidate.InstRtId = $rec.aba
    $testRequest.OOBValidate.MsgRqHdr.jXchangeHdr.InstRtId = $rec.aba
    $testRequest.OOBValidate.MsgRqHdr.jXchangeHdr.InstEnv = $rec.Environment
    $testRequest.OOBValidate.SMSText = "$($rec.Name) - Sending $counter"
    $response = Send-XmlOperation -XmlRequest $testRequest -ServiceConnection $connection -Verbose
    $results += $response
    
    if($response.HeaderStatusCode -ne "200"){
        $resultErrors += $response
        Write-Warning -Message "$($testRequest.FirstChild.Name) received error '$($response.HeaderStatusCodeDescription)' for institution $($rec.aba)/$($rec.Environment)"
    }
    
    Write-Host "Sent $counter XML(s) for $($rec.aba)/$($rec.Environment)"
}

$results.Count
$resultErrors.Count
$results
$resultErrors
