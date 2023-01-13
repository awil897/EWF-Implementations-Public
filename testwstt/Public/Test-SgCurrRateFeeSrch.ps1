<#
.SYNOPSIS
   Performs a standardized CurrRateFeeSrch call to the jXchange web services.
.DESCRIPTION
   Sends an XML CustInq operation to ServiceGateway
.EXAMPLE
   Test-SgCurrRateFeeSrch -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgCurrRateFeeSrch {
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
        $ValidConsmName,

        # Valid Consumer Prod
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $ValidConsmProd,

        # Fi ABA
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $FinInstRtId,
        
        # Max records to return, default is 10
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $MaxRec = "10",

        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $BusCorrelId = "00849003-6673-1a0f-b55e-0004ac19db9d"
    )

    Begin
    {

    }
    Process
    {
        $myBoundParms = $PSBoundParameters #debug helper - https://stackoverflow.com/questions/9025942/powershell-psboundparameters-not-available-in-debug-context
        'ValidConsmName', 'ValidConsmProd' | ForEach-Object {
                if ($PSBoundParameters.ContainsKey($_)) {
                        switch ($_) {
                        'ValidConsmName' {
                            $ValidConsmName = "<ValidConsmName>$($PSBoundParameters[$_])</ValidConsmName>"
                        }
                        'ValidConsmProd' {
                            $ValidConsmProd = "<ValidConsmProd>$($PSBoundParameters[$_])</ValidConsmProd>"
                        }
                        default { }
                    }
                }
            }
           
        $rawXmlTemplate = @"

<CurrRateFeeSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">
          <SrchMsgRqHdr>
                    <jXchangeHdr>
                              <JxVer>2021.0.01</JxVer>
                              <AuditUsrId>jXsupport</AuditUsrId>
                              <AuditWsId>TestTool</AuditWsId>
                              <ConsumerName>JackHenry</ConsumerName>
                              <ConsumerProd>JXTEST</ConsumerProd>
                              <jXLogTrackingId>00848003-6673-1a0f-b55e-0004ac19db9d</jXLogTrackingId>
                              <InstRtId>083002177</InstRtId>
                              <InstEnv>TEST</InstEnv>
                              <BusCorrelId>00849003-6673-1a0f-b55e-0004ac19db9d</BusCorrelId>
                              $ValidConsmName
                              $ValidConsmProd
                    </jXchangeHdr>
                    <MaxRec>10</MaxRec>
                    <Cursor>1</Cursor>
          </SrchMsgRqHdr>
          <FinInstRtId>120064767</FinInstRtId>
          <FundMthdType>OutgoingWire</FundMthdType>
          <FundSchedType>Rate</FundSchedType>
          <CurrType>EUR</CurrType>
</CurrRateFeeSrch>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.CurrRateFeeSrch.SrchMsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.CurrRateFeeSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.CurrRateFeeSrch.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.CurrRateFeeSrch.SrchMsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.CurrRateFeeSrch.SrchMsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.CurrRateFeeSrch.SrchMsgRqHdr.jXchangeHdr.BusCorrelId = $BusCorrelId
        $request.CurrRateFeeSrch.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = $BusCorrelId
        
        $request.CurrRateFeeSrch.SrchMsgRqHdr.MaxRec = $MaxRec
        $request.CurrRateFeeSrch.FinInstRtId = $FinInstRtId

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
