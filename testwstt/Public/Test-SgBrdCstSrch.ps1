<#
.SYNOPSIS
   Performs a standardized BrdCstSrch call to the jXchange web services.
.DESCRIPTION
   Sends an XML BrdCstSrch operation to ServiceGateway
.EXAMPLE
   Test-SgBrdCstSrch -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD -EventCode "CustDetail"
.COMPONENT
   TestWSTT
#>
function Test-SgBrdCstSrch {
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
        $ValidConsmProd = "iPay",

        # Valid Consumer Prod
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $EventCode = "CustDetail"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<BrdCstSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <SrchMsgRqHdr>
        <jXchangeHdr>
            <JxVer>2013</JxVer>
            <AuditUsrId>JXCHANGE</AuditUsrId>
            <AuditWsId>ThirdParty</AuditWsId>
            <AuthenUsrId>UserName</AuthenUsrId>
            <ConsumerName>jackhenry</ConsumerName>
            <ConsumerProd>TestWSTT</ConsumerProd>
            <jXLogTrackingId>VENDORNAME-[GUID_GOES_HERE]</jXLogTrackingId>
            <InstRtId>113102552</InstRtId>
            <InstEnv>Prod</InstEnv>
            <BusCorrelId>123</BusCorrelId>
            <WorkflowCorrelId>123</WorkflowCorrelId>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>xxxxxx</ValidConsmProd>
        </jXchangeHdr>
        <MaxRec>4000</MaxRec>
        <Cursor>0</Cursor>
    </SrchMsgRqHdr>
    <EventCode>CustDetail</EventCode>
</BrdCstSrch>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.BrdCstSrch.SrchMsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.BrdCstSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.BrdCstSrch.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.BrdCstSrch.SrchMsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.BrdCstSrch.SrchMsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.BrdCstSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.BrdCstSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $request.BrdCstSrch.EventCode = $EventCode

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
