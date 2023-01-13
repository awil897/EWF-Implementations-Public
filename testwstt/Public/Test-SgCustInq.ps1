<#
.SYNOPSIS
   Performs a standardized CustInq call to the jXchange web services.
.DESCRIPTION
   Sends an XML CustInq operation to ServiceGateway
.EXAMPLE
   Test-SgCustInq -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgCustInq {
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
        $ValidConsmProd = "CIF2020"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<CustInq xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>R2013.1.03</JxVer>
            <AuditUsrId>jXsupport</AuditUsrId>
            <AuditWsId>TestTool</AuditWsId>
            <ConsumerName>JackHenry</ConsumerName>
            <ConsumerProd>JXTEST</ConsumerProd>
            <jXLogTrackingId>VENDORNAME-[GUID_GOES_HERE]</jXLogTrackingId>
            <InstRtId>111321063</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>CIF2020</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <AccountId>
        <AcctId>62704</AcctId>
        <AcctType>D</AcctType>
    </AccountId>
    <IncXtendElemArray>
        <IncXtendElemInfo>
            <XtendElem>x_TaxDetail</XtendElem>
        </IncXtendElemInfo>
        <IncXtendElemInfo>
            <XtendElem>x_BusDetail</XtendElem>
        </IncXtendElemInfo>
        <IncXtendElemInfo>
            <XtendElem>x_RegDetail</XtendElem>
        </IncXtendElemInfo>
        <IncXtendElemInfo>
            <XtendElem>x_IdVerify</XtendElem>
        </IncXtendElemInfo>
    </IncXtendElemArray>
</CustInq>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.CustInq.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.CustInq.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.CustInq.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.CustInq.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.CustInq.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.CustInq.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.CustInq.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
