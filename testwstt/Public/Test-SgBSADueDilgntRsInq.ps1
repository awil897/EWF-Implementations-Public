<#
.SYNOPSIS
   Performs a standardized BSADueDilgntRsInq call to the jXchange web services.
.DESCRIPTION
   Sends an XML BSADueDilgntRsInq operation to ServiceGateway
.EXAMPLE
   Test-SgBSADueDilgntRsInq -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD -AuthenUsername bob_user -AuthenPassword bob_Password
.COMPONENT
   TestWSTT
#>
function Test-SgBSADueDilgntRsInq {
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
        $ValidConsmProd = "BSA",

        # AuthenToken Username
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $AuthenUsername,

        # AuthenToken Password
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $AuthenPassword
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<BSADueDilgntRsInq xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <AuditUsrId>jxchange</AuditUsrId>
            <AuditWsId>ThirdParty</AuditWsId>
            <ConsumerName>JHA</ConsumerName>
            <ConsumerProd>BSA</ConsumerProd>
            <jXLogTrackingId>VENDORNAME-[GUID_GOES_HERE]</jXLogTrackingId>
            <InstRtId>113102552</InstRtId>
            <InstEnv>SL529</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>BSA</ValidConsmProd>
        </jXchangeHdr>
        <AuthenProdCred>
            <ns1:Security xmlns:ns1="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
                <ns1:UsernameToken>
                    <ns1:Username>jx_endpoint_user</ns1:Username>
                    <ns1:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">ErhHl6Cqf5i3</ns1:Password>
                </ns1:UsernameToken>
            </ns1:Security>
        </AuthenProdCred>
    </MsgRqHdr>
    <DueDilgntType>Cust</DueDilgntType>
    <DueDilgntCustType>Indv</DueDilgntCustType>
    <CustId>ZZZ2800</CustId>
    <Custom/>
</BSADueDilgntRsInq>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.BSADueDilgntRsInq.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.BSADueDilgntRsInq.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.BSADueDilgntRsInq.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.BSADueDilgntRsInq.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.BSADueDilgntRsInq.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.BSADueDilgntRsInq.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.BSADueDilgntRsInq.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $request.BSADueDilgntRsInq.MsgRqHdr.AuthenProdCred.Security.UsernameToken.Username = $AuthenUsername
        
        Add-Type -AssemblyName System.Web
        $request.BSADueDilgntRsInq.MsgRqHdr.AuthenProdCred.Security.UsernameToken.Password.'#text' = [System.Web.HttpUtility]::HtmlEncode($AuthenPassword)

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
