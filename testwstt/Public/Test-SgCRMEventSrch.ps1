<#
.SYNOPSIS
   Performs a standardized CRMEventSrch call to the jXchange web services.
.DESCRIPTION
   Sends an XML CRMEventSrch operation to ServiceGateway
.EXAMPLE
   Test-SgCRMEventSrch -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgCRMEventSrch {
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
        $ValidConsmProd = "iTalk"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<CRMEventSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <SrchMsgRqHdr>
        <jXchangeHdr>
            <JxVer>R2013.1.03</JxVer>
            <AuditUsrId>AuditUsrId1</AuditUsrId>
            <AuditWsId>AuditWsId1</AuditWsId>
            <InstRtId>221981335</InstRtId>
            <InstEnv>PROD</InstEnv>
            <jXLogTrackingId>d278bb25-9768-4dae-9b58-aee5b68051f9</jXLogTrackingId>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>jhaEnterprise Workflow</ValidConsmProd>
        </jXchangeHdr>
        <MaxRec>1</MaxRec>
    </SrchMsgRqHdr>
    <CRMEventType>CRMEventType1</CRMEventType>
    <AccountId>
        <AcctId>AcctId1</AcctId>
        <AcctType>AcctType1</AcctType>
    </AccountId>
</CRMEventSrch>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.CRMEventSrch.SrchMsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.CRMEventSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.CRMEventSrch.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.CRMEventSrch.SrchMsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.CRMEventSrch.SrchMsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.CRMEventSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.CRMEventSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }

}
