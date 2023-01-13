<#
.SYNOPSIS
   Performs a standardized WireIntlTrnInq call to the jXchange web services.
.DESCRIPTION
   Sends an XML WireIntlTrnInq operation to ServiceGateway
.EXAMPLE
   Test-SgWireIntlTrnInq -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgWireIntlTrnInq {
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
        $ValidConsmProd = "SilverLake",
        
        # Fin Aba
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $FinInstRtId
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<WireIntlTrnAdd xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr xmlns="http://jackhenry.com/jxchange/TPG/2008">
            <AuditUsrId>matt_m</AuditUsrId>
            <AuditWsId>MATTHEW-MOR-LAP</AuditWsId>
            <jXLogTrackingId>DLIjx_9a48aba5-d788-4cf2-b5f5-136658c4dd0f</jXLogTrackingId>
            <InstRtId>123456789</InstRtId>
            <InstEnv>PROD</InstEnv>
            <BusCorrelId>DLIbc_9657d239-f9fe-44ec-8785-ec4c09fd1f73</BusCorrelId>
            <WorkflowCorrelId>DLIwf_e7563708-900e-446f-989e-4c61daf71fc9</WorkflowCorrelId>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>SilverLake</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <ErrOvrRdInfoArray xsi:nil="true" />
    <FinInstRtId>120054780</FinInstRtId>
    <WireCorrelId>201907161624232241451</WireCorrelId>
    <WireQuoteId xsi:nil="true" />
    <WireContrRefId xsi:nil="true" />
    <FundMthdType>OutgoingWire</FundMthdType>
    <WireTrnTimeDt xsi:nil="true" />
    <CurrType>EUR</CurrType>
    <WireAmt>501</WireAmt>
    <CurrPmtType>Local</CurrPmtType>
    <SttlCurrType>USD</SttlCurrType>
    <SttlMthdType>ACH</SttlMthdType>
    <SttlFinInstRtId>111111111</SttlFinInstRtId>
    <SttlWireAcctId>999999999999</SttlWireAcctId>
    <WireIntlTrnDetails>
        <WireIntlCustDetails xmlns="http://jackhenry.com/jxchange/TPG/2008">
            <WireCustId>D001</WireCustId>
            <CustName>BOB SMITH</CustName>
            <StreetAddr1>664 HWY 60</StreetAddr1>
            <City>MONETT</City>
            <PostalCode>65708</PostalCode>
            <StateProv>MO</StateProv>
            <CntryType>US</CntryType>
            <ConName1>CONTACT</ConName1>
            <FinInstName>JHA IDGQA BANK C TESTS</FinInstName>
            <WireOrignFinInstId>096015232</WireOrignFinInstId>
            <FinInstStreetAddr1>663 HWY 60</FinInstStreetAddr1>
        </WireIntlCustDetails>
        <WireIntlPayeeDetails xmlns="http://jackhenry.com/jxchange/TPG/2008">
            <WirePayeeId>20172707111500</WirePayeeId>
            <PayeeName>Gizmo Omzig</PayeeName>
            <StreetAddr1>Appartement 37, Batiment 4</StreetAddr1>
            <StreetAddr2>218 rue de la Tombe-Issoire</StreetAddr2>
            <City>Paris</City>
            <PostalCode>75014</PostalCode>
            <StateProv>DB</StateProv>
            <CntryType>FR</CntryType>
            <FinInstName>PAYEE FRANCE BANK</FinInstName>
            <FinInstRtId>021212121</FinInstRtId>
            <WireAcctId>3847838483</WireAcctId>
            <FinInstStreetAddr1>118 Boulevard Saint-Germain</FinInstStreetAddr1>
            <FinInstCity>Paris</FinInstCity>
            <FinInstPostalCode>75015</FinInstPostalCode>
            <FinInstCntryType>FR</FinInstCntryType>
        </WireIntlPayeeDetails>
        <OrderCustFundAcctId xmlns="http://jackhenry.com/jxchange/TPG/2008">252528</OrderCustFundAcctId>
        <OrderCustFundInstRtId xmlns="http://jackhenry.com/jxchange/TPG/2008">096015232</OrderCustFundInstRtId>
    </WireIntlTrnDetails>
</WireIntlTrnAdd>


"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.WireIntlTrnAdd.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.WireIntlTrnAdd.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.WireIntlTrnAdd.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.WireIntlTrnAdd.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.WireIntlTrnAdd.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.WireIntlTrnAdd.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.WireIntlTrnAdd.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $request.WireIntlTrnAdd.FinInstRtId = $FinInstRtId

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
