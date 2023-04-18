<# 
.NAME
    Get-ProviderInfo
#>

#Optional hard-coded values
$jxFarmString = "jxapp.jhahosted.com"
$credString = "username@jhahosting.com"
$passString = ""
$abaString = "123456789"
$envString = "PROD"

Import-module powershelljmc

####################################################
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = New-Object System.Drawing.Point(894,465)
$Form.text                       = "Get SG Provider Info"
$Form.TopMost                    = $false


$Username                        = New-Object system.Windows.Forms.TextBox
$Username.text                   = "$($credString)"
$Username.multiline              = $false
$Username.width                  = 160
$Username.height                 = 20
$Username.location               = New-Object System.Drawing.Point(151,11)
$Username.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',14)

$PassBox                         = New-Object system.Windows.Forms.TextBox
$PassBox.Text                    = "$($passString)"
$PassBox.PasswordChar            = "*"
$PassBox.multiline               = $false
$PassBox.width                   = 160
$PassBox.height                  = 20
$PassBox.location                = New-Object System.Drawing.Point(151,44)
$PassBox.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',14)

$JxBox                           = New-Object system.Windows.Forms.TextBox
$JxBox.multiline                 = $false
$JxBox.text                      = "$($jxFarmString)"
$JxBox.width                     = 160
$JxBox.height                    = 20
$JxBox.location                  = New-Object System.Drawing.Point(152,99)
$JxBox.Font                      = New-Object System.Drawing.Font('Microsoft Sans Serif',14)

$EnvBox                          = New-Object system.Windows.Forms.TextBox
$EnvBox.Text                     = "$($envString)"
$EnvBox.multiline                = $false
$EnvBox.width                    = 100
$EnvBox.height                   = 20
$EnvBox.location                 = New-Object System.Drawing.Point(209,166)
$EnvBox.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',14)

$UserLabel                       = New-Object system.Windows.Forms.Label
$UserLabel.text                  = "Username"
$UserLabel.AutoSize              = $true
$UserLabel.width                 = 25
$UserLabel.height                = 10
$UserLabel.location              = New-Object System.Drawing.Point(36,11)
$UserLabel.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',14)

$PassLabel                       = New-Object system.Windows.Forms.Label
$PassLabel.text                  = "Password"
$PassLabel.AutoSize              = $true
$PassLabel.width                 = 25
$PassLabel.height                = 10
$PassLabel.location              = New-Object System.Drawing.Point(36,44)
$PassLabel.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',14)

$JxLabel                         = New-Object system.Windows.Forms.Label
$JxLabel.text                    = "JX Farm"
$JxLabel.AutoSize                = $true
$JxLabel.width                   = 25
$JxLabel.height                  = 10
$JxLabel.location                = New-Object System.Drawing.Point(38,99)
$JxLabel.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',14)

$AbaBox                          = New-Object system.Windows.Forms.TextBox
$AbaBox.Text                     = "$($abaString)"
$AbaBox.multiline                = $false
$AbaBox.width                    = 114
$AbaBox.height                   = 20
$AbaBox.location                 = New-Object System.Drawing.Point(197,219)
$AbaBox.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',14)

$AbaLabel                        = New-Object system.Windows.Forms.Label
$AbaLabel.text                   = "ABA"
$AbaLabel.AutoSize               = $true
$AbaLabel.width                  = 25
$AbaLabel.height                 = 10
$AbaLabel.location               = New-Object System.Drawing.Point(41,219)
$AbaLabel.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',14)

$ListButton                      = New-Object system.Windows.Forms.Button
$ListButton.text                 = "Populate Provider List"
$ListButton.width                = 161
$ListButton.height               = 30
$ListButton.location             = New-Object System.Drawing.Point(92,289)
$ListButton.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ProviderComboBox                = New-Object system.Windows.Forms.ComboBox
$ProviderComboBox.width          = 192
$ProviderComboBox.height         = 20
$ProviderComboBox.location       = New-Object System.Drawing.Point(76,340)
$ProviderComboBox.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',14)


#$DataGridView1                   = New-Object system.Windows.Forms.DataGridView
#$DataGridView1.width             = 517
#$DataGridView1.height            = 433
#$DataGridView1.location          = New-Object System.Drawing.Point(357,11)
$DataGridView1                   = New-Object System.Windows.Forms.TextBox 
$DataGridView1.Multiline         = $True;
$DataGridView1.Location          = New-Object System.Drawing.Size(357,11) 
$DataGridView1.Size              = New-Object System.Drawing.Size(517,433)
$DataGridView1.Scrollbars        = "Vertical" 

$EnvironmentLabel                = New-Object system.Windows.Forms.Label
$EnvironmentLabel.text           = "Environment"
$EnvironmentLabel.AutoSize       = $true
$EnvironmentLabel.width          = 25
$EnvironmentLabel.height         = 10
$EnvironmentLabel.location       = New-Object System.Drawing.Point(38,166)
$EnvironmentLabel.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',14)


$Form.controls.AddRange(@($Username,$PassBox,$JxBox,$EnvBox,$AbaBox,$ListButton,$ProviderComboBox,$DataGridView1,$AbaLabel,$EnvironmentLabel,$UserLabel,$PassLabel,$JxLabel))
#ProviderComboBox.Items = $null
$ListButton.Add_Click({ Get-ProviderList })
$ProviderComboBox.Add_SelectedValueChanged({ 
 
    #$pipeline = $_ | ConvertTo-Json
    #$infohash = $this | ConvertTo-Json
    $script:selected = $ProviderComboBox.SelectedItem 
    #Write-host "$selected"
    #Write-Host "$infohash"
    Get-ProviderInformation $event $selected
})

#region Logic 
function Get-ProviderInformation ($sender,$event) {
    #$providerHash.Clear()
    
    $product = $event
    $password = ConvertTo-SecureString $($PassBox.Text) -AsPlainText -Force
    $user = $($Username.text)
    $connection = New-JMCConnection -JMCServerName $($jxbox.Text) -JMCUserName $user -JMCPassword $password
    $PSDefaultParameterValues = @{‘Add-SGInstitution:JMCConnection’=$connection; ‘New-SGProviderSilverlake:JMCConnection’=$connection; ‘Add-SGProvider:JMCConnection’=$connection; ‘Add-SGUser:JMCConnection’=$connection; ‘New-SGProviderCIF2020:JMCConnection’=$connection; ‘Add-SGHostedProviderUser:JMCConnection’=$connection; 'Get-SGInstitution:JMCConnection'=$connection; 'New-SGProviderPadapterWebService:JMCConnection'=$connection ; 'Remove-SGProvider:JMCConnection'=$connection; 'Add-IMSCustomClaim:JMCConnection'=$connection ; 'Export-SGInstitution:JMCConnection'=$connection; 'Get-SGProvider:JMCConnection'=$connection; 'New-SGProviderEnterpriseWorkflow:JMCConnection'=$connection }
    $institutionObject = Get-SGInstitution -ABA $($ababox.text) -Environment $($envbox.text) -JMCConnection $connection
    $datasource = ($institutionObject | Get-SGProvider -WarningAction SilentlyContinue)
    $providerObject = ($datasource | Where-Object {$_.ProviderTypeName -like $product}).provider
    <#$datasource.psobject.properties | ForEach-Object {
        $providerNote = @(
            Name = $_.name
            Value = $_.value
        )
    } #>
    #Write-host $($datasource)
    #$datasource = $datasource | convertto-json
    #$provider = $provider | convertto-json
    #Write-Host $($product)
    #Write-Host $($provider)
    $DataGridView1.Text = ($providerObject | convertto-json)

}

function Get-ProviderList {
    $ProviderComboBox.items.Clear()
    $password = ConvertTo-SecureString $($PassBox.Text) -AsPlainText -Force
    $user = $($Username.text)
    #Write-host "$($user)"
    #Write-Host "$($password)"
    $connection = New-JMCConnection -JMCServerName $($jxbox.Text) -JMCUserName $user -JMCPassword $password
    $PSDefaultParameterValues = @{‘Add-SGInstitution:JMCConnection’=$connection; ‘New-SGProviderSilverlake:JMCConnection’=$connection; ‘Add-SGProvider:JMCConnection’=$connection; ‘Add-SGUser:JMCConnection’=$connection; ‘New-SGProviderCIF2020:JMCConnection’=$connection; ‘Add-SGHostedProviderUser:JMCConnection’=$connection; 'Get-SGInstitution:JMCConnection'=$connection; 'New-SGProviderPadapterWebService:JMCConnection'=$connection ; 'Remove-SGProvider:JMCConnection'=$connection; 'Add-IMSCustomClaim:JMCConnection'=$connection ; 'Export-SGInstitution:JMCConnection'=$connection; 'Get-SGProvider:JMCConnection'=$connection; 'New-SGProviderEnterpriseWorkflow:JMCConnection'=$connection }
    $institution = Get-SGInstitution -ABA $($ababox.text) -Environment $($envbox.text) -JMCConnection $connection
    $providers = ($institution | Get-SGProvider ).ProviderTypeName
    foreach ($provider in $providers){
        $ProviderComboBox.Items.Add($Provider)
    }  
}
$global:providerArray = @()
$DataGridView1.text = ""
#$Username.text = whoami /upn
#endregion

[void]$Form.ShowDialog()