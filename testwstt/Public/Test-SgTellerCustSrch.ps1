<#
.SYNOPSIS
   Performs a standardized TellerCustSrch call to the jXchange web services.
.DESCRIPTION
   Sends an XML TellerCustSrch operation to ServiceGateway
.EXAMPLE
   Test-SgTellerCustSrch -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgTellerCustSrch {
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

<TellerCustSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <SrchMsgRqHdr>
        <jXchangeHdr>
            <AuditUsrId>JXCHANGE</AuditUsrId>
            <AuditWsId>ThirdParty</AuditWsId>
            <AuthenUsrId>judya</AuthenUsrId>
            <ConsumerName>jackhenry</ConsumerName>
            <jXLogTrackingId>123</jXLogTrackingId>
            <ConsumerProd>soatest</ConsumerProd>
            <InstRtId>112233445</InstRtId>
            <InstEnv>Prod</InstEnv>     
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>xxxxxx</ValidConsmProd>
        </jXchangeHdr>
        <MaxRec>10</MaxRec>
        <Cursor/>
    </SrchMsgRqHdr>
    <CustId>ZZ00011</CustId>
</TellerCustSrch>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.TellerCustSrch.SrchMsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.TellerCustSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.TellerCustSrch.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.TellerCustSrch.SrchMsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.TellerCustSrch.SrchMsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.TellerCustSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.TellerCustSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
