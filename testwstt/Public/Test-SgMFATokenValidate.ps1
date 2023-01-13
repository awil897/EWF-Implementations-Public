<#
.SYNOPSIS
   Performs a standardized MFATokenValidate call to the jXchange web services.
.DESCRIPTION
   Sends an XML MFATokenValidate operation to ServiceGateway
.EXAMPLE
   Test-SgMFATokenValidate -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgMFATokenValidate {
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
        $ValidConsmProd = "iPay"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<MFATokenValidate xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <AuditUsrId>jXsupport</AuditUsrId>
            <AuditWsId>TestTool</AuditWsId>
            <jXLogTrackingId>VENDORNAME-[GUID_GOES_HERE]</jXLogTrackingId>
            <InstRtId>111321063</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>iPay</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <UsrName>974484323</UsrName>
    <OTPArray>
        <OTPInfo>
            <OTPType>Prim</OTPType>
            <OTP>790932</OTP>
        </OTPInfo>
    </OTPArray>
</MFATokenValidate>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.MFATokenValidate.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.MFATokenValidate.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.MFATokenValidate.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.MFATokenValidate.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.MFATokenValidate.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.MFATokenValidate.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.MFATokenValidate.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
