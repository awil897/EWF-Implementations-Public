<#
.SYNOPSIS
   Performs a standardized LogSrch call to the jXchange web services.
.DESCRIPTION
   Sends an XML LogSrch operation to ServiceGateway
.EXAMPLE
   Test-SgLogSrch -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD -LogDest "Local"
.COMPONENT
   TestWSTT
#>
function Test-SgLogSrch {
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
        $ValidConsmProd = "iPay",

        # Log Destination
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $LogDest = "Local"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<LogSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <SrchMsgRqHdr>
        <jXchangeHdr>
            <JxVer/>
            <AuditUsrId>JXCHANGE</AuditUsrId>
            <AuditWsId>ThirdParty</AuditWsId>
            <AuthenUsrId>JudyA</AuthenUsrId>
            <jXLogTrackingId>VENDORNAME-[GUID_GOES_HERE]</jXLogTrackingId>
            <InstRtId>111111112</InstRtId>
            <InstEnv>EnterPriseLogging</InstEnv>   
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>xxxxxx</ValidConsmProd>
        </jXchangeHdr>
        <MaxRec>5</MaxRec>
        <Cursor>0</Cursor>
    </SrchMsgRqHdr>
    <LogDest>Local</LogDest>
    <LogStartDt>2000-12-15</LogStartDt>
</LogSrch>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.LogSrch.SrchMsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.LogSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.LogSrch.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.LogSrch.SrchMsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.LogSrch.SrchMsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.LogSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.LogSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $request.LogSrch.LogDest = $LogDest

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
