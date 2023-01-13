<#
.SYNOPSIS
   Performs a standardized EFTCardPINOffSetMod call to the jXchange web services.
.DESCRIPTION
   Sends an XML EFTCardPINOffSetMod operation to ServiceGateway
.EXAMPLE
   Test-SgEFTCardPINOffSetMod -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgEFTCardPINOffSetMod {
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

<EFTCardPINOffSetMod xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>2014</JxVer>
            <AuditUsrId>jxchange</AuditUsrId>
            <AuditWsId>thirdparty</AuditWsId>
            <AuthenUsrId>judya</AuthenUsrId>
            <ConsumerName>Passport</ConsumerName>
            <ConsumerProd>soatest</ConsumerProd>
            <jXLogTrackingId>123</jXLogTrackingId>
            <InstRtId>113102552</InstRtId>
            <InstEnv>Prod</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>xxxxxx</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <EFTCardNum>4999211000000008</EFTCardNum>
    <EFTCardExpDt>2018-05-01</EFTCardExpDt>
    <EFTCardPINOffSetId>1234</EFTCardPINOffSetId>
</EFTCardPINOffSetMod>


"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.EFTCardPINOffSetMod.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.EFTCardPINOffSetMod.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.EFTCardPINOffSetMod.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.EFTCardPINOffSetMod.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.EFTCardPINOffSetMod.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.EFTCardPINOffSetMod.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.EFTCardPINOffSetMod.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
