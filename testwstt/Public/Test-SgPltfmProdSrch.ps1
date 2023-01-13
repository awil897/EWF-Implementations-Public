<#
.SYNOPSIS
   Performs a standardized TellerCustSrch call to the jXchange web services.
.DESCRIPTION
   Sends an XML TellerCustSrch operation to ServiceGateway
.EXAMPLE
   Test-SgTellerCustSrch -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgPltfmProdSrch {
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

<PltfmProdSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <SrchMsgRqHdr>
        <jXchangeHdr>
            <JxVer>2018.7.03</JxVer>
            <AuditUsrId>AuditUsrId1</AuditUsrId>
            <AuditWsId>AuditWsId1</AuditWsId>
            <jXLogTrackingId>VENDORNAME-[GUID_GOES_HERE]</jXLogTrackingId>
            <InstRtId>113102552</InstRtId>
            <InstEnv>Prod</InstEnv>
            <ValidConsmName>Bob</ValidConsmName>
            <ValidConsmProd>Bob</ValidConsmProd>
        </jXchangeHdr>
        <MaxRec>1</MaxRec>
    </SrchMsgRqHdr>
</PltfmProdSrch>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.PltfmProdSrch.SrchMsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.PltfmProdSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.PltfmProdSrch.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.PltfmProdSrch.SrchMsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.PltfmProdSrch.SrchMsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.PltfmProdSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.PltfmProdSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
