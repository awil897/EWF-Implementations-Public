<#
.SYNOPSIS
   Performs a standardized AcctHistSrch call to the jXchange web services.
.DESCRIPTION
   Sends an XML AcctHistSrch operation to ServiceGateway
.EXAMPLE
   Test-SgAcctHistSrch -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgAcctHistSrch {
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
        $ValidConsmProd = "BillPay",

        # Valid AuditWsId
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

<AcctHistSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <SrchMsgRqHdr>
        <jXchangeHdr>
            <JxVer>R2013.1.03</JxVer>
            <AuditUsrId>jXsupport</AuditUsrId>
            <AuditWsId>TestTool</AuditWsId>
            <jXLogTrackingId>VENDORNAME-[GUID_GOES_HERE]</jXLogTrackingId>
            <InstRtId>111321063</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>BillPay</ValidConsmProd>
        </jXchangeHdr>
        <MaxRec>500</MaxRec>
    </SrchMsgRqHdr>
    <InAcctId>
        <AcctId>2</AcctId>
        <AcctType>D</AcctType>
    </InAcctId>
</AcctHistSrch>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.AcctHistSrch.SrchMsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.AcctHistSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.AcctHistSrch.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.AcctHistSrch.SrchMsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.AcctHistSrch.SrchMsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.AcctHistSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.AcctHistSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd
        $request.AcctHistSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $AuditWsId

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
