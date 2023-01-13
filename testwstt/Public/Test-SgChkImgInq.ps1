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
function Test-SgChkImgInq {
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
        $ValidConsmProd = "BannoMobile",

        # Ping Message.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $ChkImgId = "9999999999"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<ChkImgInq xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>R2013.1.03</JxVer>
            <AuditUsrId>jXsupport</AuditUsrId>
            <AuditWsId>TestTool</AuditWsId>
            <jXLogTrackingId>VENDORNAME-[GUID_GOES_HERE]</jXLogTrackingId>
            <InstRtId>111321063</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>BannoMobile</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <ChkImgId>999999999999</ChkImgId>
    <ChkImgFormat>TIFF</ChkImgFormat>
    <ChkImgSide>Both</ChkImgSide>
</ChkImgInq>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.ChkImgInq.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.ChkImgInq.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.ChkImgInq.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.ChkImgInq.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.ChkImgInq.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.ChkImgInq.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.ChkImgInq.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $request.ChkImgInq.ChkImgId = $ChkImgId

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
