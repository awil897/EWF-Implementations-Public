<#
.SYNOPSIS
   Performs a standardized NotRecipInq call to the jXchange web services.
.DESCRIPTION
   Sends an XML NotSMSAlrtAdd operation to ServiceGateway
.EXAMPLE
   Test-SgNotRecipInq -ServerName $ServerName -UserName $Username -Password $Password -InstRtId $InstRtId -InstEnv PROD -ValidConsmName JHA -ValidConsmProd Silverlake -ConsmRecipId TestConsm
.COMPONENT
   TestWSTT
#>
function Test-SgNotRecipInq {
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
        $ValidConsmName,

        # Valid Consumer Prod
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $ValidConsmProd,

        # ConsmRecipId
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $ConsmRecipId,

        # ActIntent
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $ActIntent = "ReadOnly"

    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<NotRecipInq xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>2021.0.00</JxVer>
            <AuditUsrId>TestUser</AuditUsrId>
            <AuditWsId>TestWorkstation</AuditWsId>
            <ConsumerName>JHA</ConsumerName>
            <ConsumerProd>EnterpriseNotification</ConsumerProd>
            <jXLogTrackingId>JX-[GUID_d3d7ce1c-3d5b-452b-a117-232342b009c4]</jXLogTrackingId>
            <InstRtId>001122334</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>EnterpriseNotification</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <InstRtId>001122334</InstRtId>
    <ConsumerProd>EnterpriseNotification</ConsumerProd>
    <ConsmRecipId>JimErwin</ConsmRecipId>
    <ActIntent>ReadOnly</ActIntent>
</NotRecipInq>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.NotRecipInq.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.NotRecipInq.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.NotRecipInq.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.NotRecipInq.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.NotRecipInq.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.NotRecipInq.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.NotRecipInq.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd
        $request.NotRecipInq.MsgRqHdr.jXchangeHdr.ConsumerName = $ValidConsmName
        $request.NotRecipInq.MsgRqHdr.jXchangeHdr.ConsumerProd = $ValidConsmProd


        $request.NotRecipInq.InstRtId = $InstRtId
        $request.NotRecipInq.ConsumerProd = $ValidConsmProd
        $request.NotRecipInq.ConsmRecipId = $ConsmRecipId
        $request.NotRecipInq.ActIntent = $ActIntent

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
