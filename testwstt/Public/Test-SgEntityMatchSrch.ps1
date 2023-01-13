<#
.SYNOPSIS
   Performs a standardized EntityMatchSrch call to the jXchange web services.
.DESCRIPTION
   Sends an XML EntityMatchSrch operation to ServiceGateway
.EXAMPLE
   Test-SgEntityMatchSrch -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgEntityMatchSrch {
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

        # AuditUsr Id
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $AuditUsrId = "HALLJ",

        # AuditWs Id
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $AuditWsId = "QPADEV007P"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<EntityMatchSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">        
    <SrchMsgRqHdr>           
        <jXchangeHdr>     
            <JxVer>R2017.4</JxVer>     
            <AuditUsrId>HALLJ</AuditUsrId>     
            <AuditWsId>QPADEV007P</AuditWsId>     
            <ConsumerName>JHA</ConsumerName>     
            <ConsumerProd>Silverlake</ConsumerProd>     
            <Ver_1/>     
            <jXLogTrackingId></jXLogTrackingId>     
            <Ver_2/>     
            <InstRtId>064207946</InstRtId>     
            <InstEnv>PROD</InstEnv>     
            <Ver_3/>     
            <BusCorrelId></BusCorrelId>     
            <Ver_4/>     
            <WorkflowCorrelId></WorkflowCorrelId>     
            <Ver_5/>     
            <ValidConsmName>JHA</ValidConsmName>     
            <ValidConsmProd>Silverlake</ValidConsmProd>
        </jXchangeHdr>           
        <MaxRec>1000</MaxRec>
    </SrchMsgRqHdr>        
    <EntityName>Hanna Jock</EntityName>        
    <Ver_1/>
</EntityMatchSrch>


"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.EntityMatchSrch.SrchMsgRqHdr.jXchangeHdr.AuditUsrId = $AuditUsrId
        $request.EntityMatchSrch.SrchMsgRqHdr.jXchangeHdr.AuditWsId = $AuditWsId
        $request.EntityMatchSrch.SrchMsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.EntityMatchSrch.SrchMsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.EntityMatchSrch.SrchMsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.EntityMatchSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.EntityMatchSrch.SrchMsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
