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

Import-module PowerShellWSTT
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
$JxBox.text                      = "jxchange.citystate.name.jha-sys.com"
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

$Form.controls.AddRange(@($PSUsername,$PSPassBox,$EAUsername,$EAPassBox,$Username,$PassBox,$JxBox,$EnvBox,$AbaBox,$ProviderComboBox,$ListButton,$UserLabel,$PassLabel,$PSUserLabel,$PSPassLabel,$EAUserLabel,$EAPassLabel,$DataGridView1,$AbaLabel,$EnvironmentLabel,$JxLabel))
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
function Invoke-IEFirstRunCheck {
    Try {
        $property = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main"
        $flag = $property.DisableFirstRunCustomize
        if ($flag -ne 2) {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 2
            #Write-Host "Disabled IE First Run Check"
        }
        else {
            #Write-Host "Flag already set correctly"
        }
    }
    Catch {Add-Text -string "Error setting IE First Run"}
}
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
    Invoke-IEFirstRunCheck
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
    Invoke-IEFirstRunCheck
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
    Invoke-IEFirstRunCheck
    Try{
        $dnsTest = Resolve-DnsName $jXchangeFarm -NoHostsFile -DnsOnly
    }
    Catch{
        $dnsTest = $false
        Add-Text -string "DNS failure for $($jXchangeFarm). Is this the right URL?" -color "red"
    }
    if ($dnsTest -notLike $false){
        Try {
            $jxTlsCheck = Test-TLSConnection -ComputerName $($jXchangeFarm)
            $jxCheck = $true
            Add-line
        }
        Catch {
            $jxCheck = $false
            Add-Text -string "Error establishing TLS session with https://$($jXchangeFarm)" -color "red"
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
            Add-Text -string "I'm having trouble auto-validating the credential for $($user). You may need to verify this manually" -color "red"
            Add-Line
        }
    }

    if (($jxCheck -notlike $false)-and ($credCheck -notlike $false)){
    Add-Text -string "Attempting to contact the Service Gateway"
    Add-Line
        
    $errvar = ''
    $fullError = ''

    $SGABA = $aba
    $SGEnv = $env
    
    $password = ConvertTo-SecureString -String $pass -AsPlainText -Force
    $connection = New-ServiceConnection -UserName $user -Password $password -ServerName $jXchangeFarm
    
[xml]$soap = @"
        <PingAll xmlns="http://jackhenry.com/jxchange/TPG/2008">
        <PingRq>Ping</PingRq>
        <InstRtId>$SGABA</InstRtId>
        <InstEnv>$SGEnv</InstEnv>
        <IncNonProdEnv>true</IncNonProdEnv>
        </PingAll>

"@
    try {
        $operation = Get-XmlOperation -XmlString $soap.OuterXml -CleanXml
        $request = Send-XmlOperation -ServiceConnection $connection -XmlRequest $operation
        if ($request.HeaderStatusCode -like 200){
            $response = ($request.Response.PingAllResponse.PingAllArray.PingAllInfoRec.svcprvdname) | out-string
            Add-Text -string "Success!" -color "green"
            Add-Text -string "Retrieved list of Providers configured in the Service Gateway for $($sgaba)/$($sgenv) on $jXchangeFarm"
            Add-line
            Add-Text -string $response
        }
        else {
            $response = ($request.response.fault.faultstring.'#text') | out-string
            Add-Text -string "Error!" -color "red"
            Add-Text -string "Could not retrieve list of Synergy Indexes"
            Add-line
            Add-Text -string "Error Reason:"
            Add-Text -string $response
        }
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
    Invoke-IEFirstRunCheck
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
            $response = Invoke-WebRequest -Uri $fullUrl
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
    Invoke-IEFirstRunCheck
    Try{
        $dnsTest = Resolve-DnsName $jXchangeFarm -NoHostsFile -DnsOnly
    }
    Catch{
        $dnsTest = $false
        Add-Text -string "DNS failure for $($jXchangeFarm). Is this the right URL?" -color "red"
    }
    if ($dnsTest -notLike $false){
        Try {
            $jxTlsCheck = Test-TLSConnection -ComputerName $($jXchangeFarm)
            $jxCheck = $true
            Add-line
        }
        Catch {
            $jxCheck = $false
            Add-Text -string "Error establishing TLS session with https://$($jXchangeFarm)" -color "red"
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
            Add-Text -string "I'm having trouble auto-validating the credential for $($user). You may need to verify this manually" -color "red"
            Add-Line
        }
    }

    if (($jxCheck -notlike $false) -and ($credCheck -notlike $false)){
    Add-Text -string "Attempting to retrieve a list of published workflows from EWF"
    $errvar = ''
    $fullError = ''

    $SGABA = $aba
    $SGEnv = $env

    $password = ConvertTo-SecureString -String $pass -AsPlainText -Force
    $connection = New-ServiceConnection -UserName $user -Password $password -ServerName $jXchangeFarm
    
[xml]$soap = @"
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
"@
    try {
        $operation = Get-XmlOperation -XmlString $soap.OuterXml -CleanXml
        $request = Send-XmlOperation -ServiceConnection $connection -XmlRequest $operation
        if ($request.HeaderStatusCode -like 200){
            $response = ($request.Response.PubWorkflowSrchResponse.PubWorkflowSrchRecArray.PubWorkflowSrchRec.workflowname) | out-string
            Add-Text -string "Success!" -color "green"
            Add-Text -string "Retrieved list of published definitions from EWF"
            Add-Text -string "Displaying up to 20 results"
            Add-line
            Add-Text -string $response
        }
        else {
            $response = ($request.response.fault.faultstring.'#text') | out-string
            Add-Text -string "Error!" -color "red"
            Add-Text -string "Could not retrieve list of Synergy Indexes"
            Add-line
            Add-Text -string "Error Reason:"
            Add-Text -string $response
        }
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
    Invoke-IEFirstRunCheck
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
    $fullError = ''
   

    $SGABA = $aba
    $SGEnv = $env
    
    $password = ConvertTo-SecureString -String $pass -AsPlainText -Force
    $connection = New-ServiceConnection -UserName $user -Password $password -ServerName $jXchangeFarm
    
[xml]$soap = @"
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
"@
    
    try {
        $operation = Get-XmlOperation -XmlString $soap.OuterXml -CleanXml
        $request = Send-XmlOperation -ServiceConnection $connection -XmlRequest $operation
        if ($request.HeaderStatusCode -like 200){
            $response = ($request.Response.SvcDictSrchResponse.SvcDictInfoArray.SvcDictInfoRec.elemname) | out-string
            Add-Text -string "Success!" -color "green"
            Add-Text -string "Retrieved list of Synergy Indexes"
            Add-Text -string "Displaying up to 20 results"
            Add-line
            Add-Text -string $response
        }
        else {
            $response = ($request.response.fault.faultstring.'#text') | out-string
            Add-Text -string "Error!" -color "red"
            Add-Text -string "Could not retrieve list of Synergy Indexes"
            Add-line
            Add-Text -string "Error Reason:"
            Add-Text -string $response
        }
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
$Form.Icon = New-Object -TypeName System.Drawing.Icon -ArgumentList @(New-Object -TypeName  System.IO.MemoryStream -ArgumentList @(,[System.Convert]::FromBase64String('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Bv9fGAb/XxgG/18YBv9fGAb9XxgGi18YBgZfGAYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXxgG8V8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG8l8YBklfGAYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXxgG818YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBq5fGAYIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXxgGbV8YBn5fGAabXxgG0F8YBvxfGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBupfGAYtAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXxgGAF8YBgBfGAYAXxgGGV8YBpNfGAb8XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv1fGAZfXxgGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF8YBgBfGAYAXxgGAF8YBh9fGAbdXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAaIXxgGAAAAAAAAAAAAXxgGAF8YBgBfGAYAXxgGAF8YBgBfGAYAXxgGAF8YBgBfGAYAXxgGAF8YBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAYAXxgGAF8YBgBfGAYAXxgGAF8YBgBfGAYAXxgGAF8YBgBfGAYAAAAAAAAAAAAAAAAAAAAAAF8YBghfGAa+XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAaiXxgGAQAAAAAAAAAAXxgGBF8YBgtfGAYLXxgGC18YBgtfGAYLXxgGC18YBgtfGAYLXxgGCl8YBgIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAYGXxgGC18YBgtfGAYLXxgGC18YBgtfGAYLXxgGC18YBgtfGAYLAAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAawXxgGBAAAAAAAAAAAXxgGSF8YBsNfGAbDXxgGw18YBsNfGAbDXxgGw18YBsNfGAbDXxgGtV8YBiMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAZmXxgGw18YBsNfGAbDXxgGw18YBsNfGAbDXxgGw18YBsNfGAbBAAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGYF8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG8F8YBi8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAaIXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG7F8YBi4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAaGXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb8AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG7F8YBi4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAaGXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb8AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG7F8YBi4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAaGXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb8AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG7F8YBi4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAaGXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb8AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG7F8YBi4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAaGXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb8AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG7F8YBi4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAaGXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb8AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG7F8YBi4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAaGXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb8AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG7F8YBi4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAaGXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb8AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG7F8YBi4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAaGXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb8AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG7F8YBi4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAaGXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb8AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG7F8YBi4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF8YBgBfGAaGXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb8AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG7F8YBi4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF8YBgBfGAaTXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb8AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG7F8YBixfGAYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXxgGAF8YBglfGAa7XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb4AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG918YBmxfGAYEXxgGAF8YBgBfGAYAAAAAAF8YBgBfGAYAXxgGAF8YBkNfGAbvXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAbpAAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBvJfGAaMXxgGIl8YBgBfGAYAXxgGAF8YBgBfGAYBXxgGNl8YBspfGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAbHAAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG2F8YBpBfGAZcXxgGT18YBmBfGAaXXxgG418YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv5fGAaJAAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb+XxgG+18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBupfGAY6AAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBpxfGAYGAAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAa0XxgGBQAAAAAAAAAAXxgGXl8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG2V8YBipfGAYAAAAAAAAAAAAAAAAAAAAAAF8YBgZfGAa2XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18Y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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAbsXxgG/18YBv9fGAb/XxgG/18YBv9fGAb+XxgG9F8YBtlfGAaoXxgGYF8YBh1fGAYAXxgGAF8YBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXxgG7F8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv1fGAbWXxgGfF8YBh1fGAYAXxgGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF8YBuxfGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAbNXxgGTl8YBgJfGAYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAbsXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBu1fGAZsXxgGBF8YBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXxgG7F8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG8l8YBmRfGAYBXxgGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF8YBuxfGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAblXxgGOV8YBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAbsXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBq9fGAYLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXxgG7l8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb0XxgGR18YBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF8YBsRfGAbZXxgG5V8YBvRfGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBppfGAYCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAYTXxgGGV8YBiRfGAY/XxgGel8YBtZfGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAbVXxgGGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXxgGAF8YBgBfGAYAXxgGAF8YBgBfGAYrXxgGzV8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG818YBjwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAYAXxgGAF8YBmRfGAb8XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv5fGAZhAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF8YBgBfGAYwXxgG7V8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgGfgAAAAAAAAAAAAAAAAAAAABfGAYAXxgGAF8YBgBfGAYAXxgGAF8YBgBfGAYAXxgGAF8YBgBfGAYAXxgGAF8YBgBfGAYAXxgGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF8YBgBfGAYAXxgGAF8YBgBfGAYAXxgGAF8YBgBfGAYAXxgGAF8YBgBfGAYAXxgGAF8YBgBfGAYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXxgGIV8YBuJfGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBpJfGAYAAAAAAAAAAAAAAAAAXxgGCV8YBipfGAYsXxgGLF8YBixfGAYsXxgGLF8YBixfGAYsXxgGLF8YBixfGAYsXxgGLF8YBhUAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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Bv9fGAaiXxgGAQAAAAAAAAAAAAAAAF8YBjRfGAbwXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgGtF8YBgsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABfGAYfXxgG4F8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgGol8YBgEAAAAAAAAAAAAAAABfGAY0XxgG8F8YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG9l8YBlNfGAYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXxgGH18YBuBfGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBqJfGAYBAAAAAAAAAAAAAAAAXxgGNF8YBvBfGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBqhfGAYKXxgGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAF8YBh9fGAbgXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAaiXxgGAQAAAAAAAAAAAAAAAF8YBjRfGAbwXxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18YBv9fGAb/XxgG/18Y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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////////wAP////////AAP///////8AAP///////wAAf///////AAA///////8AAD///////wAAH///////AAAf//////8AAA///////wAAD///////+AAP///////8AA////////wAD////////AAPAAP/wAD8AA8AA//AAPwADwAD/8AA/AAHAAP/wAD8AAcAA//AAPwABwAD/8AA/AAHAAP/wAD8AAcAA//AAPwABwAD/8AA/AAHAAP/wAD8AAcAA//AAPwABwAD/8AA/AAHAAP/wAD8AAcAA//AAPwABwAD/8AA/AAHAAP/wAD8AAcAA//AAPwABwAD/8AA/AAHAAP/wAD8AAcAA//AAPwABwAD/8AA/AAHAAH/gAD8AAcAAH8AAPwABwAAAAAA/AAHAAAAAAD8AAcAAAAAAPwABwAAAAAB/AAHAAAAAAH8AAcAAAAAA/wABwAAAAAH/AAHAAAAAA/8AAcAAAAAH/wABwACAAA//AAPAAOAAP////8AA/AP/////wAD/////4B/AAP/////AB8AA/////wADwAD/////AAHAAP////4AAMAA/////gAAwAD////+AADAAP////4AAMAA/////gAAwAD////+AADAAP////4AAcAA/////wABwAD/////gAPAAP/////AD8AA////w==')))
[void]$Form.ShowDialog()
