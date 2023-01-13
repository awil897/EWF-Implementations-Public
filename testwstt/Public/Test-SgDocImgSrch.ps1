<#
.SYNOPSIS
   Performs a standardized DocImgSrch call to the jXchange web services.
.DESCRIPTION
   Sends an XML DocImgSrch operation to ServiceGateway
.EXAMPLE
   Test-SgDocImgSrch -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgDocImgSrch {
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
        $ValidConsmName = "CSPI",

        # Valid Consumer Prod
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $ValidConsmProd = "Aurora"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<DocImgSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <SrchMsgRqHdr>
        <jXchangeHdr>
            <JxVer>R2013.1.03</JxVer>
            <AuditUsrId>Jxchange</AuditUsrId>
            <AuditWsId>ThirdParty</AuditWsId>
            <jXLogTrackingId>VENDORNAME-[GUID_GOES_HERE]</jXLogTrackingId>
            <ConsumerName>JackHenry</ConsumerName>
            <ConsumerProd>JXTEST</ConsumerProd>
            <InstRtId>111321063</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>CSPI</ValidConsmName>
            <ValidConsmProd>Aurora</ValidConsmProd>
        </jXchangeHdr>
        <MaxRec>2</MaxRec>
    </SrchMsgRqHdr>
    <DocImgIdxArray>
        <DocImgIdx>
            <DocImgIdxName>ShortName</DocImgIdxName>
            <DocImgIdxType>Index</DocImgIdxType>
            <DocImgIdxValue>GRANT HUGH</DocImgIdxValue>
        </DocImgIdx>
    </DocImgIdxArray>
    <IdxOnly>true</IdxOnly>
    <DocImgFilterType>qry_loan</DocImgFilterType>
</DocImgSrch>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.DocImgSrch.SrchMsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.DocImgSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.DocImgSrch.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.DocImgSrch.SrchMsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.DocImgSrch.SrchMsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.DocImgSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.DocImgSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
