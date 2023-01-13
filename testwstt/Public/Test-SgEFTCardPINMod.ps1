<#
.SYNOPSIS
   Performs a standardized EFTCardPINMod call to the jXchange web services.
.DESCRIPTION
   Sends an XML EFTCardPINMod operation to ServiceGateway
.EXAMPLE
   Test-SgEFTCardPINMod -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgEFTCardPINMod {
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

<EFTCardPINMod xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <AuditUsrId>ThirdParty</AuditUsrId>
            <AuditWsId>jXchange</AuditWsId>
            <AuthenUsrId>Judya</AuthenUsrId>
            <ConsumerName/>
            <ConsumerProd/>
            <jXLogTrackingId>123</jXLogTrackingId>
            <InstRtId>113102552</InstRtId>
            <InstEnv>Prod</InstEnv>
            <BusCorrelId/>
            <WorkflowCorrelId/>
            <ValidConsmName/>
            <ValidConsmProd/>
        </jXchangeHdr>
    </MsgRqHdr>
    <PINModId>1a212a9c-fad0-4600-9959-5e389cb1bc4e</PINModId>
    <EFTCardOldPINId>352</EFTCardOldPINId>
    <EFTCardNewPINId>6868</EFTCardNewPINId>
</EFTCardPINMod>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.EFTCardPINMod.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.EFTCardPINMod.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.EFTCardPINMod.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.EFTCardPINMod.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.EFTCardPINMod.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.EFTCardPINMod.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.EFTCardPINMod.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
