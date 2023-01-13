<#
.SYNOPSIS
   Performs a standardized NotEmailAlrtAdd call to the jXchange web services.
.DESCRIPTION
   Sends an XML NotEmailAlrtAdd operation to ServiceGateway
.EXAMPLE
PS C:\>Test-SgNotEmailAlrtAdd -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD -EmailRecipAddr test@jackhenry.com -AlrtName CPSOTP_ALERT_MC
#This will call the default request.
.EXAMPLE
PS C:\>
$mydata = @([PSCustomObject] @{
        Name = "NameValue1"
        Val = "ValValue1"
    },
    
    [PSCustomObject] @{
        Name = "NameValue2"
        Val = "ValValue2"
    })

    #This Creates an Array List of PSCustomObject to be used in the next example.
.EXAMPLE
    PS C:\>Test-SgNotEmailAlrtAdd -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD -EmailRecipAddr test@jackhenry.com -AlrtName CPSOTP_ALERT_MC -AlrtDataInfoArrayItems $myData
    
    #This will call the custom request with added Name and Val array items that were created in Example #2.
.COMPONENT
   TestWSTT
#>
function Test-SgNotEmailAlrtAdd {
   [CmdletBinding()]
    Param
    (
        # Server Name of the ServiceGateway Server
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]        
        [string]
        $ServerName,

        # Username to access the service
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $UserName,

        # Password to access the service
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $Password,

        # also ABA
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias("ABA")]
        [string]
        $InstRtId,

        # also Env
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias("Environment")]
        [string]
        $InstEnv,

        # Valid Consumer Name
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $ValidConsmName = "JHA",

        # Valid Consumer Prod
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $ValidConsmProd = "Silverlake",

        # Email Address
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $EmailRecipAddr,

        # Email body type
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("HTML", "Text")]
        [string]
        $EmailBodyType = "HTML",

        # Alert Name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $AlrtName,

        #(optional) Populates the AlrtDataInfoArray.AlrtDataInfoRec array items. Pass in a PSCustomObject array with Name and Val, see example #2 and #3
        $AlrtDataInfoArrayItems
    )

    Begin
    {

    }
    Process
    {
        if($AlrtDataInfoArrayItems -eq $null)
        {
            $rawXmlTemplate = @"
<NotEmailAlrtAdd xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>2018.7.03</JxVer>
            <AuditUsrId>SSSupport</AuditUsrId>
            <AuditWsId>MgtServer</AuditWsId>
            <ConsumerName>JHA</ConsumerName>
            <ConsumerProd>iPay</ConsumerProd>
            <jXLogTrackingId>JX-25eceedf-70d5-4fd2-bb36-2b7ac46f915c</jXLogTrackingId>
            <InstRtId>291074748</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>iPay</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <InstRtId>291074748</InstRtId>
    <ConsumerProd>iPay</ConsumerProd>
    <EmailRecipAddr>test@jackhenry.com</EmailRecipAddr>
    <AlrtName>BasicTest</AlrtName>
    <EmailBodyType>HTML</EmailBodyType>
    <AlrtDataInfoArray>
        <AlrtDataInfoRec>
            <Name>ApplicationId</Name>
            <Val>Automated Test of ENS</Val>
        </AlrtDataInfoRec>
        <AlrtDataInfoRec>
            <Name>CUSTOMMESSAGE</Name>
            <Val>TEST ENS Email</Val>
        </AlrtDataInfoRec>
    </AlrtDataInfoArray>
</NotEmailAlrtAdd>

"@
}
else
{
$AlrtDataInfoRecData = (
   $AlrtDataInfoArrayItems |
ForEach-Object {
    $name = [System.Security.SecurityElement]::Escape($_.Name)
    $val = [System.Security.SecurityElement]::Escape($_.Val)
@"
<AlrtDataInfoRec>
            <Name>$($name)</Name>
            <Val>$($val)</Val>
</AlrtDataInfoRec>
"@
}) -join "`n"

$AlrtDataInfoArrayData = @"
<AlrtDataInfoArray>
$AlrtDataInfoRecData
</AlrtDataInfoArray>
"@

$rawXmlTemplate = @"
<NotEmailAlrtAdd xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>2018.7.03</JxVer>
            <AuditUsrId>SSSupport</AuditUsrId>
            <AuditWsId>MgtServer</AuditWsId>
            <ConsumerName>JHA</ConsumerName>
            <ConsumerProd>iPay</ConsumerProd>
            <jXLogTrackingId>JX-25eceedf-70d5-4fd2-bb36-2b7ac46f915c</jXLogTrackingId>
            <InstRtId>291074748</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>iPay</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <InstRtId>291074748</InstRtId>
    <ConsumerProd>iPay</ConsumerProd>
    <EmailRecipAddr>test@jackhenry.com</EmailRecipAddr>
    <AlrtName>BasicTest</AlrtName>
    <EmailBodyType>HTML</EmailBodyType>
    $AlrtDataInfoArrayData
</NotEmailAlrtAdd>

"@
}

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.NotEmailAlrtAdd.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.NotEmailAlrtAdd.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.NotEmailAlrtAdd.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.NotEmailAlrtAdd.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.NotEmailAlrtAdd.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.NotEmailAlrtAdd.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.NotEmailAlrtAdd.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd
        $request.NotEmailAlrtAdd.MsgRqHdr.jXchangeHdr.ConsumerName = $ValidConsmName
        $request.NotEmailAlrtAdd.MsgRqHdr.jXchangeHdr.ConsumerProd = $ValidConsmProd


        $request.NotEmailAlrtAdd.InstRtId = $InstRtId
        $request.NotEmailAlrtAdd.ConsumerProd = $ValidConsmProd
        $request.NotEmailAlrtAdd.EmailRecipAddr = $EmailRecipAddr
        $request.NotEmailAlrtAdd.EmailBodyType = $EmailBodyType
        $request.NotEmailAlrtAdd.AlrtName = $AlrtName

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
