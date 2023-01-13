<#
.SYNOPSIS
   Performs a standardized IntnetFinInstIdPINMod call to the jXchange web services.
.DESCRIPTION
   Sends an XML IntnetFinInstIdPINMod operation to ServiceGateway
.EXAMPLE
   Test-SgIntnetFinInstIdPINMod -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgIntnetFinInstIdPINMod {
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
        $ValidConsmProd = "Silverlake"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<IntnetFinInstIdPINMod xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>2014.2.0</JxVer>
            <AuditUsrId>PA</AuditUsrId>
            <AuditWsId>jxServer</AuditWsId>
            <ConsumerName>WSTT</ConsumerName>
            <ConsumerProd>WSTT</ConsumerProd>
            <jXLogTrackingId>d278bb25-9768-4dae-9b58-aee5b68051f9</jXLogTrackingId>
            <InstRtId>111321063</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>Silverlake</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <IntnetFinInstUsrId>0909090909099999999999999</IntnetFinInstUsrId>
    <PINActnType>Reset</PINActnType>
</IntnetFinInstIdPINMod>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.IntnetFinInstIdPINMod.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.IntnetFinInstIdPINMod.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.IntnetFinInstIdPINMod.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.IntnetFinInstIdPINMod.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.IntnetFinInstIdPINMod.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.IntnetFinInstIdPINMod.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.IntnetFinInstIdPINMod.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
