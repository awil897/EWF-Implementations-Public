Import-Module PowerShellJMC -Verbose

if($false) #for use in visual studio environment and QA
{
	Set-Location ./bin/debug
    Import-Module .\PowerShellJMC.dll -Verbose
    $cred = Get-Credential -UserName "matt_m@qa.edn" -Message "Enter an account to access the jXChange Server:"
	$connection = New-JMCConnection -JMCServerName jx15padapter.idg.jha-sys.com -JMCUserName $cred.UserName -JMCPassword $cred.Password #if no connection, it defaults to localhost
    $PSDefaultParameterValues = @{‘Add-SGInstitution:JMCConnection’=$connection; ‘New-SGProviderSilverlake:JMCConnection’=$connection; ‘Add-SGProvider:JMCConnection’=$connection; ‘Add-SGUser:JMCConnection’=$connection; ‘New-SGProviderCIF2020:JMCConnection’=$connection; ‘Add-SGHostedProviderUser:JMCConnection’=$connection; 'Get-SGInstitution:JMCConnection'=$connection; 'New-SGProviderPadapterWebService:JMCConnection'=$connection ; 'Remove-SGProvider:JMCConnection'=$connection; 'Add-IMSCustomClaim:JMCConnection'=$connection ; 'Export-SGInstitution:JMCConnection'=$connection; 'Get-SGProvider:JMCConnection'=$connection }

	#add institution only
	Add-SGInstitution -Name Matthew -Environment PROD -ABA 123456788 -Description "myTestBank For Banno" -City Monett -State MO -Country US
}

#only helpful to the developers
if($false) #used in troubleshooting the app.config file
{
    if($false) #can use this line to start debug at any time
    {
	    [PowerShellJMC.Common.DebugHelper]::AttachDebugger()
    }

	[System.IO.Directory]::SetCurrentDirectory($ScriptDir)
	[Reflection.Assembly]::LoadFrom($Module)
	[appdomain]::CurrentDomain.SetData("APP_CONFIG_FILE", "$scriptdir\$Module.config")
	[appdomain]::CurrentDomain.GetData("APP_CONFIG_FILE")
	Add-Type -AssemblyName System.Configuration
	[Configuration.ConfigurationManager].GetField("s_initState", "NonPublic, Static").SetValue($null, 0)
	[Configuration.ConfigurationManager].GetField("s_configSystem", "NonPublic, Static").SetValue($null, $null)
	([Configuration.ConfigurationManager].Assembly.GetTypes() | Where-Object {$_.FullName -eq "System.Configuration.ClientConfigPaths"})[0].GetField("s_current", "NonPublic, Static").SetValue($null, $null)
	[Configuration.ConfigurationManager]::ConnectionStrings[0].Name
	[Configuration.ConfigurationManager]::ConnectionStrings['Name']

    update-module -Name PowerShellJMC -Repository EisArtifactory -Force
}

#Test Add-IMSCustomClaim
if($false)
{
    Get-Help Add-IMSCustomClaim -ShowWindow

    Add-IMSCustomClaim -UserName "matt_m@qa.edn" -Type Role -Value "Bob"
    Add-IMSCustomClaim -UserName "matt_m@qa.edn" -Type OrganizationType -Value "Jack Henry"
    Add-IMSCustomClaim -UserName "matt_m@qa.edn" -Type ValidatedConsumerName -Value "Bob"
    Add-IMSCustomClaim -UserName "matt_m@qa.edn" -Type ValidatedConsumerProduct -Value "Bob"
    Add-IMSCustomClaim -Type OrganizationType -Value "Jack Henry"
}

#Test Add-SGHostedProviderUser
if($false)
{
    Get-Help Add-SGHostedProviderUser -ShowWindow

    Add-SGHostedProviderUser -UserName matt_m@qa.edn -ProviderTypeName iPay
    Import-Excel -Path C:\temp\BulkInstall.xlsx -WorksheetName 'iPayBillPay' | Add-SGHostedProviderUser -ProviderTypeName iPay -Operations ACHFileAdd, ACHFileInq -OperationGroups Customer | Export-Csv c:\temp\reportDemoForNelson.csv

}

#Test Add-SGInstitution
if($false)
{
    Get-Help Add-SGInstitution -ShowWindow

    Add-SGInstitution -Name Matthew -Environment PROD -ABA 123456788 -Description "myTestBank" -City Monett -State MO -Country US

    #Bulk Import Process
	$banks = Import-Excel -Path .\NewInstitutionsFilesTesting.xlsx #| Out-GridView -PassThru
	$report = $banks | Add-SGInstitution -Verbose
    $report | Export-Csv .\exportedUserReport.csv
}

#Test Add-SGProvider
if($false)
{
    Get-Help Add-SGProvider -ShowWindow

	$banks = Import-Excel -Path .\NewInstitutionsFilesTesting.xlsx
	$silverlake = New-SGProviderSilverlake -ProviderName SilverLakeName -ProviderDescription SilverLakeDesc -ProviderHostName 10.1.1.1 -ProviderPort 40001 -ProviderSecurityKey bob -ProviderInstitutionId 20
	$banks | Add-SGProvider -Provider $silverlake -Verbose

	#use in pipeline
	$reportedBanks = $banks | New-SGProviderSilverlake
	$reportedBanks | Add-SGProvider -Verbose
	$reportedBanks[0] | Add-SGProvider -Verbose #try a single
}

#Test Add-SGUSer
if($false)
{
    Get-Help Add-SGUser -ShowWindow

    #single
    Add-SGUSer -ABA 123456788 -Environment PROD -UserName "matt_m@qa.edn" -Operations MFAOOBValidate, MFAQnAPolInq, Ping -verbose

    #be sure to put blank columns in for the Operations and OperationGroup if you want all groups or the powershell mapper will have trouble
	$institutions = Import-Excel -Path .\NewInstitutionsFilesTesting.xlsx
	$institutions | Out-GridView -PassThru | Add-SGUSer -UserName "matt_m@qa.edn" -Operations MFAOOBValidate, MFAQnAPolInq, Ping -Verbose
	$institutions | Add-SGUSer -UserName "matt_m@qa.edn" -Operations MFAOOBValidate, MFAQnAPolInq, Ping -verbose

	#use powershell reporting, this one is weird because of the operations array
	$reportedUsers = $institutions | Add-SGUSer -UserName "matt_m@qa.edn" -Operations MFAOOBValidate, MFAQnAPolInq, Ping -Verbose
	$reportedUsers | Select-Object Name,ABA,Environment,UserName,Status,@{l="Operations";e={$_.Operations -join ", "}} | Export-Csv .\exportedUserReport.csv
	$reportFile = Import-Csv -Path .\exportedUserReport.csv
	$returnedObject = $reportFile[0] | Add-SGUser #can test the operations object to see if is still an array

    Import-Excel -Path C:\temp\exportedprovider.provider.xlsx | Add-SGUser -Verbose
}

#Test ConvertTo-Splat
if($false)
{
    Get-Help ConvertTo-Splat -ShowWindow

    $splatData = ConvertTo-Splat Add-SGInstitution
    $splatData.Name = "bob"
    $splatData.ABA = 123456788
    $splatData.Environment = "PROD"
    $splatData.Description = "Bob"
    $splatData.City = "city"
    $splatData.State = "MO"
    $splatData.Country = "US"
    $splatData
}

#Test Export-SGInstitution
if($false)
{
    Get-Help Export-SGInstitution -ShowWindow

	$institutions = Get-SGInstitution
	$institutions | Export-SGInstitution -Path "C:\temp\exported\" -Password jxchange
    Get-SGInstitution | Export-SGInstitution -password jxchange -path C:\temp\Exported

    Get-SGInstitution | Out-GridView -PassThru | Export-SGInstitution -Password myPassword -Path c:\temp\testFolderExport
}

#Test Get-Input
if($false)
{
    Get-Help Get-Input -ShowWindow
    $userName = Get-Input -Message "What is the username?" -Title "Username?"
}

#Test Get-SGInsitution
if($false)
{
    Get-Help Get-SGInstitution -ShowWindow
    Get-SGInstitution
    Get-SGInstitution -Name Matthew -Verbose
    Get-SGInstitution -Environment PROD -ABA 123456788 -Verbose
    Get-SGInstitution -ABA 123456788 -Verbose
    Get-SGInstitution -Name Matthew -Environment PROD -ABA 123456788 -Verbose
    $gotFI = Get-SGInstitution | Out-GridView -PassThru

    #Get FI by Provider Type
    Get-SGInstitution -FilterByProvider "pAdapter_Extension" -Verbose
    Get-SGInstitution -FilterByProvider "iTalk" -Verbose

    #test flavors of filtering
    Get-SGInstitution -ABA 123456788 -Environment PROD -FilterByProvider "pAdapter_Extension" -Verbose #returns fi not found
    Get-SGInstitution -ABA 123456788 -FilterByProvider "pAdapter_Extension" -Verbose #returns an FI

    Get-SGInstitution -Name pAdapter_V2_Extension -FilterByProvider "pAdapter_Extension" -Verbose #returns an FI
    Get-SGInstitution -Name IDoNotExist -ABA 788888888 -Environment IDNE -FilterByProvider "pAdapter_Extension" -Verbose #returns fi not found

    #Return FI if not found with status of .NotFound
    Get-SGInstitution -Name IDoNotExist -ABA 788888888 -Environment IDNE -Verbose
    Get-SGInstitution -Name IDoNotExist -Verbose
}

#Test Get-SGProvider
if($false)
{
    Get-Help Get-SGProvider -ShowWindow

    Get-SGProvider -ABA 123456 -Verbose
    Get-SGInstitution -Verbose | Get-SGProvider -Verbose
    Get-SGProvider -Name Matthew -Verbose
    Get-SGProvider -Environment PROD -ABA 123456788 -Verbose
    Get-SGProvider -ABA 123456788 -Verbose
    $item = Get-SGProvider -ABA 82900319 -Environment TEST -ProviderTypeName pAdapter_Extension -Verbose
    $item.Provider
    $item.Provider.GetType().Name
    $item.Provider.ProviderHostName
    $item.Provider.ProviderPort
    Get-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -Verbose
    $gotFI = Get-SGProvider | Out-GridView -PassThru

    #Get FI by Provider Type
    Get-SGProvider -ProviderTypeName "iTalk" -Verbose
}

#Test Import-SGInstitution
if($false)
{
    Get-Help Import-SGInstitution -ShowWindow
    Get-ChildItem C:\Temp\testFolderExport\* | Out-GridView -PassThru | Import-SGInstitution -Password myPassword
	$files = Get-ChildItem -Path C:\temp\Exported
	$files | Import-SGInstitution -Password jxchange -Verbose
}

#Test Import-SGMetadata
if($false)
{
    Get-Help Import-SGMetadata -ShowWindow
	Import-SGMetadata -Path .\metadata7.2.2.zip -ShowProgress -Verbose
}

#Test New-JMCConnection
if($false)
{
	Get-Help New-JMCConnection -ShowWindow
    #$cred = Get-Credential -UserName "$env:userdomain\$env:username" -Message "Enter an account to access the jXChange Server"
    $cred = Get-Credential -UserName "matt_m@qa.edn" -Message "Enter an account to access the jXChange Server"
	$timeSpan = New-TimeSpan -Hours 1 -Minutes 1 -Seconds 1
	$connection = New-JMCConnection -JMCServerName jx15padapter.idg.jha-sys.com -JMCUserName $cred.UserName -JMCPassword $cred.Password -CloseTimeout $timeSpan -OpenTimeout $timeSpan -ReceiveTimeout $timeSpan -SendTimeout $timeSpan
	$institutions = Get-SGInstitution -JMCConnection $connection
}

#Test New-SGProvider4Sight
if($false)
{
    Get-Help New-SGProvider4Sight -ShowWindow

    #Option 1 - send as parms - all endpoints - pass as parm
    $4Sight = New-SGProvider4Sight -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword -AllEndpointIssuer servername.com
	Add-SGProvider -Provider $4Sight -Name Matthew -Environment PROD -ABA 123456788 -Verbose

    #Option 2 send in pipeline - all endpoints - pass in pipe
	$4Sight = New-SGProvider4Sight -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword -AllEndpointIssuer servername.com
    $4Sight | Add-SGProvider -Verbose

    #create gets a csv copy of the object
    $4Sight.Provider | Export-Csv -Path .\exportedprovider.provider.csv

    #test InquiryEndpoint endpoint override
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderName 4Sight -Force
    New-SGProvider4Sight -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword -AllEndpointIssuer servername.com -InquiryEndpoint inqEndpoint.com -InquiryEndpointUserName inqUser@inqDomain.com -InquiryEndpointPassword inqPass -InquiryIssuer inqIssuer.com | Add-SGProvider
    #test ImageEndpoint endpoint override
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderName 4Sight -Force
    New-SGProvider4Sight -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword -AllEndpointIssuer servername.com -ImageEndpoint imgEndpoint.com -ImageEndpointUserName imgUser@inqDomain.com -ImageEndpointPassword inqPass -ImageIssuer imgIssuer.com | Add-SGProvider

    #cleanup
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderTypeName "4Sight" -Force
}

#Test New-SGProviderCIF2020
if($false)
{
    Get-Help New-SGProviderCIF2020 -ShowWindow

	#add cif2020 provider only
	$cif2020 = New-SGProviderCIF2020 -Name Matthew -Environment PROD -ABA 123456788 -ProviderHostName 10.1.1.1 -ProviderPort 40001 -ProviderSecurityKey bob -ProviderInstitutionId 20

    #Option 1 - send as parms
	Add-SGProvider -Provider $cif2020 -Name Matthew -Environment PROD -ABA 123456788 -Verbose

    #Option 2 send in pipeline
    $cif2020 | Add-SGProvider -Verbose

    #create gets a csv copy of the object
    $cif2020.Provider | Export-Csv -Path .\exportedprovider.provider.csv

    #cleanup
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderTypeName CIF2020 -Force
}

#Test New-SGProviderCoreDirector
if($false)
{
    Get-Help New-SGProviderCoreDirector -ShowWindow

    #Option 1 - send as parms - all endpoints - pass as parm
    $CoreDirector = New-SGProviderCoreDirector -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword -AllEndpointIssuer servername.com
	Add-SGProvider -Provider $CoreDirector -Name Matthew -Environment PROD -ABA 123456788 -Verbose

    #Option 2 send in pipeline - all endpoints - pass in pipe
	$CoreDirector = New-SGProviderCoreDirector -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword -AllEndpointIssuer servername.com
    $CoreDirector | Add-SGProvider -Verbose

    #create gets a csv copy of the object
    $CoreDirector.Provider | Export-Csv -Path C:\temp\exportedprovider.provider.csv

    #test cmdlet to cmdlet pipeline parm passing
    $CoreDirector = New-SGProviderCoreDirector -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword -AllEndpointIssuer servername.com
    Get-SGInstitution -Name Matthew | Add-SGProvider -Provider $CoreDirector -Verbose

    #cleanup
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderTypeName "Core Director" -Force
}

#Test New-SGProviderEnterpriseNotification
if($false)
{
    Get-Help New-SGProviderEnterpriseNotification -ShowWindow

    #Option 1 - send as parms - all endpoints - pass as parm
    $EnterpriseNotification = New-SGProviderEnterpriseNotification -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword -AllEndpointIssuer servername.com
	Add-SGProvider -Provider $EnterpriseNotification -Environment PROD -ABA 123456788 -Verbose

    #Option 2 send in pipeline - all endpoints - pass in pipe
	$EnterpriseNotification = New-SGProviderEnterpriseNotification -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword -AllEndpointIssuer servername.com
    $EnterpriseNotification | Add-SGProvider -Verbose

    #create gets a csv copy of the object
    $EnterpriseNotification.Provider | Export-Csv -Path .\exportedprovider.provider.csv

    #cleanup
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderTypeName "Enterprise Notification" -Force
}

#Test New-SGProviderEpisys
if($false)
{
    Get-Help New-SGProviderEpisys -ShowWindow

    #Option 1 - send as parms - all endpoints - pass as parm
    $Episys = New-SGProviderEpisys -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword
	Add-SGProvider -Provider $Episys -Name Matthew -Environment PROD -ABA 123456788 -Verbose

    #Option 2 send in pipeline - all endpoints - pass in pipe
	$Episys = New-SGProviderEpisys -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword -AllEndpointIssuer servername.com
    $Episys | Add-SGProvider -Verbose

    #create gets a csv copy of the object
    $Episys.Provider | Export-Csv -Path .\exportedprovider.provider.csv

    #test InquiryEndpoint endpoint override
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderName Episys -Force
    New-SGProviderEpisys -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword -InquiryEndpoint inqEndpoint.com -InquiryEndpointUserName inqUser@inqDomain.com -InquiryEndpointPassword inqPass | Add-SGProvider
    #test CustomerEndpoint endpoint override
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderName Episys -Force
    New-SGProviderEpisys -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword -CustomerEndpoint custEndpoint.com -CustomerEndpointUserName custUser@inqDomain.com -CustomerEndpointPassword custPass | Add-SGProvider
    #test ImageEndpoint endpoint override
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderName Episys -Force
    New-SGProviderEpisys -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint Servername.com -AllEndpointUserName user@domain.com -AllEndpointPassword myPassword -TransactionEndpoint imgEndpoint.com -TransactionEndpointUserName imgUser@inqDomain.com -TransactionEndpointPassword inqPass | Add-SGProvider

    #cleanup
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderTypeName Episys -Force
}

#Test New-SGProviderMultiFactorAuth
if($false)
{
    Get-Help New-SGProviderMultiFactorAuth -ShowWindow

	$mfa = New-SGProviderMultiFactorAuth -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint www.services.cyota.net -CallerCredential JHNSOAP06 -CallerId SOAPCLIENT -InstanceId ejhnp -LegacyCallerId SOAPCLIENT  -LegacyInstanceId ejhnp -LegacyCallerCredential JHNSOAP06 -CertFilePath "C:\inetpub\Certs\Multi-Factor Authentication.p12" -CertPassword 13CSMZUXO3MX65IY -GroupKey 09bffa8d56bdce8718c550b36c607ddc -LicenseKey A7GJSRSVACRM -NCPLogFile "E:\Logs\MFA" -Target "https://pfd.phonefactor.net/pfd/pfd.pl" -TargetBackup "https://pfd2.phonefactor.net/pfd/pfd.pl"
	$mfa | Add-SGProvider -Verbose

	#create generic MFA Provider and parms
    $mfa = New-SGProviderMultiFactorAuth -AllEndpoint www.services.cyota.net -CallerCredential JHNSOAP06 -CallerId SOAPCLIENT -InstanceId ejhnp -LegacyCallerId SOAPCLIENT  -LegacyInstanceId ejhnp -LegacyCallerCredential JHNSOAP06 -CertFilePath "C:\inetpub\Certs\Multi-Factor Authentication.p12" -CertPassword 13CSMZUXO3MX65IY -GroupKey 09bffa8d56bdce8718c550b36c607ddc -LicenseKey A7GJSRSVACRM -NCPLogFile "E:\Logs\MFA" -Target "https://pfd.phonefactor.net/pfd/pfd.pl" -TargetBackup "https://pfd2.phonefactor.net/pfd/pfd.pl"
    #select FI's to install provider on.
    Get-SGInstitution | Out-GridView -PassThru | Add-SGProvider -Provider $mfa

    #cleanup
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderTypeName "Multi-Factor Authentication" -Force
}

#Test New-SGProviderNetTeller
if($false)
{
    Get-Help New-SGProviderNetTeller -ShowWindow

	#add user only
	Add-SGUser -Name Matthew -Environment PROD -ABA 123456788 -UserName "matt_m@qa.edn" -Verbose

	#add NetTeller provider only
	$NetTeller = New-SGProviderNetTeller -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint servername.com -AllEndpointUserName username@domain.com -AllEndpointPassword mypassword

    #Option 1 - send as parms
	Add-SGProvider -Provider $NetTeller -Name Matthew -Environment PROD -ABA 123456788 -Verbose

    #Option 2 send in pipeline
    $NetTeller | Add-SGProvider -Verbose

    #create gets a csv copy of the object
    $NetTeller.Provider | Export-Csv -Path .\exportedprovider.provider.csv

    #cleanup
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderTypeName NetTeller -Force
}

#Test New-SGProviderPadapterExtension
if($false)
{
    get-help New-SGProviderPadapterExtension -ShowWindow
	New-SGProviderPadapterExtension -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint servername.jhacorp.com -ProviderHostName 10.1.1.1 -ProviderPort 443 | Add-SGProvider
}

#Test New-SGProviderPadapterWebService
if($false)
{
    get-help New-SGProviderPadapterWebService -ShowWindow
	New-SGProviderPadapterWebService -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint servername.jhacorp.com -AllEndpointUserName username -AllEndpointPassword password | Add-SGProvider

    #cleanup
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderTypeName pAdapter_WebService -Force
}

#Test New-SGProviderSilverlake
if($false)
{
    Get-Help New-SGProviderSilverlake -ShowWindow

	#add silverlake provider only
	$silverlake = New-SGProviderSilverlake -Name Matthew -Environment PROD -ABA 123456788 -ProviderHostName 10.1.1.1 -ProviderPort 40001 -ProviderSecurityKey bob -ProviderInstitutionId 20
	Add-SGProvider -Provider $silverlake -Name Matthew -Environment PROD -ABA 123456788 -Verbose

    #gets a csv copy of the object
    $silverlake.Provider | Export-Csv -Path .\exportedprovider.provider.csv

    #cleanup
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderTypeName SilverLake -Force
}

#Test New-SGProviderSynapsys
if($false)
{
    get-help New-SGProviderSynapsys -ShowWindow
	New-SGProviderSynapsys -Name Matthew -Environment PROD -ABA 123456788 -AllEndpoint servername.jhacorp.com -AllEndpointUserName username -AllEndpointPassword password | Add-SGProvider

    #cleanup
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderTypeName Synapsys -Force
}

#Test Remove-SGInstitution
if($false)
{
    Get-Help remove-SGInstitution -ShowWindow

    Remove-SGInstitution -Name Matthew -Environment PROD -ABA 123456788 -Force

	$institutions = Get-SGInstitution
	$institutions | Out-GridView -PassThru | remove-SGInstitution -Force -Verbose
}

#Test remove provider
if($false)
{
    get-help New-SGProviderPadapterWebService -ShowWindow

    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderTypeName "pAdapter_WebService" -Force
    Remove-SGProvider -Name Matthew -Environment PROD -ABA 123456788 -ProviderTypeName "pAdapter_WebService"
}

#Process - test csv file import export
if($false)
{
     #test export new provider cmdlet to xslx file
    (New-SGProviderMultiFactorAuth -Name 0 -Environment 0 -ABA 0 -ProviderName name -ProviderDescription desc -AllEndpoint b -CallerCredential b -CallerId b -InstanceId b -LegacyInstanceId b -LegacyCallerId b -LegacyCallerCredential b -CertFilePath b -GroupKey b -LicenseKey b -Target b -TargetBackup b -CertPassword b -NCPLogFile b).Provider  | Export-Excel -Path C:\temp\testexport2.xlsx

    $mfaImport = Import-Excel -Path C:\temp\testexport.csv | New-SGProviderMultiFactorAuth
    Get-SGInstitution | Out-GridView -PassThru | Add-SGProvider -Provider $mfaImport

#???
    $silverlake = New-SGProviderSilverlake -Name 0 -Environment 0 -ABA 0 -ProviderName SilverLakeName -ProviderDescription SilverLakeDesc -AllEndpoint 10.1.1.1 -ProviderPort 40001 -ProviderSecurityKey bob -ProviderInstitutionId 20
    Get-SGInstitution | Out-GridView -PassThru | Add-SGProvider -Provider $silverlake

    $mfa = New-SGProviderMultiFactorAuth -Name 0 -Environment 0 -ABA 0 -ProviderName name -ProviderDescription desc -AllEndpoint b -CallerCredential b -CallerId b -InstanceId b -LegacyInstanceId b -LegacyCallerId b -LegacyCallerCredential b -CertFilePath b -GroupKey b -LicenseKey b -Target b -TargetBackup b -CertPassword b -NCPLogFile b

    #test bad object into provider
    $mfaImport = Import-Csv -Path C:\temp\testexport.csv
    Get-SGInstitution | Out-GridView -PassThru | Add-SGProvider -Provider $mfaImport
}

#measure a set of standard import, to check client
if($false)
{
	#wake up services
	Get-SGInstitution

	$banks = Import-Csv -Path .\NewInstitutionsFilesTesting.xlsx
	Measure-Command { $banks | Add-SGInstitution } #before client code update = 2075ms, after = 1309ms

	$providers = $banks | New-SGProviderSilverlake
	Measure-Command {$providers | Add-SGProvider } #before client code update = 91895ms, after = 90839ms

	Measure-Command { Get-SGInstitution } #before client code update = 4474ms, after 475ms

	Measure-Command { $banks | Remove-SGInstitution -Force } #before client code update = 114311ms, after 110615ms
}

