<#
.SYNOPSIS
   Performs a standardized EntityMatchBatchInq call to the jXchange web services.
.DESCRIPTION
   Sends an XML EntityMatchBatchInq operation to ServiceGateway
.EXAMPLE
   Test-SgEntityMatchBatchInq -ServerName $ServerName -UserName $Username -Password $Password -InstRtId 123456788 -InstEnv PROD
.COMPONENT
   TestWSTT
#>
function Test-SgEntityMatchBatchInq {
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

        # Phone Number
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $AuditUsrId = "HALLJ",

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

<EntityMatchBatchInq xmlns="http://jackhenry.com/jxchange/TPG/2008">   
    <MsgRqHdr>    
        <jXchangeHdr>     
            <JxVer>R2017.4</JxVer>     
            <AuditUsrId>HALLJ</AuditUsrId>     
            <AuditWsId>QPADEV007P</AuditWsId>     
            <ConsumerName>JHA</ConsumerName>     
            <ConsumerProd>Silverlake</ConsumerProd>     
            <jXLogTrackingId></jXLogTrackingId>     
            <InstRtId>064207946</InstRtId>     
            <InstEnv>PROD</InstEnv>     
            <BusCorrelId></BusCorrelId>     
            <WorkflowCorrelId></WorkflowCorrelId>     
            <ValidConsmName>JHA</ValidConsmName>     
            <ValidConsmProd>Silverlake</ValidConsmProd>
        </jXchangeHdr>
    </MsgRqHdr>   
    <EntityBatchSrcType>Cust_Addr</EntityBatchSrcType>
    <EntityNameArray>   
        <EntityNameRec>  
            <ElemName>CustId</ElemName>  
            <EntityCatType>CustId</EntityCatType>
        </EntityNameRec>
        <EntityNameRec>  
            <ElemName>LegalName</ElemName>  
            <EntityCatType>ComName</EntityCatType>
        </EntityNameRec>
        <EntityNameRec>  
            <ElemName>StreetAddr1</ElemName>  
            <EntityCatType>StreetAddr</EntityCatType>
        </EntityNameRec>
        <EntityNameRec>  
            <ElemName>StreetAddr2</ElemName>  
            <EntityCatType>StreetAddr</EntityCatType>
        </EntityNameRec>
        <EntityNameRec>  
            <ElemName>City</ElemName>  
            <EntityCatType>City</EntityCatType>
        </EntityNameRec>
        <EntityNameRec>  
            <ElemName>StateCode</ElemName>  
            <EntityCatType>StateCode</EntityCatType>
        </EntityNameRec>
        <EntityNameRec>  
            <ElemName>PostalCode</ElemName>  
            <EntityCatType>PostalCode</EntityCatType>
        </EntityNameRec>
    </EntityNameArray>
    <EntityListCodeArray>
        <EntityListCodeRec>  
            <EntityListType>OFAC</EntityListType>
        </EntityListCodeRec>
    </EntityListCodeArray>
    <SelArray>
        <SelRec>  
            <SelOrder>1</SelOrder>  
            <SelCode>Cntry</SelCode>  
            <SelOperand>NE</SelOperand>  
            <SelVal/>
        </SelRec>
    </SelArray>
    <EntityConfdScore>0.85</EntityConfdScore>
    <BirthDtTolr>1</BirthDtTolr>
    <Custom></Custom>
    <Ver_1/>
    <EntityBatchSrcArray>
        <EntityBatchSrcRec>  
            <EntityBatchSrcType>Ln_AcctTitle</EntityBatchSrcType>  
            <EntityNameArray> 
                <EntityNameRec>
                    <ElemName>CustId</ElemName>
                    <EntityCatType>CustId</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>ComName</ElemName>
                    <EntityCatType>ComName</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>StreetAddr1</ElemName>
                    <EntityCatType>StreetAddr</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>StreetAddr2</ElemName>
                    <EntityCatType>StreetAddr</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>City</ElemName>
                    <EntityCatType>City</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>StateCode</ElemName>
                    <EntityCatType>StateCode</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>PostalCode</ElemName>
                    <EntityCatType>PostalCode</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>Cntry</ElemName>
                    <EntityCatType>Cntry</EntityCatType>
                </EntityNameRec>
            </EntityNameArray>
            <SelArray>
                <SelRec>
                    <SelOrder>1</SelOrder>
                    <SelCode>Cntry</SelCode>
                    <SelOperand>NE</SelOperand>
                    <SelVal/>
                </SelRec>
            </SelArray>
        </EntityBatchSrcRec>
        <EntityBatchSrcRec>
            <EntityBatchSrcType>CustDetail</EntityBatchSrcType>
            <EntityNameArray>
                <EntityNameRec>
                    <ElemName>CustId</ElemName>
                    <EntityCatType>CustId</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>ComName</ElemName>
                    <EntityCatType>ComName</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>StreetAddr1</ElemName>
                    <EntityCatType>StreetAddr</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>StreetAddr2</ElemName>
                    <EntityCatType>StreetAddr</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>City</ElemName>
                    <EntityCatType>City</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>StateCode</ElemName>
                    <EntityCatType>StateCode</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>PostalCode</ElemName>
                    <EntityCatType>PostalCode</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>Cntry</ElemName>
                    <EntityCatType>Cntry</EntityCatType>
                </EntityNameRec>
            </EntityNameArray>
            <SelArray>
                <SelRec>
                    <SelOrder>1</SelOrder>
                    <SelCode>Cntry</SelCode>
                    <SelOperand>NE</SelOperand>
                    <SelVal/>
                </SelRec>
            </SelArray>
        </EntityBatchSrcRec>
        <EntityBatchSrcRec>
            <EntityBatchSrcType>Dep_AcctTitle</EntityBatchSrcType>
            <EntityNameArray>
                <EntityNameRec>
                    <ElemName>CustId</ElemName>
                    <EntityCatType>CustId</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>ComName</ElemName>
                    <EntityCatType>ComName</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>StreetAddr1</ElemName>
                    <EntityCatType>StreetAddr</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>StreetAddr2</ElemName>
                    <EntityCatType>StreetAddr</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>Cntry</ElemName>
                    <EntityCatType>Cntry</EntityCatType>
                </EntityNameRec>
            </EntityNameArray>
            <SelArray>
                <SelRec>
                    <SelOrder>1</SelOrder>
                    <SelCode>Cntry</SelCode>
                    <SelOperand>NE</SelOperand>
                    <SelVal/>
                </SelRec>
            </SelArray>
        </EntityBatchSrcRec>
        <EntityBatchSrcRec>
            <EntityBatchSrcType>SafeDep_AcctTitle</EntityBatchSrcType>
            <EntityNameArray>
                <EntityNameRec>
                    <ElemName>CustId</ElemName>
                    <EntityCatType>CustId</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>ComName</ElemName>
                    <EntityCatType>ComName</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>StreetAddr1</ElemName>
                    <EntityCatType>StreetAddr</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>StreetAddr2</ElemName>
                    <EntityCatType>StreetAddr</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>Cntry</ElemName>
                    <EntityCatType>Cntry</EntityCatType>
                </EntityNameRec>
            </EntityNameArray>
            <SelArray>
                <SelRec>
                    <SelOrder>1</SelOrder>
                    <SelCode>Cntry</SelCode>
                    <SelOperand>NE</SelOperand>
                    <SelVal/>
                </SelRec>
            </SelArray>
        </EntityBatchSrcRec>
        <EntityBatchSrcRec>
            <EntityBatchSrcType>TimeDep_AcctTitle</EntityBatchSrcType>
            <EntityNameArray>
                <EntityNameRec>
                    <ElemName>CustId</ElemName>
                    <EntityCatType>CustId</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>ComName</ElemName>
                    <EntityCatType>ComName</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>StreetAddr1</ElemName>
                    <EntityCatType>StreetAddr</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>StreetAddr2</ElemName>
                    <EntityCatType>StreetAddr</EntityCatType>
                </EntityNameRec>
                <EntityNameRec>
                    <ElemName>Cntry</ElemName>
                    <EntityCatType>Cntry</EntityCatType>
                </EntityNameRec>
            </EntityNameArray>
            <SelArray>
                <SelRec>
                    <SelOrder>1</SelOrder>
                    <SelCode>Cntry</SelCode>
                    <SelOperand>NE</SelOperand>
                    <SelVal/>
                </SelRec>
            </SelArray>
        </EntityBatchSrcRec>
    </EntityBatchSrcArray>
</EntityMatchBatchInq>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.EntityMatchBatchInq.MsgRqHdr.jXchangeHdr.AuditUsrId = $AuditUsrId
        $request.EntityMatchBatchInq.MsgRqHdr.jXchangeHdr.AuditWsId = $AuditWsId
        $request.EntityMatchBatchInq.MsgRqHdr.jXchangeHdr.jXLogTrackingId = "jxAutomation_"+ (New-Guid)
        $request.EntityMatchBatchInq.MsgRqHdr.jXchangeHdr.InstRtId = $InstRtId
        $request.EntityMatchBatchInq.MsgRqHdr.jXchangeHdr.InstEnv = $InstEnv
        $request.EntityMatchBatchInq.MsgRqHdr.jXchangeHdr.ValidConsmName = $ValidConsmName
        $request.EntityMatchBatchInq.MsgRqHdr.jXchangeHdr.ValidConsmProd = $ValidConsmProd

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }
}
