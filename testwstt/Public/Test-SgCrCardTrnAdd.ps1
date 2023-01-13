<#
.SYNOPSIS
   Performs a standardized CrCardTrnAdd call to the jXchange web services.
.DESCRIPTION
   Sends an XML CrCardTrnAdd operation to ServiceGateway
.EXAMPLE
   Test-SgCrCardTrnAdd -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgCrCardTrnAdd {
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

<CrCardTrnAdd xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>2018.7.03</JxVer>
            <AuditUsrId>jXchange</AuditUsrId>
            <AuditWsId>ThirdParty</AuditWsId>
            <ConsumerName>Test</ConsumerName>
            <jXLogTrackingId>VENDORNAME-[GUID_GOES_HERE]</jXLogTrackingId>
            <InstRtId>121143626</InstRtId>
            <InstEnv>PROD</InstEnv>
            <BusCorrelId>test</BusCorrelId>
            <WorkflowCorrelId>test1pos</WorkflowCorrelId>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>Silverlake</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <CrCardAcctId>9999999999999999</CrCardAcctId>
    <CrCardTrnType>Pmt</CrCardTrnType>
    <CrCardPmtInfoRec>
        <Amt>0</Amt>
        <DrRtNum>111111111</DrRtNum>
        <DrAcctId>222222222</DrAcctId>
        <DrAcctType>C</DrAcctType>
    </CrCardPmtInfoRec>
</CrCardTrnAdd>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.CrCardTrnAdd.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.CrCardTrnAdd.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.CrCardTrnAdd.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.CrCardTrnAdd.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.CrCardTrnAdd.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.CrCardTrnAdd.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.CrCardTrnAdd.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
