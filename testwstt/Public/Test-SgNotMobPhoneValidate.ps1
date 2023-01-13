<#
.SYNOPSIS
   Performs a standardized NotMobPhoneValidate call to the jXchange web services.
.DESCRIPTION
   Sends an XML NotMobPhoneValidate operation to ServiceGateway
.EXAMPLE
   Test-SgNotMobPhoneValidate -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD -MobPhoneNum 4172356652
.COMPONENT
   TestWSTT
#>
function Test-SgNotMobPhoneValidate {
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
        $ValidConsmProd = "CPSOTP",

        # Phone Number
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]
        $MobPhoneNum
    )

    Begin {

    }
    Process {
        $rawXmlTemplate = @"

<NotMobPhoneValidate xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <AuditUsrId>PA</AuditUsrId>
            <AuditWsId>IDG</AuditWsId>
            <jXLogTrackingId>987654321</jXLogTrackingId>
            <InstRtId>291074748</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>CPSOTP</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <MobPhoneNum>4175559999</MobPhoneNum>
</NotMobPhoneValidate>

"@
        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.NotMobPhoneValidate.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.NotMobPhoneValidate.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.NotMobPhoneValidate.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_" + (New-Guid)
        $request.NotMobPhoneValidate.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.NotMobPhoneValidate.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.NotMobPhoneValidate.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.NotMobPhoneValidate.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd
      
        $request.NotMobPhoneValidate.MobPhoneNum = $MobPhoneNum

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End {
    }
}
