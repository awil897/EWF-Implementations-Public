Add-Type -AssemblyName System.Windows.Forms
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@

[System.Windows.Forms.Application]::EnableVisualStyles()


$ErrorActionPreference = "Continue"

Import-Module PowershellJMC


$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = New-Object System.Drawing.Point(894,600)
$Form.text                       = "Synergy/EWF Integration Tests"
$Form.TopMost                    = $false
$Form.Icon                       = ([System.Drawing.Icon]$this.Icon)


$PSUsername                        = New-Object system.Windows.Forms.TextBox
$PSUsername.Name                   = "PSUsername"
$PSUsername.text                   = ""
$PSUsername.multiline              = $false
$PSUsername.width                  = 160
$PSUsername.height                 = 20
$PSUsername.location               = New-Object System.Drawing.Point(151,10)
$PSUsername.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',11)

$PSPassBox                         = New-Object system.Windows.Forms.TextBox
$PSPassBox.Name                    = "PSPassbox"
$PSPassBox.Text                    = ""
$PSPassBox.PasswordChar            = "*"
$PSPassBox.multiline               = $false
$PSPassBox.width                   = 160
$PSPassBox.height                  = 20
$PSPassBox.location                = New-Object System.Drawing.Point(151,40)
$PSPassBox.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',11)

$EAUsername                        = New-Object system.Windows.Forms.TextBox
$EAUsername.name                   = "EAUsername"
$EAUsername.text                   = ""
$EAUsername.multiline              = $false
$EAUsername.width                  = 160
$EAUsername.height                 = 20
$EAUsername.location               = New-Object System.Drawing.Point(151,90)
$EAUsername.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',11)

$EAPassBox                         = New-Object system.Windows.Forms.TextBox
$EAPassBox.name                    = "eapassbox"
$EAPassBox.Text                    = ""
$EAPassBox.PasswordChar            = "*"
$EAPassBox.multiline               = $false
$EAPassBox.width                   = 160
$EAPassBox.height                  = 20
$EAPassBox.location                = New-Object System.Drawing.Point(151,120)
$EAPassBox.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',11)

$Username                        = New-Object system.Windows.Forms.TextBox
$Username.Name                   = "username"
$Username.text                   = ""
$Username.multiline              = $false
$Username.width                  = 160
$Username.height                 = 20
$Username.location               = New-Object System.Drawing.Point(151,170)
$Username.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',11)

$PassBox                         = New-Object system.Windows.Forms.TextBox
$PassBox.name                    = "passbox"
$PassBox.Text                    = ""
$PassBox.PasswordChar            = "*"
$PassBox.multiline               = $false
$PassBox.width                   = 160
$PassBox.height                  = 20
$PassBox.location                = New-Object System.Drawing.Point(151,200)
$PassBox.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',11)

$JxBox                           = New-Object system.Windows.Forms.TextBox
$jxbox.Name                      = "jxbox"
$JxBox.multiline                 = $false
$JxBox.text                      = "jxchange.gadev.jha-sys.com"
$JxBox.width                     = 160
$JxBox.height                    = 20
$JxBox.location                  = New-Object System.Drawing.Point(151,250)
$JxBox.Font                      = New-Object System.Drawing.Font('Microsoft Sans Serif',11)

$EnvBox                          = New-Object system.Windows.Forms.TextBox
$EnvBox.name                     = "envbox"
$EnvBox.Text                     = "PROD"
$EnvBox.multiline                = $false
$EnvBox.width                    = 100
$EnvBox.height                   = 20
$EnvBox.location                 = New-Object System.Drawing.Point(209,316)
$EnvBox.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',11)

$AbaBox                          = New-Object system.Windows.Forms.TextBox
$AbaBox.name                     = "ababox"
$AbaBox.Text                     = "123456789"
$AbaBox.multiline                = $false
$AbaBox.width                    = 114
$AbaBox.height                   = 20
$AbaBox.location                 = New-Object System.Drawing.Point(197,369)
$AbaBox.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',11)

$PSUserLabel                       = New-Object system.Windows.Forms.Label
$PSUserLabel.text                  = "PS Username"
$PSUserLabel.AutoSize              = $true
$PSUserLabel.width                 = 25
$PSUserLabel.height                = 10
$PSUserLabel.location              = New-Object System.Drawing.Point(20,10)
$PSUserLabel.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$PSPassLabel                       = New-Object system.Windows.Forms.Label
$PSPassLabel.text                  = "PS Password"
$PSPassLabel.AutoSize              = $true
$PSPassLabel.width                 = 25
$PSPassLabel.height                = 10
$PSPassLabel.location              = New-Object System.Drawing.Point(20,40)
$PSPassLabel.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$EAUserLabel                       = New-Object system.Windows.Forms.Label
$EAUserLabel.text                  = "EA Username"
$EAUserLabel.AutoSize              = $true
$EAUserLabel.width                 = 25
$EAUserLabel.height                = 10
$EAUserLabel.location              = New-Object System.Drawing.Point(20,90)
$EAUserLabel.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$EAPassLabel                       = New-Object system.Windows.Forms.Label
$EAPassLabel.text                  = "EA Password"
$EAPassLabel.AutoSize              = $true
$EAPassLabel.width                 = 25
$EAPassLabel.height                = 10
$EAPassLabel.location              = New-Object System.Drawing.Point(20,120)
$EAPassLabel.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$UserLabel                       = New-Object system.Windows.Forms.Label
$UserLabel.text                  = "SG Username"
$UserLabel.AutoSize              = $true
$UserLabel.width                 = 25
$UserLabel.height                = 10
$UserLabel.location              = New-Object System.Drawing.Point(20,170)
$UserLabel.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$PassLabel                       = New-Object system.Windows.Forms.Label
$PassLabel.text                  = "SG Password"
$PassLabel.AutoSize              = $true
$PassLabel.width                 = 25
$PassLabel.height                = 10
$PassLabel.location              = New-Object System.Drawing.Point(20,200)
$PassLabel.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$JxLabel                         = New-Object system.Windows.Forms.Label
$JxLabel.text                    = "JX Farm"
$JxLabel.AutoSize                = $true
$JxLabel.width                   = 25
$JxLabel.height                  = 10
$JxLabel.location                = New-Object System.Drawing.Point(38,252)
$JxLabel.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$EnvironmentLabel                = New-Object system.Windows.Forms.Label
$EnvironmentLabel.text           = "Environment"
$EnvironmentLabel.AutoSize       = $true
$EnvironmentLabel.width          = 25
$EnvironmentLabel.height         = 10
$EnvironmentLabel.location       = New-Object System.Drawing.Point(38,318)
$EnvironmentLabel.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$AbaLabel                        = New-Object system.Windows.Forms.Label
$AbaLabel.text                   = "ABA"
$AbaLabel.AutoSize               = $true
$AbaLabel.width                  = 25
$AbaLabel.height                 = 10
$AbaLabel.location               = New-Object System.Drawing.Point(41,371)
$AbaLabel.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$ListButton                      = New-Object system.Windows.Forms.Button
$ListButton.text                 = "Perform Test"
$ListButton.width                = 161
$ListButton.height               = 30
$ListButton.location             = New-Object System.Drawing.Point(92,490)
$ListButton.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$ProviderComboBox                = New-Object system.Windows.Forms.ComboBox
$ProviderComboBox.width          = 192
$ProviderComboBox.height         = 20
$ProviderComboBox.location       = New-Object System.Drawing.Point(76,439)
$ProviderComboBox.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',12)


#$DataGridView1                   = New-Object system.Windows.Forms.DataGridView
#$DataGridView1.width             = 517
#$DataGridView1.height            = 433
#$DataGridView1.location          = New-Object System.Drawing.Point(357,11)
$DataGridView1                   = New-Object System.Windows.Forms.RichTextBox 
#$DataGridView1.Multiline         = $True;
$DataGridView1.Location          = New-Object System.Drawing.Size(357,11) 
$DataGridView1.Size              = New-Object System.Drawing.Size(517,533)
$DataGridView1.Scrollbars        = "Vertical" 



if($selected){Remove-Variable selected}

$Form.controls.AddRange(@($Username,$PassBox,$PSUsername,$PSPassBox,$EAUsername,$EAPassBox,$UserLabel,$PassLabel,$PSUserLabel,$PSPassLabel,$EAUserLabel,$EAPassLabel,$JxBox,$EnvBox,$AbaBox,$ListButton,$ProviderComboBox,$DataGridView1,$AbaLabel,$EnvironmentLabel,$JxLabel))
$ProviderComboBox.items.Add("Choose a test")
$ProviderComboBox.Items.add("Synergy Server Tests")
$ProviderComboBox.Items.add("Synergy-to-SG")
$ProviderComboBox.Items.add("Synergy-to-PS")
$ProviderComboBox.Items.add("Synergy-to-EA")
$ProviderComboBox.Items.add("SG-to-Synergy")
$ProviderComboBox.Items.add("SG-to-EWF")

$ProviderComboBox.SelectedIndex = $ProviderComboBox.FindStringExact("Choose a test")
$ProviderComboBox.Add_SelectedValueChanged({ 
 
    #$pipeline = $_ | ConvertTo-Json
    #$infohash = $this | ConvertTo-Json
    $script:selected = $ProviderComboBox.SelectedItem 
    
    #$DataGridView1.font = "Lucida Console"
    #"$selected"
    #"$infohash"

})
$tooltip1 = New-Object System.Windows.Forms.ToolTip
$ShowHelp={
	#display popup help
    #each value is the name of a control on the form.
	Switch ($this.name) {
		"PSUsername"  {$tip = "Enter the Username used in jXchange Integration Maintenance, Persistent Storage tab"}
        "PSPassbox"  {$tip = "Enter the Password used in jXchange Integration Maintenance, Persistent Storage tab"}
        "eausername" {$tip = "Enter the Username used in jXchange Integration Maintenance, Enterprise Audit tab"}
        "eapassbox"  {$tip = "Enter the Password used in jXchange Integration Maintenance, Enterprise Audit tab"}
        "username"  {$tip = "Enter the Username used in jXchange Integration Maintenance, Service Gateway tab"}
        "passbox"  {$tip = "Enter the Password used in jXchange Integration Maintenance, Service Gateway tab"}
        "jxbox"  {$tip = "Enter the FQDN of the JXCHANGE farm (leave off any prefix like https:\\)"}
        "envbox"  {$tip = "Enter the Enivronment variable that Synergy is using for this Institution"}
        "ababox"  {$tip = "Enter the Routing Number that Synergy is using for this Institution"}

	}
	$tooltip1.SetToolTip($this,$tip)
}

$PSUsername.add_mousehover($ShowHelp)
$PSPassBox.add_mousehover($ShowHelp)
$EAUsername.add_mousehover($ShowHelp)
$EAPassBox.add_mousehover($ShowHelp)
$Username.add_mousehover($ShowHelp)
$PassBox.add_mousehover($ShowHelp)
$JxBox.add_mousehover($ShowHelp)
$EnvBox.add_mousehover($ShowHelp)
$ababox.add_mousehover($ShowHelp)

$ListButton.Add_Click({ Invoke-Test })
#$DataGridView1.font = "Lucida Console"
function Invoke-Test {
    switch ($selected) {
        "Choose a test"  {$DataGridView1.Text = "Please select a test from the dropdown menu"; break}
        "Synergy Server Tests"  {
            $DataGridView1.Text = ""
            Test-SynNode; break}
        "Synergy-to-SG"  {
            $DataGridView1.Text = ""
            Test-SG -jXchangeFarm $jxbox.text -user $Username.text -pass $PassBox.Text -aba $AbaBox.Text -env $EnvBox.text; break
        }
        "Synergy-to-PS"  {
            $DataGridView1.Text = ""
            Test-PS -user $PSUsername.text -pass $PSPassBox.Text; break
        }
        "Synergy-to-EA"  {
            $DataGridView1.Text = ""
            Test-EA -user $EAUsername.text -pass $EAPassBox.Text; break
        }
        "SG-to-Synergy"  {
            $DataGridView1.Text = ""
            Test-SvcDictSrch -jXchangeFarm $jxbox.text -user $Username.text -pass $PassBox.Text -aba $AbaBox.Text -env $EnvBox.text; break
        }
        "SG-to-EWF"  {
            $DataGridView1.Text = ""
            Test-PubWorkflowSrch -jXchangeFarm $jxbox.text -user $Username.text -pass $PassBox.Text -aba $AbaBox.Text -env $EnvBox.text; break
        }
        default {$DataGridView1.Text = "Please select a test from the dropdown menu"; break}
     }
}
function Add-Text {
    param(
    [Parameter (Mandatory = $true)] [String]$string,
    [Parameter (Mandatory = $false)] [String]$color = "black"
    )

    $DataGridView1.SelectionColor = [Drawing.Color]::$color
    $DataGridView1.AppendText("$string`n")
}
function Add-Line {
    $DataGridView1.AppendText("`n")
}
function Test-TLSConnection {
    [OutputType([psobject],[bool])]
    param (
        # Specifies the DNS name of the computer to test
        [Parameter(Mandatory=$true,
                    ValueFromPipeline=$true,
                    Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("Server","Name","HostName")]
        $ComputerName,

        # Specifies the IP Address of the computer to test. Can be useful if no DNS record exists.
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Net.IPAddress]
        $IPAddress,

        # Specifies the TCP port on which the TLS service is running on the computer to test
        [Parameter(Mandatory=$false,
                    Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("RemotePort")]
        [ValidateRange(1,65535)]
        $Port = '443',

        # Specifies a path to a file (.cer) where the certificate should be saved if the SaveCert switch parameter is used
        [Parameter(Mandatory=$false,
                    Position=3)]
        [System.IO.FileInfo]
        $FilePath = "$env:TEMP\$computername.cer",

        [Parameter(Mandatory=$false,
                    Position=2)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Default','Ssl2','Ssl3','Tls','Tls11','Tls12')]
        [System.Security.Authentication.SslProtocols[]]
        $Protocol = 'Tls12',

        # Check revocation information for remote certificate. Default is true.
        [Parameter(Mandatory=$false)]
        [bool]$CheckCertRevocationStatus = $true,

        # Saves the remote certificate to a file, the path can be specified using the FilePath parameter
        [switch]
        $SaveCert,

        # Only returns true or false, instead of a custom object with some information.
        [Alias("Silent")]
        [switch]
        $Quiet
    )

    begin { 
        function Get-SanAsArray {
            param($io)
            $io.replace("DNS Name=","").split("`n") 
        }
    }

    process {
        if(-not($IPAddress)){
            # if no IP is specified, use the ComputerName
            [string]$IPAddress = $ComputerName
        }

        try {
            $TCPConnection = New-Object System.Net.Sockets.Tcpclient($($IPAddress.ToString()), $Port)
            Add-Text -string "TCP connection has succeeded"
            $TCPStream     = $TCPConnection.GetStream()
            try {
                $SSLStream = New-Object System.Net.Security.SslStream($TCPStream)
                #Add-Text -string "SSL connection has succeeded with $($SSLStream.SslProtocol)"
                try {
                    # AuthenticateAsClient (string targetHost, X509CertificateCollection clientCertificates, SslProtocols enabledSslProtocols, bool checkCertificateRevocation)
                    $SSLStream.AuthenticateAsClient($ComputerName,$null,$Protocol,$CheckCertRevocationStatus)
                    Add-Text -string "SSL authentication has succeeded"
                } catch {
                    Add-Text -string "There's a problem with SSL authentication to $ComputerName `n$_"
                    Add-Text -string "Tried to connect using $Protocol protocol. Try another protocol with the -Protocol parameter."
                    return $false
                }
                $certificate = $SSLStream.get_remotecertificate()
                $certificateX509 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certificate)
                $SANextensions = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection($certificateX509)
                $SANextensions = $SANextensions.Extensions | Where-Object {$_.Oid.FriendlyName -eq "subject alternative name"}

                $data = [ordered]@{
                    'ComputerName' = $ComputerName;
                    'Port' = $Port;
                    'Protocol' = $SSLStream.SslProtocol;
                    'CheckRevocation' = $SSLStream.CheckCertRevocationStatus;
                    'Issuer' = $SSLStream.RemoteCertificate.Issuer;
                    'Subject' = $SSLStream.RemoteCertificate.Subject;
                    'SerialNumber' = $SSLStream.RemoteCertificate.GetSerialNumberString();
                    'ValidTo' = $SSLStream.RemoteCertificate.GetExpirationDateString();
                    'SAN' = (Get-SanAsArray -io $SANextensions.Format(1));
                }

                if($Quiet) {
                    Write-Output $true
                } else {
                    Write-Output (New-Object -TypeName PSObject -Property $Data)
                }
                if ($SaveCert) {
                    #Add-Text -string "Saving cert to $FilePath" -ForegroundColor Yellow
                    [system.io.file]::WriteAllBytes($FilePath,$certificateX509.Export("cer"))
                }

            } catch {
                Add-Text -string "$ComputerName doesn't support SSL connections at TCP port $Port `n$_"
            }

        } catch {
            $exception = New-Object System.Net.Sockets.SocketException
            $errorcode = $exception.ErrorCode
            Add-Text -string "TCP connection to $ComputerName failed, error code:$errorcode"
            Add-Text -string "Error details: $exception"
            Add-Line
        }
        
    } # process

    end {
        # cleanup
        Write-Verbose "Cleanup sessions"
        if ($SSLStream) {
            $SSLStream.Dispose()
        }
        if ($TCPStream) {
            $TCPStream.Dispose()
        }
        if ($TCPConnection) {
            $TCPConnection.Dispose()
        }
    }
}
Function Test-ADAuthentication {
    param(
        $username,
        $password)
    
    (New-Object DirectoryServices.DirectoryEntry "",$username,$password).psbase.name -ne $null
}
function Test-PS {
    param(
    [Parameter (Mandatory = $false)] [String]$user,
    [Parameter (Mandatory = $false)] [String]$pass
    )

    Try{
        $dnsTest = Resolve-DnsName $jxbox.text -NoHostsFile -DnsOnly
    }
    Catch{
        $dnsTest = $false
        Add-Text -string "DNS failure for $($jxbox.text). Is this the right URL?" -color "red"
    }
    if ($dnsTest -notLike $false){
        Try {
            $jxTlsCheck = Test-TLSConnection -ComputerName $($jxbox.text)
            $jxCheck = $true
            Add-Line
        }
        Catch {
            $jxCheck = $false
            Add-Text -string "Error establishing TLS session with https://$($jxbox.text)" -color "red"
            Add-line
        }
    }
    Try {
        
        Add-Text -string "Checking credential for $($user)"
        $test = Test-ADAuthentication -username $user -password $pass
        
        if ($test -like $true){
            Add-Text -string "Success!" -color "green"
            Add-Text -string "Credential for $user is valid"
            $credCheck = $true
            Add-Line
        }
        elseif ($test -like $false){
            throw "invalid"
        }
    }
    Catch {
        if ($error[0].FullyQualifiedErrorID -eq "invalid") {
                Add-Text -string "The credential you entered for the SG may be invalid, double-check the password" -color "red"
                $credCheck = $false
                Add-Text -string "Attempting to get account properties from Active Directory" 
                Import-Module ActiveDirectory
                $userObj = Get-ADUser -Filter "userPrincipalName -like '$($user)'" -Properties *
                if ($userObj -like $null){Add-Text -string "$($user) not found in Active Directory" -color "red"}
                else {
                    Add-Text -string "Enabled = $($userObj.enabled)"
                    Add-Text -string "LockedOut = $($userObj.lockedout)"
                    Add-Text -string "Password Never Expires = $($userObj.Passwordneverexpires)"
                    Add-Text -string "Expired = $($userObj.PasswordExpired)"
                    Add-Line
                }
            }
        else {
            Add-Text -string "I'm having trouble auto-validating the credential for $($username.text). You may need to verify this manually" -color "red"
            Add-Line
        }
    }

    if (($jxCheck -notlike $false)-and ($credCheck -notlike $false)){
        Add-Text -string "Attempting to contact Persistent Storage"
    Add-Line
    $psPass = ConvertTo-SecureString $PSPassBox.text -AsPlainText -Force
    $connection = New-JMCConnection -JMCServerName $JxBox.Text -JMCUserName $PSUsername.Text -JMCPassword $psPass #if no connection, it defaults to localhost
    Try {
        $user = (Get-PSUser -JMCConnection $connection -UserName $PSUsername.Text).Operations
        $permissionsString = [String]::Join(', ', $user)
        Add-Text -string "Success!" -color "green"
        Add-Text -string "User was found in Persistent Storage and has the following permissions:"
        Add-Text -string $permissionsString
        Add-Line
    }
    Catch {
        Add-Text -string "Failure!" -color "red"
        Add-Text -string "Error Checking Persistent Storage"
        Add-Line
    }
}

}
function Test-EA {
    param(
    [Parameter (Mandatory = $false)] [String]$user,
    [Parameter (Mandatory = $false)] [String]$pass
    )

    Try{
        $dnsTest = Resolve-DnsName $jxbox.text -NoHostsFile -DnsOnly
    }
    Catch{
        $dnsTest = $false
        Add-Text -string "DNS failure for $($jxbox.text). Is this the right URL?" -color "red"
    }
    if ($dnsTest -notLike $false){
        Try {
            $jxTlsCheck = Test-TLSConnection -ComputerName $($jxbox.text)
            $jxCheck = $true
            Add-line
        }
        Catch {
            $jxCheck = $false
            Add-Text -string "Error establishing TLS session with https://$($jxbox.text)" -color "red"
            Add-line
        }
    }
    Try {
        
        Add-Text -string "Checking credential for $($user)"
        $test = Test-ADAuthentication -username $user -password $pass
        
        if ($test -like $true){
            Add-Text -string "Success!" -color "green"
            Add-Text -string "Credential for $user is valid"
            $credCheck = $true
            Add-Line
        }
        elseif ($test -like $false){
            throw "invalid"
        }
    }
    Catch {
        if ($error[0].FullyQualifiedErrorID -eq "invalid") {
                Add-Text -string "The credential you entered for the SG may be invalid, double-check the password" -color "red"
                $credCheck = $false
                Add-Text -string "Attempting to get account properties from Active Directory" 
                Import-Module ActiveDirectory
                $userObj = Get-ADUser -Filter "userPrincipalName -like '$($user)'" -Properties *
                if ($userObj -like $null){Add-Text -string "$($user) not found in Active Directory" -color "red"}
                else {
                    Add-Text -string "Enabled = $($userObj.enabled)"
                    Add-Text -string "LockedOut = $($userObj.lockedout)"
                    Add-Text -string "Password Never Expires = $($userObj.Passwordneverexpires)"
                    Add-Text -string "Expired = $($userObj.PasswordExpired)"
                    Add-Line
                }
            }
        else {
            Add-Text -string "I'm having trouble auto-validating the credential for $($username.text). You may need to verify this manually" -color "red"
            Add-Line
        }
    }

    if (($jxCheck -notlike $false)-and ($credCheck -notlike $false)){
        Add-Text -string "Attempting to contact Enterprise Audit"
    Add-Line
    $eaPass = ConvertTo-SecureString $EAPassBox.text -AsPlainText -Force
    $connection = New-JMCConnection -JMCServerName $JxBox.Text -JMCUserName $EAUsername.Text -JMCPassword $eaPass #if no connection, it defaults to localhost
    Try {
        $user = (Get-EAUser -JMCConnection $connection -UserName $EAUsername.Text).Operations
        $permissionsString = [String]::Join(', ', $user)
        Add-Text -string "Success!" -color "green"
        Add-Text -string "User was found in Enterprise Audit and has the following permissions:"
        Add-Text -string $permissionsString
        Add-Line
    }
    Catch {
        Add-Text -string "Failure!" -color "red"
        Add-Text -string "Error Checking Persistent Storage"
        Add-Line
    }
}

}
function Test-SG {
    param(
    [Parameter (Mandatory = $false)] [String]$jXchangeFarm,
    [Parameter (Mandatory = $false)] [String]$user,
    [Parameter (Mandatory = $false)] [String]$pass,
    [Parameter (Mandatory = $false)] [String]$ABA,
    [Parameter (Mandatory = $false)] [String]$ENV
    )

    Try{
        $dnsTest = Resolve-DnsName $jxbox.text -NoHostsFile -DnsOnly
    }
    Catch{
        $dnsTest = $false
        Add-Text -string "DNS failure for $($jxbox.text). Is this the right URL?" -color "red"
    }
    if ($dnsTest -notLike $false){
        Try {
            $jxTlsCheck = Test-TLSConnection -ComputerName $($jxbox.text)
            $jxCheck = $true
            Add-line
        }
        Catch {
            $jxCheck = $false
            Add-Text -string "Error establishing TLS session with https://$($jxbox.text)" -color "red"
            Add-line
        }
    }
    Try {
        
        Add-Text -string "Checking credential for $($user)"
        $test = Test-ADAuthentication -username $user -password $pass
        
        if ($test -like $true){
            Add-Text -string "Success!" -color "green"
            Add-Text -string "Credential for $user is valid"
            $credCheck = $true
            Add-Line
        }
        elseif ($test -like $false){
            throw "invalid"
        }
    }
    Catch {
        if ($error[0].FullyQualifiedErrorID -eq "invalid") {
                Add-Text -string "The credential you entered for the SG may be invalid, double-check the password" -color "red"
                $credCheck = $false
                Add-Text -string "Attempting to get account properties from Active Directory" 
                Import-Module ActiveDirectory
                $userObj = Get-ADUser -Filter "userPrincipalName -like '$($user)'" -Properties *
                if ($userObj -like $null){Add-Text -string "$($user) not found in Active Directory" -color "red"}
                else {
                    Add-Text -string "Enabled = $($userObj.enabled)"
                    Add-Text -string "LockedOut = $($userObj.lockedout)"
                    Add-Text -string "Password Never Expires = $($userObj.Passwordneverexpires)"
                    Add-Text -string "Expired = $($userObj.PasswordExpired)"
                    Add-Line
                }
            }
        else {
            Add-Text -string "I'm having trouble auto-validating the credential for $($username.text). You may need to verify this manually" -color "red"
            Add-Line
        }
    }

    if (($jxCheck -notlike $false)-and ($credCheck -notlike $false)){
    Add-Text -string "Attempting to contact the Service Gateway"
    Add-Line
        
    $errvar = ''
    $message = ''
    $fullError = ''

    #$password = ConvertTo-SecureString $pass -AsPlainText -Force
    $userString = $user
    

    $SGABA = $aba
    $SGEnv = $env
    $SGFarm = $jXchangeFarm
    
    $uri = "https://" + $SGfarm + "/jXchange/2008/ServiceGateway/ServiceGateway.svc"
    $headers = @{
        'SOAPAction' = 'http://jackhenry.com/ws/PingAll'
    }
    $timestamp = Get-Date -UFormat '+%Y-%m-%dT%H:%M:%S.000Z'
    
$soap = @"
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <SOAP-ENV:Header>
                        <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
                                  <wsse:UsernameToken>
                                  <wsse:Username>$userString</wsse:Username>
                                  <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">$pass</wsse:Password>
                                  </wsse:UsernameToken>
                        </wsse:Security>
              </SOAP-ENV:Header>
              <SOAP-ENV:Body>
              <PingAll xmlns="http://jackhenry.com/jxchange/TPG/2008">
                <PingRq>Ping</PingRq>
                <InstRtId>$SGABA</InstRtId>
                <InstEnv>$SGEnv</InstEnv>
                <IncNonProdEnv>true</IncNonProdEnv>
                </PingAll>
        </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
"@
    try {
        [xml]$return = (Invoke-WebRequest -Uri $uri -Headers $headers -Method Post -Body $soap -ContentType text/xml).content
        $message = ($return.Envelope.body.PingAllResponse.PingAllArray.PingAllInfoRec) | Where-Object {$_.InstEnv -like $SGEnv}
        #$results = "Successfully retrieved list of Synergy Indexes" + "`r`n" + "Displaying first 20 results" + "`r`n" + "`r`n"
        $body = $message.SvcPrvdName -join ", " | Out-String
        #$output = $results + $body
        Add-Text -string "Success!" -color "green"
        Add-Text -string "Retrieved list of Providers configured in the Service Gateway for $($sgaba)/$($sgenv) on $jXchangeFarm"
        Add-line
        Add-Text -string $body
        }
    catch [System.ArgumentException] {
        $errvar = $_.Exception.Message
        Add-text -string "Unhandled Expception: System.ArgumentException" -color "red"
        Add-Text -string $errvar
        Add-Line

    }
    catch [System.Net.WebException]{
        $errvar = $_.Exception.Message
        Add-text -string "Unhandled Expception:System.Net.WebException" -color "red"
        Add-Text -string $errvar
        Add-Line
    }
    catch {
        [xml]$errorResponse = $error[0].ErrorDetails
        $errException = $error[0].Exception | Out-String
        $errCode = $errorResponse.Envelope.body.Fault.detail.HdrFault.FaultRecInfoArray.FaultMsgRec.errCode
        $errDesc = $errorResponse.Envelope.body.Fault.detail.HdrFault.FaultRecInfoArray.FaultMsgRec.ErrDesc
        $fullError = [PSCustomObject]@{
            Exception     = $errException
            Code          = $errCode
            Details       = $errDesc
            }
        $fullError = $fullError | Format-List | Out-String
        Add-text -string "$($fullError)"
        Add-Line
    }
    }
}
function Test-SynNode {
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    #[System.Net.ServicePointManager]::ServerCertificateValidationCallback = $true
    $errvar = ''
    
    $ipv6 = Get-ItemPropertyValue 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' -Name "DisabledComponents" -ErrorAction SilentlyContinue
    
    Add-Text -string "Checking IPv6 Settings"
    if ($ipv6 -notlike "32"){
        Add-Text -string "Setting IPv4 to preferred over IPv6"
        (reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 32 /f) | out-null
        Add-Line
        
    }
    else {
        Add-Text -string "IPv4 already set to preferred over IPv6" -color "green"
        Add-Line
    }
    #[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls13
    $ErrorActionPreference = "Continue"

    #download modules


    Add-Text -string "Checking for certificate issues"
    #wrap these if if/else/try/catch
    Try {
        
        Add-Text -string "Getting Certificate bound to port 443"
        Import-Module -Name WebAdministration

        $iisBinding = (Get-ChildItem -Path IIS:SSLBindings | where-object {$_.port -like 443})
        $iisBinding.Thumbprint
        $certificate = Get-ChildItem -Path CERT:LocalMachine/My | Where-Object -Property Thumbprint -EQ -Value $iisBinding.Thumbprint
        $certname = $certificate.DnsNameList.unicode
        Add-Text -string "Success!" -color "green"
        Add-Text -string "Certificate Found for $($certname)"
        Add-Line
        $bindingCheck = $true
        
    }
    Catch {
        $bindingCheck = $false
        $errvar = $_.Exception.Message
        Add-text -string $errvar -color "red"
        Add-Text -string "Error retrieving cert binding, or no cert is bound. CHECK MANUALLY" -color "red"
        Add-Line
    }
    if ($bindingCheck -like $true){
        Add-Text -string "Checking if SSL certificate is expired"
        Try {
            #[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
            $url = "https://" + $certname
            $req = [Net.HttpWebRequest]::Create($url)
            $check = $req.GetResponse()
            $certStart = [DateTime]($req.ServicePoint.Certificate.GetEffectiveDateString()).toString()
            $certEnd = [DateTime]($req.ServicePoint.Certificate.GetExpirationDateString()).toString()
            $Now = Get-Date 
            if (($certStart -lt $now) -and ($certEnd -gt $now)){
                $expiringDays = (New-TimeSpan -Start $Now -End $certEnd).Days
                Add-Text -string "Success!" -color "green"
                Add-Text -string "The SSL Certificate bound to port 443 is valid for $expiringDays days"

                Add-Line
            }
            if ($certStart -gt $now){
                Add-Text -string "Failed!" -color "red"
                Add-Text -string "The SSL Certificate bound to port 443 is not valid until $certStart"
                Add-Line
            }
            if ($certEnd -lt $now){
                Add-Text -string "Failed!" -color "red"
                $expiredDays = (New-TimeSpan -Start $certEnd -End $Now).Days
                Add-Text -string "The SSL Certificate bound to port 443 expired $expiredDays ago on $certEnd"
                Add-Line
            }
            $certDateCheck = $true
        }
        Catch {
            
            $certDateCheck = $false
            $errvar = $_.Exception.Message
            Add-text -string $errvar -color "red"
            Add-Text -string "Error verifying certificate dates. VERIFY MANUALLY"
            Add-Line
        }
    }
    else {
        Add-Text -string "Skipped checking if cert is valid on port 443" -color "red"
        Add-Line
    }

    if ($bindingCheck -like $true){
        Add-Text -string "Checking DNS Records" 
        Try {
            $dnsQuery = (Resolve-DnsName -Name $certname -DnsOnly -NoHostsFile -ErrorAction Stop).ip4address
            if ($dnsQuery){
                Add-Text -string "Success!" -color "green"
                Add-Text -string "DNS A Record exists and resolves to $($dnsQuery)"
                $dnsCheck = $true
                Add-Line
            }
            else {
                throw
            }
        }
        Catch{
            $dnsCheck = $false
            Add-Text -string "Failure!" -color "red"
            Add-Text -string "Error retrieving DNS Record, or DNS Record does not exist. CHECK MANUALLY" 
            Add-Line
        }
    }
    else {
        Add-Text -string "Skipped verifying DNS records" -color "red"
        Add-Line
    }
    
    if ($dnsCheck -like $true){
        Try {
            Add-Text -string "Checking if DNS record resolves to a local IPv4 address"
            $iPs = (Get-NetIPAddress | Where-Object {$_.InterfaceAlias -notlike "loopback*"}).IPv4Address
            if ($dnsQuery -in $ips){
                Add-Text -string "Success!" -color "green"
                $dnsIpCheck = $true
                Add-Line
            }
            else {
                throw
            }
        }
        Catch {
            $dnsIpCheck = $false
            Add-Text -string "Error checking IP Address against DNS records. VERIFY MANUALLY" 
            Add-Line
        }
    }
    else {
        Add-Text -string "Skipped matching IP address to DNS resolution" -color "red"
        Add-Line
    }


    Add-Text -string "Checking if Webex Remote Access is installed" 
    Try {
        $HNA = (Get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\WebEx\Config\RA\General -Name "HNA" -ErrorAction SilentlyContinue).HNA 
        If ($HNA -like $null){
            $HNA = "Not Installed"
            Add-Text -string $HNA -color "green"
        }
    }
    Catch {
        $HNA = "Error querying the Registry"
        Start-Sleep -Seconds 1
        Add-Text -string $HNA "red"
    }
    Start-Sleep -Seconds 1
    Add-Line
    
    if ($jxbox.text){
        Add-Text "Checking communication path to JXCHANGE"
        Try{
            $dnsTest = Resolve-DnsName $jxbox.text -NoHostsFile -DnsOnly
            Add-Text -string "A DNS record resolves for $($jxbox.text)"
        }
        Catch{
            $dnsTest = $false
            Add-Text -string "Failure checking DNS for $($jxbox.text). Is this the right URL?" -color "red"
        }
        if ($dnsTest -notLike $false){
            Try {
                $jxTlsCheck = Test-TLSConnection -ComputerName $($jxbox.text)
                Add-Text -string "Success!" -color "green"
                Add-Text -string "TLS session established with $($jxbox.text) over port 443 using the $($jxTlsCheck.protocol) protocol"
                $jxCheck = $true
                Add-Line
            }
            Catch {
                $jxCheck = $false
                Add-Text -string "Failure!" -color "red"
                Add-Text -string "Error establishing TLS session. Try putting https://$($jxbox.text) in a browser"
                Add-Line
            }
        }
    }
    #[System.Net.ServicePointManager]::ServerCertificateValidationCallback = $false

    if ($jxbox.text -and $jxCheck -like $true){
        Add-Text "Retrieving ADFS Token Signing Thumbprint"
        
        Try {
            $adfsFarmUrl = $jxbox.text #Only modify this value if ADFS does not live on the same servers as JX
            $suffix = $adfsFarmUrl.Substring($adfsFarmUrl.IndexOf(".") +1)
            $signingName = "ADFS-Signing-" + $suffix
            $uri = "federationmetadata/2007-06/federationmetadata.xml"
            $fullUrl = "https://$adfsFarmUrl/$uri"
            $response = Invoke-WebRequest -Uri $fullUrl -UseBasicParsing
            $xmlContent = [xml]$response.content
            $certificateString = $xmlContent."EntityDescriptor"."Signature"."KeyInfo"."X509Data"."X509Certificate"
            $file = New-Temporaryfile
            $filename = $signingName
            if ($certificateString -eq $null -or $certificateString.Trim() -eq "") {
                throw "Error creating certificate $filename"
            }
            $newString = ""
            foreach ($entry in ($certificateString -split '(.{64})' | ? {$_})) {
                $newString = "$newString$entry`r`n"
            }
            $certificateStringNew = "-----BEGIN CERTIFICATE-----`r`n$($newString)-----END CERTIFICATE-----"
            $outputPath = $file.FullName
            $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
        
            [System.IO.File]::WriteAllLines($outputPath, $certificateStringNew, $Utf8NoBomEncoding)
            $thumbprint = (New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $outputPath).Thumbprint
            Add-Text -string "Success!" -color "green"
            Add-Text -string "Current Token Signing Thumbprint is $thumbprint"
        }
        Catch {
            $_.Exception.Message
            Add-text -string "Failure" -color "red"
            Add-Text -string "Error retrieving Signing Thumbprint. VERIFY MANUALLY" 
            Add-Line
        }
    }
    [System.Net.ServicePointManager]::CertificatePolicy = $null

}
function Test-PubWorkflowSrch{ 
    param(
    [Parameter (Mandatory = $false)] [String]$jXchangeFarm,
    [Parameter (Mandatory = $false)] [String]$user,
    [Parameter (Mandatory = $false)] [String]$pass,
    [Parameter (Mandatory = $false)] [String]$ABA,
    [Parameter (Mandatory = $false)] [String]$ENV
    )
    Try{
        $dnsTest = Resolve-DnsName $jxbox.text -NoHostsFile -DnsOnly
    }
    Catch{
        $dnsTest = $false
        Add-Text -string "DNS failure for $($jxbox.text). Is this the right URL?" -color "red"
    }
    if ($dnsTest -notLike $false){
        Try {
            $jxTlsCheck = Test-TLSConnection -ComputerName $($jxbox.text)
            $jxCheck = $true
            Add-line
        }
        Catch {
            $jxCheck = $false
            Add-Text -string "Error establishing TLS session with https://$($jxbox.text)" -color "red"
            Add-line
        }
    }
    
    Try {
        
        Add-Text -string "Checking credential for $($user)"
        $test = Test-ADAuthentication -username $user -password $pass
        
        if ($test -like $true){
            Add-Text -string "Success!" -color "green"
            Add-Text -string "Credential for $user is valid"
            $credCheck = $true
            Add-Line
        }
        elseif ($test -like $false){
            throw "invalid"
        }
    }
    Catch {
        if ($error[0].FullyQualifiedErrorID -eq "invalid") {
                Add-Text -string "The credential you entered for the SG may be invalid, double-check the password" -color "red"
                $credCheck = $false
                Add-Text -string "Attempting to get account properties from Active Directory" 
                Import-Module ActiveDirectory
                $userObj = Get-ADUser -Filter "userPrincipalName -like '$($user)'" -Properties *
                if ($userObj -like $null){Add-Text -string "$($user) not found in Active Directory" -color "red"}
                else {
                    Add-Text -string "Enabled = $($userObj.enabled)"
                    Add-Text -string "LockedOut = $($userObj.lockedout)"
                    Add-Text -string "Password Never Expires = $($userObj.Passwordneverexpires)"
                    Add-Text -string "Expired = $($userObj.PasswordExpired)"
                    Add-Line
                }
            }
        else {
            Add-Text -string "I'm having trouble auto-validating the credential for $($username.text). You may need to verify this manually" -color "red"
            Add-Line
        }
    }

    if (($jxCheck -notlike $false) -and ($credCheck -notlike $false)){
    Add-Text -string "Attempting to retrieve a list of published workflows from EWF"
    $errvar = ''
    $message = ''
    $fullError = ''

    #$password = ConvertTo-SecureString $pass -AsPlainText -Force
    $userString = $user
    

    $SGABA = $aba
    $SGEnv = $env
    $SGFarm = $jXchangeFarm
    
    $uri = "https://" + $SGfarm + "/jXchange/2008/ServiceGateway/ServiceGateway.svc"
    $headers = @{
        'SOAPAction' = 'http://jackhenry.com/ws/PubWorkflowSrch'
    }
    $timestamp = Get-Date -UFormat '+%Y-%m-%dT%H:%M:%S.000Z'
    
    $soap = @"
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <SOAP-ENV:Header>
                        <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
                                  <wsse:UsernameToken>
                                            <wsse:Username>$userString</wsse:Username>
                                            <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">$pass</wsse:Password>
                                  </wsse:UsernameToken>
                        </wsse:Security>
              </SOAP-ENV:Header>
              <SOAP-ENV:Body>
                        <PubWorkflowSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">
                                  <SrchMsgRqHdr>
                                            <jXchangeHdr>
                                                      <JxVer>2019.0.04.01</JxVer>
                                                      <AuditUsrId>AuditUsrId1</AuditUsrId>
                                                      <AuditWsId>AuditWsId1</AuditWsId>
                                                      <InstRtId>$SGABA</InstRtId>
                                                      <InstEnv>$SGEnv</InstEnv>
                                            </jXchangeHdr>
                                            <MaxRec>20</MaxRec>
                                  </SrchMsgRqHdr>
                        </PubWorkflowSrch>
              </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
"@
    try {
        [xml]$return = (Invoke-WebRequest -Uri $uri -Headers $headers -Method Post -Body $soap -ContentType text/xml).content
        $message = ($return.Envelope.Body.PubWorkflowSrchResponse.PubWorkflowSrchRecArray.PubWorkflowSrchRec).workflowname 
        #$results = "Successfully retrieved list of published workflow definitions" + "`r`n" + "Displaying first 20 results" + "`r`n" + "`r`n"
        $body = $message -join "`r`n" | Out-String
        #$output = $results + $body
        Add-Text -string "Success!" -color "green"
        Add-Text -string "Retrieved list of published definitions from EWF"
        add-line
        Add-Text -string "Displaying up to 20 results"
        Add-line
        Add-Text -string $body
        }
    catch [System.ArgumentException] {
        $errvar = $_.Exception.Message
        Add-text -string "Unhandled Expception: System.ArgumentException" -color "red"
        Add-Text -string $errvar
        Add-Line

    }
    catch [System.Net.WebException]{
        $errvar = $_.Exception.Message
        Add-text -string "Unhandled Expception:System.Net.WebException" -color "red"
        Add-Text -string $errvar
        Add-Line
    }
    catch {
        [xml]$errorResponse = $error[0].ErrorDetails
        $errException = $error[0].Exception | Out-String
        $errCode = $errorResponse.Envelope.body.Fault.detail.HdrFault.FaultRecInfoArray.FaultMsgRec.errCode
        $errDesc = $errorResponse.Envelope.body.Fault.detail.HdrFault.FaultRecInfoArray.FaultMsgRec.ErrDesc
        $fullError = [PSCustomObject]@{
            Exception     = $errException
            Code          = $errCode
            Details       = $errDesc
            }
        $fullError = $fullError | Format-List | Out-String
        Add-text -string "$($fullError)"
        Add-Line
    }
    }
    $user = $null
    $pass = $null
}
function Test-SvcDictSrch{ 
    param(
    [Parameter (Mandatory = $false)] [String]$jXchangeFarm,
    [Parameter (Mandatory = $false)] [String]$user,
    [Parameter (Mandatory = $false)] [String]$pass,
    [Parameter (Mandatory = $false)] [String]$ABA,
    [Parameter (Mandatory = $false)] [String]$ENV
    )
    
    Try{
        $dnsTest = Resolve-DnsName $jxbox.text -NoHostsFile -DnsOnly
    }
    Catch{
        $dnsTest = $false
        Add-Text -string "DNS failure for $($jxbox.text). Is this the right URL?" -color "red"
    }
    if ($dnsTest -notLike $false){
        Try {
            $jxTlsCheck = Test-TLSConnection -ComputerName $($jxbox.text)
            $jxCheck = $true
            Add-line
        }
        Catch {
            $jxCheck = $false
            Add-Text -string "Error establishing TLS session with https://$($jxbox.text)" -color "red"
            Add-line
        }
    }
    Try {
        
        Add-Text -string "Checking credential for $($user)"
        $test = Test-ADAuthentication -username $user -password $pass
        
        if ($test -like $true){
            Add-Text -string "Success!" -color "green"
            Add-Text -string "Credential for $user is valid"
            $credCheck = $true
            Add-Line
        }
        elseif ($test -like $false){
            throw "invalid"
        }
    }
    Catch {
        if ($error[0].FullyQualifiedErrorID -eq "invalid") {
                Add-Text -string "The credential you entered for the SG may be invalid, double-check the password" -color "red"
                $credCheck = $false
                Add-Text -string "Attempting to get account properties from Active Directory" 
                Import-Module ActiveDirectory
                $userObj = Get-ADUser -Filter "userPrincipalName -like '$($user)'" -Properties *
                if ($userObj -like $null){Add-Text -string "$($user) not found in Active Directory" -color "red"}
                else {
                    Add-Text -string "Enabled = $($userObj.enabled)"
                    Add-Text -string "LockedOut = $($userObj.lockedout)"
                    Add-Text -string "Password Never Expires = $($userObj.Passwordneverexpires)"
                    Add-Text -string "Expired = $($userObj.PasswordExpired)"
                    Add-Line
                }
            }
        else {
            Add-Text -string "I'm having trouble auto-validating the credential for $($username.text). You may need to verify this manually" -color "red"
            Add-Line
        }
    }

    if (($jxCheck -notlike $false) -and ($credCheck -notlike $false)){
    Add-Text -string "Attempting to retrieve list of indexes from Synergy"
    $errvar = ''
    $message = ''
    $fullError = ''

    #$password = ConvertTo-SecureString $pass -AsPlainText -Force
    $userString = $user
    

    $SGABA = $aba
    $SGEnv = $env
    $SGFarm = $jXchangeFarm
    
    $uri = "https://" + $SGfarm + "/jXchange/2008/ServiceGateway/ServiceGateway.svc"
    $headers = @{
        'SOAPAction' = 'http://jackhenry.com/ws/SvcDictSrch'
    }
    $timestamp = Get-Date -UFormat '+%Y-%m-%dT%H:%M:%S.000Z'
    
$soap = @"
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <SOAP-ENV:Header>
                        <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
                                  <wsse:UsernameToken>
                                  <wsse:Username>$userString</wsse:Username>
                                  <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">$pass</wsse:Password>
                                  </wsse:UsernameToken>
                        </wsse:Security>
              </SOAP-ENV:Header>
              <SOAP-ENV:Body>
                        <SvcDictSrch xmlns="http://jackhenry.com/jxchange/TPG/2008">
                                  <SrchMsgRqHdr>
                                            <jXchangeHdr>
                                                      <JxVer>2019.0.04.01</JxVer>
                                                      <AuditUsrId>jXsupport</AuditUsrId>
                                                      <AuditWsId>TestTool</AuditWsId>
                                                      <InstRtId>$SGABA</InstRtId>
                                                      <InstEnv>$SGEnv</InstEnv>
                                            </jXchangeHdr>
                                            <MaxRec>20</MaxRec>
                                  </SrchMsgRqHdr>
                                  <SvcDictName>DocImgAdd</SvcDictName>
                                  <SvcDictType>Rq</SvcDictType>
            </SvcDictSrch>
        </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
"@
    try {
        [xml]$return = (Invoke-WebRequest -Uri $uri -Headers $headers -Method Post -Body $soap -ContentType text/xml).content
        $message = ($return.Envelope.Body.SvcDictSrchResponse.SvcDictInfoArray.SvcDictInfoRec).ElemName 
        #$results = "Successfully retrieved list of Synergy Indexes" + "`r`n" + "Displaying first 20 results" + "`r`n" + "`r`n"
        $body = $message -join "`r`n" | Out-String
        #$output = $results + $body
        Add-Text -string "Success!" -color "green"
        Add-Text -string "Retrieved list of Synergy Indexes"
        Add-Text -string "Displaying up to 20 results"
        Add-line
        Add-Text -string $body
        }
    catch [System.ArgumentException] {
        $errvar = $_.Exception.Message
        Add-text -string "Unhandled Expception: System.ArgumentException" -color "red"
        Add-Text -string $errvar
        Add-Line

    }
    catch [System.Net.WebException]{
        $errvar = $_.Exception.Message
        Add-text -string "Unhandled Expception:System.Net.WebException" -color "red"
        Add-Text -string $errvar
        Add-Line
    }
    catch {
        [xml]$errorResponse = $error[0].ErrorDetails
        $errException = $error[0].Exception | Out-String
        $errCode = $errorResponse.Envelope.body.Fault.detail.HdrFault.FaultRecInfoArray.FaultMsgRec.errCode
        $errDesc = $errorResponse.Envelope.body.Fault.detail.HdrFault.FaultRecInfoArray.FaultMsgRec.ErrDesc
        $fullError = [PSCustomObject]@{
            Exception     = $errException
            Code          = $errCode
            Details       = $errDesc
            }
        $fullError = $fullError | Format-List | Out-String
        Add-text -string "$($fullError)"
        Add-Line
    }
    }
}


#region Logic 


#$global:providerArray = @()
$DataGridView1.text = "Please select a test"
#$Username.text = whoami /upn
#endregion

[void]$Form.ShowDialog()
# SIG # Begin signature block
# MIINiQYJKoZIhvcNAQcCoIINejCCDXYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDGZHzr7tshBZbal2RSbqIakd
# kiegggrLMIIFMDCCBBigAwIBAgIQBAkYG1/Vu2Z1U0O1b5VQCDANBgkqhkiG9w0B
# AQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMTMxMDIyMTIwMDAwWhcNMjgxMDIyMTIwMDAwWjByMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQg
# Q29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# +NOzHH8OEa9ndwfTCzFJGc/Q+0WZsTrbRPV/5aid2zLXcep2nQUut4/6kkPApfmJ
# 1DcZ17aq8JyGpdglrA55KDp+6dFn08b7KSfH03sjlOSRI5aQd4L5oYQjZhJUM1B0
# sSgmuyRpwsJS8hRniolF1C2ho+mILCCVrhxKhwjfDPXiTWAYvqrEsq5wMWYzcT6s
# cKKrzn/pfMuSoeU7MRzP6vIK5Fe7SrXpdOYr/mzLfnQ5Ng2Q7+S1TqSp6moKq4Tz
# rGdOtcT3jNEgJSPrCGQ+UpbB8g8S9MWOD8Gi6CxR93O8vYWxYoNzQYIH5DiLanMg
# 0A9kczyen6Yzqf0Z3yWT0QIDAQABo4IBzTCCAckwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwMweQYIKwYBBQUH
# AQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYI
# KwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFz
# c3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmw0
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaG
# NGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RD
# QS5jcmwwTwYDVR0gBEgwRjA4BgpghkgBhv1sAAIEMCowKAYIKwYBBQUHAgEWHGh0
# dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCgYIYIZIAYb9bAMwHQYDVR0OBBYE
# FFrEuXsqCqOl6nEDwGD5LfZldQ5YMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6en
# IZ3zbcgPMA0GCSqGSIb3DQEBCwUAA4IBAQA+7A1aJLPzItEVyCx8JSl2qB1dHC06
# GsTvMGHXfgtg/cM9D8Svi/3vKt8gVTew4fbRknUPUbRupY5a4l4kgU4QpO4/cY5j
# DhNLrddfRHnzNhQGivecRk5c/5CxGwcOkRX7uq+1UcKNJK4kxscnKqEpKBo6cSgC
# PC6Ro8AlEeKcFEehemhor5unXCBc2XGxDI+7qPjFEmifz0DLQESlE/DmZAwlCEIy
# sjaKJAL+L3J+HNdJRZboWR3p+nRka7LrZkPas7CM1ekN3fYBIM6ZMWM9CBoYs4Gb
# T8aTEAb8B4H6i9r5gkn3Ym6hU/oSlBiFLpKR6mhsRDKyZqHnGKSaZFHvMIIFkzCC
# BHugAwIBAgIQDOvNDFiXw2OZ9AIQGE5NKjANBgkqhkiG9w0BAQsFADByMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29k
# ZSBTaWduaW5nIENBMB4XDTIwMDIwNTAwMDAwMFoXDTIzMDIwOTEyMDAwMFowgc8x
# CzAJBgNVBAYTAlVTMREwDwYDVQQIEwhNaXNzb3VyaTEPMA0GA1UEBxMGTW9uZXR0
# MSYwJAYDVQQKDB1KQUNLIEhFTlJZICYgQVNTT0NJQVRFUywgSU5DLjEMMAoGA1UE
# CxMDSkhBMSYwJAYDVQQDDB1KQUNLIEhFTlJZICYgQVNTT0NJQVRFUywgSU5DLjE+
# MDwGCSqGSIb3DQEJARYvc2NzLWVudGVycHJpc2VhcHBsaWNhdGlvbnNlY3VyaXR5
# QGphY2toZW5yeS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDR
# rClZ7TdfrGF+aTUJqbQojlEBoStRJqZe1SebuP3+RSQLVpnDXd2T1BBtBIdxPcGR
# lSgpGPDJNkmDIFa6utr++4jYPjwZMXP4MAUSHm7JpvLJ/n0eVnLcuV3+FhUoHqrP
# /cNRxhAaQ7DWdrAG0C9u8fNyIcP3xZ6tgbqTxpF72ImIZ3+VfEzopCMhsx+EeYkN
# HN6YyGJTce9yjitgkb0Wwb0mmkJZYtseg/JnKZEvW3QR8mJH1WSHxtjm2pD52OGH
# 6J8ze+eX06hMXdsgjXl81UBnmR0/WUsjFk4iOXbnUCicZmaTQHV8MagzOhlM5m2D
# lagJPSnEySweXxD27NR5AgMBAAGjggHFMIIBwTAfBgNVHSMEGDAWgBRaxLl7Kgqj
# pepxA8Bg+S32ZXUOWDAdBgNVHQ4EFgQUA6XmHgDE2Xp3ln6R4tXl4wp/+PswDgYD
# VR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGA1UdHwRwMG4wNaAz
# oDGGL2h0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEu
# Y3JsMDWgM6Axhi9odHRwOi8vY3JsNC5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVk
# LWNzLWcxLmNybDBMBgNVHSAERTBDMDcGCWCGSAGG/WwDATAqMCgGCCsGAQUFBwIB
# FhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAgGBmeBDAEEATCBhAYIKwYB
# BQUHAQEEeDB2MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20w
# TgYIKwYBBQUHMAKGQmh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dFNIQTJBc3N1cmVkSURDb2RlU2lnbmluZ0NBLmNydDAMBgNVHRMBAf8EAjAAMA0G
# CSqGSIb3DQEBCwUAA4IBAQCsaoC+laoa0qHEpl+beeLTTktTEFavWjDGs7QhvU8Q
# ABBL1bz0RQUG9KuCcfr0XQTMB3NuPHTr3fwq/pNKJIMn3tfRzv+jfkdFirla2NWP
# +wr+V7+J43utL10wo50TceBzUXTm3gAE0dbRFSveQVapBqS44bQ8O6g6x0HyNAEL
# MIZLWtskxXuBKoi7VuqG1yoz/hUtnBPd7uFrK6vyMHc285CVntJN+sY5sBNw5jDq
# JnzYi/SINS1ZQSgXq8aC1Xm1VRPQ8wTQuHUgyRFchtVYBl0Lmp+A8wh9ZGW36pHY
# XtOEMUgQkb/FAx+2cMSWOD5GlS672n24sPfDCCOjg4s5MYICKDCCAiQCAQEwgYYw
# cjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVk
# IElEIENvZGUgU2lnbmluZyBDQQIQDOvNDFiXw2OZ9AIQGE5NKjAJBgUrDgMCGgUA
# oHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0B
# CQQxFgQUEzblbNifCYJTVIbQjHXiQ0sM0OMwDQYJKoZIhvcNAQEBBQAEggEAls9y
# a7Y+X+EB5lln9nGSpDzCR1i0/COwIWrWqYI+z4MgwFfNsrjWC8RVu8U+EAyAmRh5
# m40Fe2FMf0OUkr83rAnO8XG0n494tutGePGkVUniNzb0XLvg3MYbKYQXit0zu/Xi
# ap9J1V1p4AmgSj6vdhayz2WJXCDDh9eaRaBDo+6AoJOBQDW3j2oXC9pcJ83YyqwL
# jDln6zyE3GehMnQpf7M8F+HoE+vWtia3WyMkqC1fJLO9dT/c0BuIJ+DZx6SZ19vO
# rdrxZPNIJDxBQSn+ISQZ9t9ajrRvilZ1TFfATU+lzCSrhoTfcJBW8hlmbjTlsI8V
# pRXqfuzObZy6fSqVSQ==
# SIG # End signature block
