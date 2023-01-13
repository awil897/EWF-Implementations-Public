<#
.SYNOPSIS
   Performs a standardized WorkflowInstcSrch call to the jXchange web services.
.DESCRIPTION
   Sends an XML WorkflowInstcSrch operation to ServiceGateway
.EXAMPLE
   Test-SgWorkflowInstcSrch -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgWorkflowInstcSrch {
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
        $ValidConsmProd
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<WorkflowInstcSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">
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
        <MaxRec>10</MaxRec>
    </SrchMsgRqHdr>
    <WorkflowName>Basic QC Example</WorkflowName>
    <AttachId>PFN5bkl0ZW1SZWZCYXNlIGk6dHlwZT0iRG9jdW1lbnRJdGVtUmVmIiB4bWxucz0iU3luZXJneUVDTSIgeG1sbnM6aT0iaHR0cDovL3d3dy53My5vcmcvMjAwMS9YTUxTY2hlbWEtaW5zdGFuY2UiPjxEYklkPjE3MjY3MDA4MDwvRGJJZD48RGVzY3JpcHRpb24vPjxGaWxlUm9vbUd1aWQ+Qjk1NkQwNzMtQjdENC00NkEwLTlDNUUtNkFFNkFBOTcwNEREPC9GaWxlUm9vbUd1aWQ+PEZpbGVSb29tSWQ+MTwvRmlsZVJvb21JZD48RmlsZVJvb21OYW1lPlN5bmVyZ3kgRmlsZXJvb208L0ZpbGVSb29tTmFtZT48SXRlbVJlZlR5cGU+RG9jdW1lbnQ8L0l0ZW1SZWZUeXBlPjxOYW1lLz48T3JnR3VpZD5EQzUxOEU1Qy0xMzM0LTQ5NTQtOTlCMS03QzU2NEE2MEY1NUU8L09yZ0d1aWQ+PE9yZ0lkPjA8L09yZ0lkPjxPcmdOYW1lPjAwMDE8L09yZ05hbWU+PFZlcnNpb24+MzwvVmVyc2lvbj48RG9jSWQ+OTUwPC9Eb2NJZD48UGFnZUlkPjgzNjwvUGFnZUlkPjxQYWdlTm8+MTwvUGFnZU5vPjwvU3luSXRlbVJlZkJhc2U+</AttachId>
    <AttachIdType>DocImg</AttachIdType>
</WorkflowInstcSrch>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.WorkflowInstcSrch.SrchMsgRqHdr.jXchangeHdr.AuditUsrId = "jXsupport"
        $request.WorkflowInstcSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $env:COMPUTERNAME
        $request.WorkflowInstcSrch.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.WorkflowInstcSrch.SrchMsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.WorkflowInstcSrch.SrchMsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.WorkflowInstcSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.WorkflowInstcSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
