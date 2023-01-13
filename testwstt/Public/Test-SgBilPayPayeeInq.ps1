<#
.SYNOPSIS
   Performs a standardized BilPayPayeeInq call to the jXchange web services.
.DESCRIPTION
   Sends an XML BilPayPayeeInq operation to ServiceGateway
.EXAMPLE
   Test-SgBilPayPayeeInq -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgBilPayPayeeInq {
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

<BilPayPayeeInq xmlns="http://jackhenry.com/jxchange/TPG/2008">
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
            <ValidConsmProd>xxxxxx</ValidConsmProd>
        </jXchangeHdr>
        <MaxRec>10</MaxRec>
        <Cursor>0</Cursor>
    </SrchMsgRqHdr>
    <BilPayProd>BilPay</BilPayProd>
    <SubId>1468098094</SubId>
    <PayeeId>2</PayeeId>
    <ActIntent>ReadOnly</ActIntent>
    <Custom/>
    <Ver_1/>
    <Ver_2/>
</BilPayPayeeInq>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.BilPayPayeeInq.SrchMsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.BilPayPayeeInq.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.BilPayPayeeInq.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.BilPayPayeeInq.SrchMsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.BilPayPayeeInq.SrchMsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.BilPayPayeeInq.SrchMsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.BilPayPayeeInq.SrchMsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
