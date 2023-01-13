<#
.SYNOPSIS
   Performs a standardized CustSrch call to the jXchange web services.
.DESCRIPTION
   Sends an XML CustSrch operation to ServiceGateway
.EXAMPLE
   Test-SgCustSrch -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgCustSrch {
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
        $ValidConsmProd = "CIF2020",

        #  Valid AuditWsId
        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [string]
        $AuditWsId = 'TestTool'
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<CustSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <SrchMsgRqHdr>
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
        <MaxRec>10</MaxRec>
        <Cursor>0</Cursor>
    </SrchMsgRqHdr>
    <PersonName>
        <LastName>A</LastName>
    </PersonName>
</CustSrch>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.CustSrch.SrchMsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.CustSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.CustSrch.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.CustSrch.SrchMsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.CustSrch.SrchMsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.CustSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.CustSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd
        $request.CustSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $AuditWsId

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
