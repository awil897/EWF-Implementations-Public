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
