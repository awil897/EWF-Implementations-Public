<#
.SYNOPSIS
   Performs a standardized ChkRiskInq call to the jXchange web services.
.DESCRIPTION
   Sends an XML ChkRiskInq operation to ServiceGateway
.EXAMPLE
   Test-SgChkRiskInq -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgChkRiskInq {
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
        $ValidConsmProd = "ImageCenter"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<ChkRiskInq xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>R2013.1.03</JxVer>
            <AuditUsrId>AuditUsrId1</AuditUsrId>
            <AuditWsId>AuditWsId1</AuditWsId>
            <jXLogTrackingId>VENDORNAME-[GUID_GOES_HERE]</jXLogTrackingId>
            <ConsumerName>JackHenry</ConsumerName>
            <ConsumerProd>ImageCenter</ConsumerProd>
            <InstRtId>321171317</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>ImageCenter</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <TrnInstRtId>321171317</TrnInstRtId>
    <TrnAcctId>TrnAcctId1</TrnAcctId>
    <TrnChanType>TrnChanType1</TrnChanType>
    <IdVerify>
        <IdVerifyQueryArray>
            <IdVerifyQueryInfo>
                <IdVerifyQuery>IdVerifyQuery1</IdVerifyQuery>
                <IdVerifyQueryVal>IdVerifyQueryVal1</IdVerifyQueryVal>
            </IdVerifyQueryInfo>
            <IdVerifyQueryInfo>
                <IdVerifyQuery>IdVerifyQuery2</IdVerifyQuery>
                <IdVerifyQueryVal>IdVerifyQueryVal2</IdVerifyQueryVal>
            </IdVerifyQueryInfo>
        </IdVerifyQueryArray>
    </IdVerify>
</ChkRiskInq>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.ChkRiskInq.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.ChkRiskInq.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.ChkRiskInq.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.ChkRiskInq.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.ChkRiskInq.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.ChkRiskInq.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.ChkRiskInq.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $request.ChkRiskInq.TrnInstRtId = $InstRtId

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
