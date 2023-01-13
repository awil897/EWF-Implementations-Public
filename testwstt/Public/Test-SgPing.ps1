<#
.SYNOPSIS
   Performs a standardized Ping call to the jXchange web services.
.DESCRIPTION
   Sends an XML Ping operation to ServiceGateway
.EXAMPLE
   Test-SgPing -ServerName $ServerName -UserName $Username -Password $Password -Message "Hello World"
.COMPONENT
   TestWSTT
#>
function Test-SgPing {
    [CmdletBinding()]
    Param
    (
        # Server Name of the ServiceGateway Server
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]        
        [string]
        $ServerName,

        # Username to access the service
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]
        $UserName,

        # Password to access the service
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [string]
        $Password,

        # Ping Message.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [string]
        $Message = "Ping Message Request"
    )

    Begin
    {

    }
    Process
    {
        $rawXmlTemplate = @"

<Ping xmlns="http://jackhenry.com/jxchange/TPG/2008">
    <PingRq>I am Testing Ping Here, Hello?</PingRq>
</Ping>

"@

        $request = Get-XmlOperation -XmlString $rawXmlTemplate -CleanXml
        $request.Ping.PingRq = $Message

        $credPass = $Password | ConvertTo-SecureString -Force -AsPlainText
        $connection = New-ServiceConnection -UserName $UserName -Password $credPass -ServerName $ServerName #-EndPointSvc "https://jx15padapter.idg.jha-sys.com/jxchange/2008/ServiceGateway/ServiceGateway.svc"

        $response = Send-XmlOperation -XmlRequest $request -ServiceConnection $connection -Verbose

        $response
    }
    End
    {
    }

}

