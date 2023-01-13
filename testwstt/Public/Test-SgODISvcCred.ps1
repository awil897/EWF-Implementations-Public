<#
.SYNOPSIS
   Performs a standardized ODISvcCred call to the jXchange web services.
.DESCRIPTION
   Sends an XML ODISvcCred operation to ServiceGateway
.EXAMPLE
   Test-SgODISvcCred -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgODISvcCred {
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

<ODISvcCred xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <MsgRqHdr>
        <jXchangeHdr>
            <JxVer>R2013.1.03</JxVer>
            <AuditUsrId>jXsupport</AuditUsrId>
            <AuditWsId>TestTool</AuditWsId>
            <jXLogTrackingId>d278bb25-9768-4dae-9b58-aee5b68051f9</jXLogTrackingId>
            <InstRtId>067016891</InstRtId>
            <InstEnv>PROD</InstEnv>
            <ValidConsmName>JHA</ValidConsmName>
            <ValidConsmProd>iTalk</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>
    <SvcType>SQL</SvcType>
</ODISvcCred>


"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.ODISvcCred.MsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.ODISvcCred.MsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.ODISvcCred.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.ODISvcCred.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.ODISvcCred.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.ODISvcCred.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.ODISvcCred.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }

}
