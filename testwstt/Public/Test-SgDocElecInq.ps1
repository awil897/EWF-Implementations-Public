<#
.SYNOPSIS
   Performs a standardized DocElecInq call to the jXchange web services.
.DESCRIPTION
   Sends an XML DocElecInq operation to ServiceGateway
.EXAMPLE
   Test-SgDocElecInq -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgDocElecInq {
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

<DocElecInq xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>2018.7.03</JxVer>
            <AuditUsrId>AuditUsrId1</AuditUsrId>
            <AuditWsId>AuditWsId1</AuditWsId>
            <jXLogTrackingId>VENDORNAME-[GUID_GOES_HERE]</jXLogTrackingId>
            <InstRtId>081905085</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>Silverlake</ValidConsmProd>
        </jXchangeHdr>
        <AuthenUsrCred>
            <Security xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
                <Assertion xmlns="urn:oasis:names:tc:SAML:2.0:assertion" ID="my_identifier" Version="2.0" IssueInstant="2004-12-05T09:22:05Z">
                    <AttributeStatement>
                        <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name">
                            <AttributeValue>userName</AttributeValue>
                        </Attribute>
                        <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/role">
                            <AttributeValue></AttributeValue>
                        </Attribute>
                        <Attribute Name="http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname">
                            <AttributeValue>test\user</AttributeValue>
                        </Attribute>
                    </AttributeStatement>
                </Assertion>
            </Security>
        </AuthenUsrCred>
    </MsgRqHdr>
    <DocRcptId>1</DocRcptId>
    <ConsmDocId>1</ConsmDocId>
</DocElecInq>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.DocElecInq.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.DocElecInq.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.DocElecInq.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.DocElecInq.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.DocElecInq.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.DocElecInq.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.DocElecInq.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
