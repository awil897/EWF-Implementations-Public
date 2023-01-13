<#
.SYNOPSIS
   Performs a standardized CardRwrdlinq call to the jXchange web services.
.DESCRIPTION
   Sends an XML CardRwrdlinq operation to ServiceGateway
.EXAMPLE
   Test-SgCrCardRwrdlinq -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD -CrCardAcctId 4340790000000049
.COMPONENT
   TestWSTT
#>
function Test-SgCrCardRwrdlinq {
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
        $ValidConsmProd = "iTalk",

        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
        [string]
        $CrCardAcctId
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<CrCardRwrdInq xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <AuditUsrId>jXsupport</AuditUsrId>
            <AuditWsId>TestTool</AuditWsId>
            <jXLogTrackingId>d278bb25-9768-4dae-9b58-aee5b68051f9</jXLogTrackingId>
            <InstRtId>067016891</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>BannoMobile</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <CrCardAcctId>4340790000000049</CrCardAcctId>
    <Custom></Custom>
</CrCardRwrdInq>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.CrCardRwrdInq.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.CrCardRwrdInq.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.CrCardRwrdInq.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.CrCardRwrdInq.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.CrCardRwrdInq.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.CrCardRwrdInq.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.CrCardRwrdInq.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd
        $request.CrCardRwrdInq.CrCardAcctId = $CrCardAcctId

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }

}
