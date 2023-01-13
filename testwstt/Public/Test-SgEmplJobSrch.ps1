<#
.SYNOPSIS
   Performs a standardized EmplJobSrch call to the jXchange web services.
.DESCRIPTION
   Sends an XML EmplJobSrch operation to ServiceGateway
.EXAMPLE
   Test-SgEmplJobSrch -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgEmplJobSrch {
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
        $ValidConsmProd = "TimeTrack"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<EmplJobSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <SrchMsgRqHdr>
        <jXchangeHdr>
            <JxVer>2015</JxVer>
            <AuditUsrId>jxchange</AuditUsrId>
            <AuditWsId>thirdparty</AuditWsId>
            <AuthenUsrId>judyj</AuthenUsrId>
            <ConsumerName>soatest</ConsumerName>
            <ConsumerProd>jxchange</ConsumerProd>
            <jXLogTrackingId>123</jXLogTrackingId>
            <InstRtId>989898988</InstRtId>
            <InstEnv>Prod</InstEnv>
            <BusCorrelId>123</BusCorrelId>
            <WorkflowCorrelId>123</WorkflowCorrelId>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>TimeTrack</ValidConsmProd>
        </jXchangeHdr>
        <MaxRec>3</MaxRec>
        <Cursor>3</Cursor>
    </SrchMsgRqHdr>
</EmplJobSrch>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.EmplJobSrch.SrchMsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.EmplJobSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.EmplJobSrch.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.EmplJobSrch.SrchMsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.EmplJobSrch.SrchMsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.EmplJobSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.EmplJobSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
