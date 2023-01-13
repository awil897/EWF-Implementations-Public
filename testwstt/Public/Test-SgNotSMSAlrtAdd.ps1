<#
.SYNOPSIS
   Performs a standardized NotSMSAlrtAdd call to the jXchange web services.
.DESCRIPTION
   Sends an XML NotSMSAlrtAdd operation to ServiceGateway
.EXAMPLE
   Test-SgNotSMSAlrtAdd -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD -MobPhoneNum 4172354114 -AlrtName CPSOTP_Alert_MC
.COMPONENT
   TestWSTT
#>
function Test-SgNotSMSAlrtAdd {
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

        # Phone Number
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $MobPhoneNum,

        # Alert Name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $AlrtName

    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<NotSMSAlrtAdd xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>2018.7.03</JxVer>
            <AuditUsrId>AuditUsrId1</AuditUsrId>
            <AuditWsId>AuditWsId1</AuditWsId>
            <ConsumerName>JHA</ConsumerName>
            <ConsumerProd>CPSOTP</ConsumerProd>
            <jXLogTrackingId>VENDORNAME-[GUID_GOES_HERE]</jXLogTrackingId>
            <InstRtId>071112503</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>CPSOTP</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <InstRtId>071112503</InstRtId>
    <ConsumerProd>CPSOTP</ConsumerProd>
    <MobPhoneNum>4172354114</MobPhoneNum>
    <AlrtName>CPSOTP_Alert_MC</AlrtName>
    <AlrtDataInfoArray>
        <AlrtDataInfoRec>
            <Name>ApplicationId</Name>
            <Val>Manual test of ENS</Val>
        </AlrtDataInfoRec>
        <AlrtDataInfoRec>
            <Name>CUSTOMMESSAGE</Name>
            <Val>TEST ENS SMS</Val>
        </AlrtDataInfoRec>
    </AlrtDataInfoArray>
</NotSMSAlrtAdd>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.NotSMSAlrtAdd.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.NotSMSAlrtAdd.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.NotSMSAlrtAdd.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.NotSMSAlrtAdd.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.NotSMSAlrtAdd.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.NotSMSAlrtAdd.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.NotSMSAlrtAdd.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd
        $request.NotSMSAlrtAdd.MsgRqHdr.jXchangeHdr.ConsumerName = $ValidConsmName
        $request.NotSMSAlrtAdd.MsgRqHdr.jXchangeHdr.ConsumerProd = $ValidConsmProd


        $request.NotSMSAlrtAdd.InstRtId = $InstRtId
        $request.NotSMSAlrtAdd.ConsumerProd = $ValidConsmProd
        $request.NotSMSAlrtAdd.MobPhoneNum = $MobPhoneNum
        $request.NotSMSAlrtAdd.AlrtName = $AlrtName

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
