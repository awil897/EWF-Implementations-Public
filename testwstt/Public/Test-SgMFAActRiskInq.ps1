<#
.SYNOPSIS
   Performs a standardized MFAActRiskInq call to the jXchange web services.
.DESCRIPTION
   Sends an XML MFAActRiskInq operation to ServiceGateway
.EXAMPLE
   Test-SgMFAActRiskInq -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD -RSAId tompkinstrustUAT1 -RSAOrgId 7701B
.COMPONENT
   TestWSTT
#>
function Test-SgMFAActRiskInq {
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
        $ValidConsmProd = "Aurora",

        # RSAId
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $RSAId = "[Will look like tompkinstrustUAT]",

        # RSAOrgId
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $RSAOrgId = "[Will look like 7701T]"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<MFAActRiskInq xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>2015.0.08</JxVer>
            <AuditUsrId>AuditUsrId1</AuditUsrId>
            <AuditWsId>AuditWsId1</AuditWsId>
            <jXLogTrackingId>a976fd49-4d3a-4b96-bcc1-d6da39c8b031</jXLogTrackingId>
            <InstRtId>[ABA]</InstRtId>
            <InstEnv>[Environment]</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>Silverlake</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <TrnOrignChan>Intnet</TrnOrignChan>
    <MFAEventInfoArray>
        <MFAEventInfo>
            <MFAActEventType>LogIn</MFAActEventType>
        </MFAEventInfo>
    </MFAEventInfoArray>
    <SvcPrvdInfo>
        <JHAConsumer>
            <RSAId>[Will look like tompkinstrustUAT]</RSAId>
            <RSAOrgId>[Will look like 7701T]</RSAOrgId>
        </JHAConsumer>
    </SvcPrvdInfo>
</MFAActRiskInq>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.MFAActRiskInq.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.MFAActRiskInq.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.MFAActRiskInq.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.MFAActRiskInq.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.MFAActRiskInq.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.MFAActRiskInq.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.MFAActRiskInq.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $request.MFAActRiskInq.SvcPrvdInfo.JHAConsumer.RSAId = $RSAId
        $request.MFAActRiskInq.SvcPrvdInfo.JHAConsumer.RSAOrgId = $RSAOrgId

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
