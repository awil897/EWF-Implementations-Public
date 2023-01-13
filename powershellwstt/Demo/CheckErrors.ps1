cd..
cd bin
cd debug

Import-Module .\PowershellWSTT.dll -Verbose

$testRequest = Get-XmlOperation -CleanXml

$testRequest = Get-XmlOperation -Path .\PingSampleXML.txt -CleanXml
$response = Send-XmlOperation -XmlRequest null -ServiceConnection null -Verbose
$response = Send-XmlOperation -XmlRequest $testRequest -ServiceConnection null -Verbose


$password = ConvertTo-SecureString -String "junk" -AsPlainText -Force
$connection = New-ServiceConnection -UserName "matt_m@qa.edn" -Password null -ServerName "jx15padapter.idg.jha-sys.com" #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"
$connection = New-ServiceConnection -UserName null -Password $password -ServerName "jx15padapter.idg.jha-sys.com" #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"
$connection = New-ServiceConnection -UserName "matt_m@qa.edn" -Password $password #check warning
$connection = New-ServiceConnection -UserName "matt_m@qa.edn" -Password $password -EndpointKind EnterpriseLogging #check warning
$connection = New-ServiceConnection -UserName "matt_m@qa.edn" -Password $password -EndpointKind Broadcastevent #check warning
$connection = New-ServiceConnection -UserName "matt_m@qa.edn" -Password $password -EndpointKind EnterpriseAudit #check warning
$connection = New-ServiceConnection -UserName "matt_m@qa.edn" -Password $password -EndpointKind IdentityManagement #check warning
$connection = New-ServiceConnection -UserName "matt_m@qa.edn" -Password $password -EndpointKind PersistentStorage #check warning
$connection = New-ServiceConnection -UserName "matt_m@qa.edn" -Password $password -EndpointKind ServiceGateway #check warning

$password = ConvertTo-SecureString -String "junk" -AsPlainText -Force
$connection = New-ServiceConnection -UserName "bob@bob.com" -Password $password -ServerName "really bad servername" #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"


