<#
.SYNOPSIS
   Performs a standardized ChkImgInq call to the jXchange web services.
.DESCRIPTION
   Sends an XML ChkImgInq operation to ServiceGateway
.EXAMPLE
   Test-SgChkImgInq -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgUsrEnrollInq {
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
        $ValidConsmName = "CSPI",

        # Valid Consumer Prod
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $ValidConsmProd = "Aurora"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<UsrEnrollInq xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>2017.4.0</JxVer>
            <AuditUsrId>jha</AuditUsrId>
            <AuditWsId>RVLP054</AuditWsId>
            <ConsumerName>SilverLake</ConsumerName>
            <ConsumerProd>Xperience</ConsumerProd>
            <jXLogTrackingId>a976fd49-4d3a-4b96-bcc1-d6da39c8b031</jXLogTrackingId>
            <InstRtId>067016891</InstRtId>
            <InstEnv>PROD</InstEnv>
            <BusCorrelId>f9f00f43-614b-4d9b-843b-4bb6b04010e3</BusCorrelId>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>Silverlake</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <AccountId>
        <AcctId>201002328</AcctId>
        <AcctType>D</AcctType>
    </AccountId>
    <EnrollAppInqArray>
        <EnrollAppInqInfo>
            <EnrollAppType>VR</EnrollAppType>
        </EnrollAppInqInfo>
    </EnrollAppInqArray>
</UsrEnrollInq>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.UsrEnrollInq.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.UsrEnrollInq.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.UsrEnrollInq.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.UsrEnrollInq.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.UsrEnrollInq.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.UsrEnrollInq.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.UsrEnrollInq.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
