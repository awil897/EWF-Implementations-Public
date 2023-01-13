<#
.SYNOPSIS
   Performs a standardized IntnetFinInstUsrAuthenInq call to the jXchange web services.
.DESCRIPTION
   Sends an XML IntnetFinInstUsrAuthenInq operation to ServiceGateway
.EXAMPLE
   Test-SgIntnetFinInstUsrAuthenInq -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgIntnetFinInstUsrAuthenInq {
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

<IntnetFinInstUsrAuthenInq xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>2014.2.0</JxVer>
            <AuditUsrId>PA</AuditUsrId>
            <AuditWsId>jxServer</AuditWsId>
            <ConsumerName>WSTT</ConsumerName>
            <ConsumerProd>WSTT</ConsumerProd>
            <jXLogTrackingId>d278bb25-9768-4dae-9b58-aee5b68051f9</jXLogTrackingId>
            <InstRtId>101101976</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>BannoMobile</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <IntnetFinInstUsrId>johnnytest</IntnetFinInstUsrId>
    <IntnetFinInstPswdId>XXXver01</IntnetFinInstPswdId>
</IntnetFinInstUsrAuthenInq>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.IntnetFinInstUsrAuthenInq.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.IntnetFinInstUsrAuthenInq.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.IntnetFinInstUsrAuthenInq.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.IntnetFinInstUsrAuthenInq.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.IntnetFinInstUsrAuthenInq.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.IntnetFinInstUsrAuthenInq.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.IntnetFinInstUsrAuthenInq.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }

}
