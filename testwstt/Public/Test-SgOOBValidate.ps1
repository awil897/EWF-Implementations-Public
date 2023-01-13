<#
.SYNOPSIS
   Performs a standardized OOBValidate call to the jXchange web services.
.DESCRIPTION
   Sends an XML OOBValidate operation to ServiceGateway
.EXAMPLE
   Test-SgOOBValidate -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD -PhoneNumber 4172356652
.EXAMPLE
    Test-SgOOBValidate -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD -PhoneNumber 4172356652 -Voice $true
.COMPONENT
   TestWSTT
#>
function Test-SgOOBValidate {
    [CmdletBinding()]
    Param
    (
        # Server Name of the ServiceGateway Server
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]        
        [string]
        $ServerName,

        # Username to access the service
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]
        $UserName,

        # Password to access the service
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]
        $Password,

        # also ABA
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Alias("ABA")]
        [string]
        $InstRtId,

        # also Env
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Alias("Environment")]
        [string]
        $InstEnv,

        # Valid Consumer Name
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [string]
        $ValidConsmName = "JHA",

        # Valid Consumer Prod
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [string]
        $ValidConsmProd = "iPay",

        # Phone Number
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [alias('PhoneNumber')]
        [string]        
        $PhoneNum,

        # Voice Switch
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]        
        [bool]
        $VoiceOTP = $false
    )

    Begin {

    }
    Process {
        $rawXmlTemplate = @"

<OOBValidate xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <AuditUsrId>PA</AuditUsrId>
            <AuditWsId>IDG</AuditWsId>
            <ConsumerName>JHA</ConsumerName>
            <ConsumerProd>iPay</ConsumerProd>
            <jXLogTrackingId>987654321</jXLogTrackingId>
            <InstRtId>291074748</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>iPay</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <InstRtId>291074748</InstRtId>
    <ConsumerProd>iPay</ConsumerProd>
    <PhoneNum>4175559999</PhoneNum>
    <OOBModeType>OneWay</OOBModeType>
    [VOICE]
</OOBValidate>

"@
        if ($VoiceOTP) {
            $rawXmlTemplate = $rawXmlTemplate.Replace("[VOICE]", "<Custom><VoiceOTP>true</VoiceOTP></Custom>")
        }
        else {
            $rawXmlTemplate = $rawXmlTemplate.Replace("[VOICE]", "")
        }
        
        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.OOBValidate.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.OOBValidate.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.OOBValidate.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_" + (New-Guid)
        $request.OOBValidate.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.OOBValidate.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.OOBValidate.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.OOBValidate.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $request.OOBValidate.InstRtId = $InstRtId
        $request.OOBValidate.ConsumerProd = $ValidConsmProd
        $request.OOBValidate.PhoneNum = $PhoneNum

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End {
    }
}
