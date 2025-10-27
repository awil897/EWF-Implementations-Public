Function Get-EWFUsers {
    $search = [adsisearcher]"(&(ObjectCategory=person)(ObjectClass=user)(samaccountname=*ewf*))"
    $users = $search.FindAll()
    $userArray = @()
    foreach($user in $users) {
        $SamAccountName = $user.Properties['SamAccountName']
        $userArray += $SamAccountName
        $SamAccountName = $null
    }
    $userString = $userArray -join ", "
    return $userString
}
Function Get-EWFGroups {
    $search = [adsisearcher]"(&(objectCategory=group)(samaccountname=*ewf*))"
    $groups = $search.FindAll()
    $groupsArray = @()
    foreach($group in $groups) {
        $SamAccountName = $group.Properties['SamAccountName']
        $groupsArray += $SamAccountName
        $SamAccountName = $null
    }
    $groupsString = $groupsArray -join ", "
    return $groupsString
}
Function Test-SQL{
    param (
        [string]$dbconnection
    )

    $connectionString = "Data Source=$dbconnection;Integrated Security=true;Initial Catalog=master;Connect Timeout=3;"
    $sqlConn = new-object ("Data.SqlClient.SqlConnection") $connectionString
    trap{
        Write-Host "Cannot connect."
        $sqlResult = "Failed"
    }
    $sqlConn.Open()
    if ($sqlConn.State -eq 'Open'){
        $sqlConn.Close();
        $sqlResult = "Successful"
        Write-Host "Success!" -ForegroundColor Green
    }
    return $sqlResult   
}
function Get-FormItemProperties {
    Param(
        [Parameter(Mandatory = $true)] $item,
        [Parameter(Mandatory = $false)] $dialogTitle,
        [Parameter(Mandatory = $false)] $propertiesOrder,
        [Parameter(Mandatory = $false)] $base64FormIcon,
        [Parameter(Mandatory = $false)] $note
    )
    
    if ($item -eq $null) {
        exit
    }
    
    if ($item.GetType().Name -eq "PSCustomObject") {
        $hashTable = @{ }
        $item.psobject.properties | ForEach-Object { $hashTable[$_.Name] = $_.Value }
        $item = $hashTable
    }
    
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    
    if ($dialogTitle -eq $null) {
        $dialogTitle = "Fill out values:"
    }
    
    $Panel = New-Object System.Windows.Forms.Panel
    $Panel.DockPadding.Bottom = 40
    $Panel.Dock = [System.Windows.Forms.DockStyle]::Fill
        
    $Font = New-Object System.Drawing.Font("Times New Roman", 12)
    
    $textboxY = 40
    $textboxHeight = 20
    $spaceBetweenTextboxes = $textboxHeight + 22
    
    $textboxes = @()
    
    if ($null -eq $propertiesOrder) {
        $propertiesOrder = $item.Keys
    }
    
    foreach ($key in $propertiesOrder) {
    
        $Label = New-Object System.Windows.Forms.Label
        $Label.Location = "20,$textboxY"
        $Label.size = "450,$textboxHeight" 
        $Label.Text = $key
    
        $textboxY += $spaceBetweenTextboxes / 2
    
        $TextBox = New-Object System.Windows.Forms.TextBox
        $TextBox.Location = "20,$textboxY"
        $TextBox.size = "450,$textboxHeight"  
            
        $TextBox.Text = $item[$key]
        $Panel.Controls.AddRange(@($Label, $TextBox))
        $textboxes += $TextBox
        $textboxY += $spaceBetweenTextboxes
        $TextBox.Font = $Font
    }
    
    $Panel.BorderStyle = 1
    $Panel.VerticalScroll.Enabled = $true;
    $Panel.VerticalScroll.Visible = $true;
    $Panel.AutoScroll = $true;
    
    
    $Form = New-Object System.Windows.Forms.Form
    $Form.Height = 380
    $Form.Width = 530
    $Form.Text = $dialogTitle
    $Form.Topmost = $true
    $Form.StartPosition = "CenterScreen"
    
    # Base 64 encoded image
    if ($base64FormIcon) {
        $iconBase64 = $base64FormIcon 
        $iconBytes = [Convert]::FromBase64String($iconBase64)
        $stream = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
        $stream.Write($iconBytes, 0, $iconBytes.Length);
        $iconImage = [System.Drawing.Image]::FromStream($stream, $true)
        $Form.Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $stream).GetHIcon())
    }

    if ($note){
        $NoteLabel = New-Object System.Windows.Forms.Label
        $NoteLabel.Location = "20,$textboxY"
        $NoteLabel.size = "450,50" 
        $NoteLabel.MaximumSize  = "500,50" 
        $NoteLabel.Font = 'Times New Roman,13'
        $NoteLabel.Text = $note
        $NoteLabel.AutoSize = $true
        $textboxY += $spaceBetweenTextboxes/2
        $Panel.Controls.AddRange(@($NoteLabel))
    }

    $ActionButtonHeight = 40
    $ActionButtonY = $GroupBox.size.Height + $GroupBox.Location.Y + 10
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Size = "100,$ActionButtonHeight" 
    $textboxY+= 30
    $OKButton.Location = "20,$textboxY"
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
 

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = "370,$textboxY"
    $CancelButton.Size = "100,$ActionButtonHeight"
    $CancelButton.Text = "Cancel"
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

    $Font = New-Object System.Drawing.Font("Times New Roman", 10)
    $Form.Font = $Font
        
    $form.Controls.AddRange(@($Panel))
    $Panel.Controls.AddRange(@($OKButton, $CancelButton))

    $form.AcceptButton = $OKButton
    $form.CancelButton = $CancelButton

    $form.Add_Shown( { $form.Activate() })   

    $dialogResult = $form.ShowDialog() 
        

    if ($dialogResult -eq "OK") {

        $hashTable = @{ }
        $i = 0;     
        foreach ($key in $propertiesOrder) {
            $hashTable[$key] = $textboxes[$i].Text
            $i++;
        }
        return $hashTable
    }
    else {
        throw "Execution was cancelled by the user"
    }

}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Continue"

$Inputs = ([ordered]@{
        EWF_Farm_URL     = "EWF.CityState.Name.jha-sys.com"
        EWF_SQL_Instance = "DBServerExample\Instance"
})
$Inputs = Get-FormItemProperties -item $Inputs -dialogTitle "Fill these required fields"

if (($inputs.EWF_Farm_URL -like "EWF.CityState.Name.jha-sys.com") <#-or ($inputs.EWF_SQL_Instance -like "DBServerExample\Instance")#>){
   Write-Host "Please restart this script and check that you are inputting valid information in the required fields" -ForegroundColor Red
   return
}

$ewfFarm = $inputs.EWF_Farm_URL
$ewfSQL = $inputs.EWF_SQL_Instance

Write-host "`nChecking DNS for $ewfFarm"
Try {
    $dns = (Resolve-DnsName $ewfFarm -DnsOnly -ErrorAction Stop).Ipaddress -join ', '
    if ($dns){
        $ewfFarmTest = $dns
        Write-Host "Success!" -ForegroundColor Green
    }
    else {
    $ewfFarmTest = $dns
    Write-Host "There was an issue verifying DNS records for $ewfFarm" 
    }
}
Catch {
    Write-Host "There was an issue verifying DNS records for $ewfFarm"
    if($_.ErrorDetails.Message) {
        $ewfFarmTest = $_.ErrorDetails.Message
    } else {
        $ewfFarmTest = $_
    }
}
Start-Sleep -Seconds 1

Write-host "`nChecking connectivity to $ewfSql"
Try {
    $sqlResult = Test-SQL -dbconnection $ewfSQL
}
Catch {
    Write-Host "Error connecting to SQL Server"
    $sqlResult = "Failed"
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1

Write-Host "`nTesting connection to required websites" -ForegroundColor Yellow
Start-Sleep -Seconds 1
Write-Host "Checking secure.JHAHosted.com"
Try {
    $response = (Invoke-WebRequest "https://secure.jhahosted.com" -UseBasicParsing).StatusCode
    if ($response -like "200"){
        $jhahostedTest = "Successful"
        Write-Host "Success!" -ForegroundColor Green
    }
    else {
    $jhahostedTest = $response
    }
}
Catch {
    Write-Host "There was an issue verifying this URL"
    if($_.ErrorDetails.Message) {
        $jhahostedTest = $_.ErrorDetails.Message
    } else {
        $jhahostedTest = $_
    }
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1
Write-Host "Checking go.Microsoft.com"
Try {
    $response = (Invoke-WebRequest "https://go.Microsoft.com" -UseBasicParsing).StatusCode
    if ($response -like "200"){
        $MicrosoftTest = "Successful"
        Write-Host "Success!" -ForegroundColor Green
    }
    else {
    $MicrosoftTest = $response
    }
}
Catch {
    Write-Host "There was an issue verifying this URL"
    if($_.ErrorDetails.Message) {
        $MicrosoftTest = $_.ErrorDetails.Message
    } else {
        $MicrosoftTest = $_
    }
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1
Write-Host "Checking api.Github.com"
Try {
    $response = (Invoke-WebRequest "https://api.Github.com" -UseBasicParsing).StatusCode
    if ($response -like "200"){
        $GithubTest = "Successful"
        Write-Host "Success!" -ForegroundColor Green
    }
    else {
    $GithubTest = $response
    }
}
Catch {
    Write-Host "There was an issue verifying this URL"
    if($_.ErrorDetails.Message) {
        $GithubTest = $_.ErrorDetails.Message
    } else {
        $GithubTest = $_
    }
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1

Write-Host "`nChecking if .NET 4.8 is installed"
Try {
    $dotNetInstalled = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 528040
    Write-Host "Confirmed!" -ForegroundColor Green
}
Catch{
    $dotNetInstalled = ".NET Version Unavailable"
    Write-Host "There was an issue verifying this application"
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1


#Getting full list of installed software
$installedSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
$installedList = foreach($obj in $InstalledSoftware){$obj.GetValue('DisplayName') + " - " + $obj.GetValue('DisplayVersion')}

Write-Host "`nChecking if XCA is installed"
Try {
    $xcaInstalled = $installedList | Where-Object {$_ -like "*xperience client agent*"}
    if (!$xcaInstalled){$xcaInstalled = "Not Installed"}
    Write-Host "Confirmed!" -ForegroundColor Green
}
Catch{
    $xcaInstalled = "XCA Version Unavailable"
    Write-Host "There was an issue verifying this application"
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1

Write-Host "Checking if Support Account is a member of the local administrators group"
Try {
    $adminlist = (net localgroup Administrators) | Where-Object { $_ -match '\S' } | Select-Object -Skip 4 | Select-Object -SkipLast 1
    $members = ($adminlist | Where-Object { $_ -like "*support*"}) -join ", "
    if (!$members){
        $members = "Not Present"
        Write-Host "Support accounts may not be present"
        }
    if ($members){
        Write-Host "Success!" -ForegroundColor Green
        }
    
}
Catch{
    $members = "Error"
    Write-Host "Error verifying group membership"
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1


Write-Host "`nGetting a list of possible EWF AD Groups"
Try {
    $groupsFound = Get-EWFGroups
    Write-Host "Success!" -ForegroundColor Green
    if ($groupsFound -like $null){
        Write-Host "No Groups Found"
        $groupsFound = "No Groups Found"
    }
}
Catch {
    $groupsFound = "Error"
    Write-Host "Error while looking up EWF Groups"
}
Start-Sleep -Seconds 1

Write-Host "`nGetting a list of possible EWF AD Users"
Try {
    $usersFound = Get-EWFUsers
    Write-Host "Success!" -ForegroundColor Green
    if ($usersFound -like $null){
        Write-Host "No Users Found"
        $usersFound = "No Users Found"
    }
}
Catch {
    $usersFound = "Error"
    Write-Host "Error while looking up EWF Users" 
}
Start-Sleep -Seconds 1

Write-Host "`nChecking if Webex Remote Access is installed"
Try {
    $HNA = (Get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\WebEx\Config\RA\General -Name "HNA" -ErrorAction SilentlyContinue).HNA 
    If ($HNA -like $null){
        $HNA = "Not Installed"
        Write-Host "Successfully Checked" -ForegroundColor Green
    }
}
Catch {
    $HNA = "Error querying the Registry"
    Start-Sleep -Seconds 1
}
Start-Sleep -Seconds 1

$testResults = New-Object -TypeName PSObject -Property ([ordered]@{
    'JackHenry.com' = $jackhenryTest
    'JHAHosted.com' = $jhahostedTest
    'Microsoft.com' = $MicrosoftTest
    'Github.com' = $GithubTest
    '.NET 4.8 Installed' = $dotNetInstalled
    'XCA Installed' = $xcaInstalled
    'EWF URL' = $ewfFarm
    'EWF DNS Records' = $ewfFarmTest
    'SQL Connectivity' = $sqlResult
    'SQL Instance' = $ewfSQL
    'Support Accounts as Admin' = $members
    'Server Hostname' = $env:COMPUTERNAME
    'EWF Users Found' = $usersFound
    'EWF Groups Found' = $groupsFound
    'SmartTech Entry Name' = $HNA
})

Write-Host "`nPlease screenshot or copy the results below and email to jhaEnterpriseWorkflowImplementation@jackhenry.com" -BackgroundColor Yellow -ForegroundColor Black
Write-Host "If you have multiple EWF application servers, please repeat this process on those additional servers"

Start-Sleep -Seconds 2

#outputting the log to a csv file
$outputDir = "C:\EWFTests"
Write-Host "`nAttempting to output a log file to $outputDir"
if (-not (Test-Path -LiteralPath $outputDir)) {
    Write-Host "Folder does not exist"
    try {
        New-Item -Path $outputDir -ItemType Directory -ErrorAction Stop | Out-Null #-Force
        Write-Host "folder Created"
    }
    catch {
        Write-Error -Message "Unable to create directory '$outputDir'. Error was: $_" -ErrorAction Stop
    }
}
if (Test-Path -LiteralPath $outputDir) {
    try {
        $filename = "$outputDir\Results_$(Get-Date -UFormat '%Y%m%d_%H%M%S')_EWF_appserver.$env:COMPUTERNAME.csv" 
        $testResults | Export-Csv -LiteralPath $filename -NoTypeInformation
        Write-Host "Log created"
        Write-Host "$filename"
    }
    catch {
        Write-Error -Message "Unable to create log file $filename"  -ErrorAction Continue
        Start-Sleep -Seconds 1
    }
}
Start-Sleep -Seconds 1
return $testResults

# SIG # Begin signature block
# MIIvbgYJKoZIhvcNAQcCoIIvXzCCL1sCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCYwee3yuMEfvn6
# 2DNmEFg70Z/ID7xW0VDldT7tzOqb36CCFFMwggWQMIIDeKADAgECAhAFmxtXno4h
# MuI5B72nd3VcMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0xMzA4MDExMjAwMDBaFw0z
# ODAxMTUxMjAwMDBaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0
# IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3EMB/z
# G6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKyunWZ
# anMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsFxl7s
# Wxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU15zHL
# 2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJBMtfb
# BHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObURWBf3
# JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6nj3c
# AORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxBYKqx
# YxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5SUUd0
# viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+xq4aL
# T8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjQjBAMA8GA1Ud
# EwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGGMB0GA1UdDgQWBBTs1+OC0nFdZEzf
# Lmc/57qYrhwPTzANBgkqhkiG9w0BAQwFAAOCAgEAu2HZfalsvhfEkRvDoaIAjeNk
# aA9Wz3eucPn9mkqZucl4XAwMX+TmFClWCzZJXURj4K2clhhmGyMNPXnpbWvWVPjS
# PMFDQK4dUPVS/JA7u5iZaWvHwaeoaKQn3J35J64whbn2Z006Po9ZOSJTROvIXQPK
# 7VB6fWIhCoDIc2bRoAVgX+iltKevqPdtNZx8WorWojiZ83iL9E3SIAveBO6Mm0eB
# cg3AFDLvMFkuruBx8lbkapdvklBtlo1oepqyNhR6BvIkuQkRUNcIsbiJeoQjYUIp
# 5aPNoiBB19GcZNnqJqGLFNdMGbJQQXE9P01wI4YMStyB0swylIQNCAmXHE/A7msg
# dDDS4Dk0EIUhFQEI6FUy3nFJ2SgXUE3mvk3RdazQyvtBuEOlqtPDBURPLDab4vri
# RbgjU2wGb2dVf0a1TD9uKFp5JtKkqGKX0h7i7UqLvBv9R0oN32dmfrJbQdA75PQ7
# 9ARj6e/CVABRoIoqyc54zNXqhwQYs86vSYiv85KZtrPmYQ/ShQDnUBrkG5WdGaG5
# nLGbsQAe79APT0JsyQq87kP6OnGlyE0mpTX9iV28hWIdMtKgK1TtmlfB2/oQzxm3
# i0objwG2J5VT6LaJbVu8aNQj6ItRolb58KaAoNYes7wPD1N1KarqE3fk3oyBIa0H
# EEcRrYc9B9F1vM/zZn4wggawMIIEmKADAgECAhAIrUCyYNKcTJ9ezam9k67ZMA0G
# CSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0
# IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0zNjA0MjgyMzU5NTla
# MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UE
# AxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEz
# ODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDVtC9C
# 0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0JAfhS0/TeEP0F9ce
# 2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJrQ5qZ8sU7H/Lvy0da
# E6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhFLqGfLOEYwhrMxe6T
# SXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+FLEikVoQ11vkunKoA
# FdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh3K3kGKDYwSNHR7Oh
# D26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJwZPt4bRc4G/rJvmM
# 1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQayg9Rc9hUZTO1i4F4z
# 8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbIYViY9XwCFjyDKK05
# huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchApQfDVxW0mdmgRQRNY
# mtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRroOBl8ZhzNeDhFMJlP
# /2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IBWTCCAVUwEgYDVR0T
# AQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+YXsIiGX0TkIwHwYD
# VR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMG
# A1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYY
# aHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2Fj
# ZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNV
# HR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRU
# cnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAEDMAgGBmeBDAEEATAN
# BgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql+Eg08yy25nRm95Ry
# sQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFFUP2cvbaF4HZ+N3HL
# IvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1hmYFW9snjdufE5Btf
# Q/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3RywYFzzDaju4ImhvTnh
# OE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5UbdldAhQfQDN8A+KVssIh
# dXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw8MzK7/0pNVwfiThV
# 9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnPLqR0kq3bPKSchh/j
# wVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatEQOON8BUozu3xGFYH
# Ki8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bnKD+sEq6lLyJsQfmC
# XBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQjiWQ1tygVQK+pKHJ6l
# /aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbqyK+p/pQd52MbOoZW
# eE4wgggHMIIF76ADAgECAhAEnhjl/1RuI+msAJeJQ0XLMA0GCSqGSIb3DQEBCwUA
# MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UE
# AxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEz
# ODQgMjAyMSBDQTEwHhcNMjIxMjA1MDAwMDAwWhcNMjUxMjA0MjM1OTU5WjCBzzEL
# MAkGA1UEBhMCVVMxETAPBgNVBAgTCE1pc3NvdXJpMQ8wDQYDVQQHEwZNb25ldHQx
# JjAkBgNVBAoMHUpBQ0sgSEVOUlkgJiBBU1NPQ0lBVEVTLCBJTkMuMQwwCgYDVQQL
# EwNKSEExJjAkBgNVBAMMHUpBQ0sgSEVOUlkgJiBBU1NPQ0lBVEVTLCBJTkMuMT4w
# PAYJKoZIhvcNAQkBFi9zY3MtZW50ZXJwcmlzZWFwcGxpY2F0aW9uc2VjdXJpdHlA
# amFja2hlbnJ5LmNvbTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOgi
# xeUMAFmrqp74p+wJ8bMFvtDGCwKLGfgWajix3ydS8RvrZBpdoCTuKKyHEi40wxxg
# ZRSN/t4vWy3KLsRjo+p4roNghBhha/ZzHXgxBvaOCYq95meVpzbg+HK6scMaY7BB
# J9qD8sWKHRMRsYcnW6rkyM4QzQPAxxOUh50G55UKfcNwXqyrX2XDEl3H/Oqzqy2I
# iUXANSv1SNizVKP9JQ6zSMSFjg2IjNKUvalzRIi6slB/YKc66SC6yDkYRM3Cipj/
# cp2SM68UbI/SzxnSxaVLhXSA2qWLAAFfaJN8DFVyEb3wv8PqwXXoxI4NwMfchiar
# NftZP0N2K4hOawk8i1/z8k/mDYUyYdNUogW8M/yQuWDE/hweRuE7ELfLZ/t3X1+A
# tvloAqIXw7REB8iVYkLWccdTB4cgB1jrf/a+bufW5v+VCL0PUOCI1ybtcRhzrUHJ
# ++617mEcZ0idAYjy3ht+Uu5HWfLzOBj+VoksvcCcIcJLVkIEP3kZrpx3pezqVRMF
# 1IKA/pOk/LonzBmle1kjGOLXUVJvpP+D8XBYlfodLthh+QcLGXQ43Auju5iVj2eB
# jfKo78HZ/fIKMs/abaFLjAyc+BjonbfY/BkMU+uvXvNY1ukd9hHJv6yWPNytwnfY
# SDci9CFNeKJd5CyXzkpDyWV2bXeqlOaObkJnkwZ5AgMBAAGjggJCMIICPjAfBgNV
# HSMEGDAWgBRoN+Drtjv4XxGG+/5hewiIZfROQjAdBgNVHQ4EFgQUdNMpUD79Bofk
# bPXDNv4fz2uM8iUwOgYDVR0RBDMwMYEvc2NzLWVudGVycHJpc2VhcHBsaWNhdGlv
# bnNlY3VyaXR5QGphY2toZW5yeS5jb20wDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQM
# MAoGCCsGAQUFBwMDMIG1BgNVHR8Ega0wgaowU6BRoE+GTWh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVTaWduaW5nUlNBNDA5NlNI
# QTM4NDIwMjFDQTEuY3JsMFOgUaBPhk1odHRwOi8vY3JsNC5kaWdpY2VydC5jb20v
# RGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQwOTZTSEEzODQyMDIxQ0Ex
# LmNybDA+BgNVHSAENzA1MDMGBmeBDAEEATApMCcGCCsGAQUFBwIBFhtodHRwOi8v
# d3d3LmRpZ2ljZXJ0LmNvbS9DUFMwgZQGCCsGAQUFBwEBBIGHMIGEMCQGCCsGAQUF
# BzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wXAYIKwYBBQUHMAKGUGh0dHA6
# Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENvZGVTaWdu
# aW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZI
# hvcNAQELBQADggIBAGqYSbML7WwPyOgy61boAp0pzdphKkU9F0cw34nHKmX6TkT7
# GGF03Ujx6+pJaSaHbCc7KpM4tHVIbKHAcEwTzqaul9yvxc9wk4JwlFW7B4NfWMle
# XJRXPfU0+y18AfZnWzhAPdjaRPPjKvskQWGv/IAhr1Y8qy+mhPk5PT7D1y6FIXmC
# LoAme37+j94n/JlYsU2NTVJOO9FNHgBATgLDxr5I6MYN1Gj8OHjb019mauVUoO0L
# 7vgQxNO5ZAQ1xXm2/bIEA8bSRgvUb6DVpDmb2aiveb0Tw7rR+7xTzECDG36rFlHg
# fFO8TGKKaaavGUlns8hyXY5+KhN/7W31I64TIuvnqUKOcqMvrjEcDajOQx6j9Eor
# NXTTEVWOBSXS9vhdrABSZ+uVnyF6tm6rfdB8nCDN/v9bMJ2MvFTyk0JNdLafMR6G
# idjzYb6ulle4NOy2aUYFcMDplYByPYvQ3/XKUCZgqFR3jY+Tb7Z5VSMqFxsyuXsP
# XR1cxIzi9b7KTzL/nlQRfNyENtbRrLBSRGFmmCLcVeTXB0dV6fYDYRJE82VCZ8ao
# 3bQPnbQv4o7Do5yga3dfQeMryT5W/fL/zFANrXAJu6N+C7lpWUTGsrXAj71ErY47
# 4FzzvQgQ8ENbCyRU7p9Xni/ORs7+ZeScw8zlAGtV4EKsO3Wl0KpYkPawsTGhMYIa
# cTCCGm0CAQEwfTBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgQ29kZSBTaWduaW5nIFJT
# QTQwOTYgU0hBMzg0IDIwMjEgQ0ExAhAEnhjl/1RuI+msAJeJQ0XLMA0GCWCGSAFl
# AwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkD
# MQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJ
# KoZIhvcNAQkEMSIEICEZoZU1id35V0fdwHnEDGwWh9X0uWmYRT5E/8n+Xd3IMA0G
# CSqGSIb3DQEBAQUABIICAD+knej2KYg87ViIqwFp4DMlMz3PfcKBX17paC/DUhp6
# JCvBdPMVE7MbGzWHhX6ly2MYtY6iO3T6OmOL8O6dGvT2XAG1fyXGQXlSEQhMI28i
# 4IN5S1NeOP0ZgP2nxhIzETfUJ5/KZOHjDSlzEONSfsfYtawQTPlhl9f+OQBG8ivo
# Oqlj0ZlRDbDN/WU20pVkI0e/BZRU5hI4+Fo6tXQOm6zsn0JJpx9aO1rhEgeHV3d+
# 0dvDT+/RsfwQL3PZ2bRi2s1w2ceWMa0CxA+6Qo1/oLhIY/cWkrYr/8xpJwmkpP0z
# xlBAYlFURB1wCX32tXVrqFuwOto3CdBgSvinauquuMp1cg63HUcVArtVl1XTbUzO
# U4S1LM25UL2E8SXcjMae4qhKn4+ooBzCV7eYOHvUpNmfa1bbuhMK7sX0aT9LcU8D
# ykjg9sBcENA68RdtgJ0VNOOMQ1/2kTdDKOVpWHl0jfRmI/cz5Jj2lZaqhiymZjoN
# k5pI8nvCZUGQQvNuJ0omtjEzddTapmcHX0MH+38WoXGv3Wu3BULB2PeAbiBRxdxz
# iOi2YxaX7l7f7zz8Am3QmDlDhaR3eU0gqxCNvt+Siy6yBJTpVdFyONlmUV3Yglut
# At3FxwpywixPFqtimHfnpZlTfYupUSECMxuGmOljbLZncReK7vAb9RlFulF4szmV
# oYIXPjCCFzoGCisGAQQBgjcDAwExghcqMIIXJgYJKoZIhvcNAQcCoIIXFzCCFxMC
# AQMxDzANBglghkgBZQMEAgEFADB4BgsqhkiG9w0BCRABBKBpBGcwZQIBAQYJYIZI
# AYb9bAcBMDEwDQYJYIZIAWUDBAIBBQAEIJOdkZZKtPjc98FJdNuRMgKW+uCtSDrf
# laEEefbhQA9sAhEAtHFhRqYLL1j+vd+XEWT52BgPMjAyMzA0MDMyMDEwMjNaoIIT
# BzCCBsAwggSooAMCAQICEAxNaXJLlPo8Kko9KQeAPVowDQYJKoZIhvcNAQELBQAw
# YzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQD
# EzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGlu
# ZyBDQTAeFw0yMjA5MjEwMDAwMDBaFw0zMzExMjEyMzU5NTlaMEYxCzAJBgNVBAYT
# AlVTMREwDwYDVQQKEwhEaWdpQ2VydDEkMCIGA1UEAxMbRGlnaUNlcnQgVGltZXN0
# YW1wIDIwMjIgLSAyMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAz+yl
# JjrGqfJru43BDZrboegUhXQzGias0BxVHh42bbySVQxh9J0Jdz0Vlggva2Sk/QaD
# FteRkjgcMQKW+3KxlzpVrzPsYYrppijbkGNcvYlT4DotjIdCriak5Lt4eLl6FuFW
# xsC6ZFO7KhbnUEi7iGkMiMbxvuAvfTuxylONQIMe58tySSgeTIAehVbnhe3yYbyq
# Ogd99qtu5Wbd4lz1L+2N1E2VhGjjgMtqedHSEJFGKes+JvK0jM1MuWbIu6pQOA3l
# jJRdGVq/9XtAbm8WqJqclUeGhXk+DF5mjBoKJL6cqtKctvdPbnjEKD+jHA9QBje6
# CNk1prUe2nhYHTno+EyREJZ+TeHdwq2lfvgtGx/sK0YYoxn2Off1wU9xLokDEaJL
# u5i/+k/kezbvBkTkVf826uV8MefzwlLE5hZ7Wn6lJXPbwGqZIS1j5Vn1TS+QHye3
# 0qsU5Thmh1EIa/tTQznQZPpWz+D0CuYUbWR4u5j9lMNzIfMvwi4g14Gs0/EH1OG9
# 2V1LbjGUKYvmQaRllMBY5eUuKZCmt2Fk+tkgbBhRYLqmgQ8JJVPxvzvpqwcOagc5
# YhnJ1oV/E9mNec9ixezhe7nMZxMHmsF47caIyLBuMnnHC1mDjcbu9Sx8e47LZInx
# scS451NeX1XSfRkpWQNO+l3qRXMchH7XzuLUOncCAwEAAaOCAYswggGHMA4GA1Ud
# DwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
# MCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATAfBgNVHSMEGDAWgBS6
# FtltTYUvcyl2mi91jGogj57IbzAdBgNVHQ4EFgQUYore0GH8jzEU7ZcLzT0qlBTf
# UpwwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNybDCB
# kAYIKwYBBQUHAQEEgYMwgYAwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2lj
# ZXJ0LmNvbTBYBggrBgEFBQcwAoZMaHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0VHJ1c3RlZEc0UlNBNDA5NlNIQTI1NlRpbWVTdGFtcGluZ0NBLmNy
# dDANBgkqhkiG9w0BAQsFAAOCAgEAVaoqGvNG83hXNzD8deNP1oUj8fz5lTmbJeb3
# coqYw3fUZPwV+zbCSVEseIhjVQlGOQD8adTKmyn7oz/AyQCbEx2wmIncePLNfIXN
# U52vYuJhZqMUKkWHSphCK1D8G7WeCDAJ+uQt1wmJefkJ5ojOfRu4aqKbwVNgCeij
# uJ3XrR8cuOyYQfD2DoD75P/fnRCn6wC6X0qPGjpStOq/CUkVNTZZmg9U0rIbf35e
# Ca12VIp0bcrSBWcrduv/mLImlTgZiEQU5QpZomvnIj5EIdI/HMCb7XxIstiSDJFP
# PGaUr10CU+ue4p7k0x+GAWScAMLpWnR1DT3heYi/HAGXyRkjgNc2Wl+WFrFjDMZG
# QDvOXTXUWT5Dmhiuw8nLw/ubE19qtcfg8wXDWd8nYiveQclTuf80EGf2JjKYe/5c
# QpSBlIKdrAqLxksVStOYkEVgM4DgI974A6T2RUflzrgDQkfoQTZxd639ouiXdE4u
# 2h4djFrIHprVwvDGIqhPm73YHJpRxC+a9l+nJ5e6li6FV8Bg53hWf2rvwpWaSxEC
# yIKcyRoFfLpxtU56mWz06J7UWpjIn7+NuxhcQ/XQKujiYu54BNu90ftbCqhwfvCX
# hHjjCANdRyxjqCU4lwHSPzra5eX25pvcfizM/xdMTQCi2NYBDriL7ubgclWJLCcZ
# YfZ3AYwwggauMIIElqADAgECAhAHNje3JFR82Ees/ShmKl5bMA0GCSqGSIb3DQEB
# CwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNV
# BAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQg
# Um9vdCBHNDAeFw0yMjAzMjMwMDAwMDBaFw0zNzAzMjIyMzU5NTlaMGMxCzAJBgNV
# BAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNl
# cnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0EwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDGhjUGSbPBPXJJUVXHJQPE8pE3
# qZdRodbSg9GeTKJtoLDMg/la9hGhRBVCX6SI82j6ffOciQt/nR+eDzMfUBMLJnOW
# bfhXqAJ9/UO0hNoR8XOxs+4rgISKIhjf69o9xBd/qxkrPkLcZ47qUT3w1lbU5ygt
# 69OxtXXnHwZljZQp09nsad/ZkIdGAHvbREGJ3HxqV3rwN3mfXazL6IRktFLydkf3
# YYMZ3V+0VAshaG43IbtArF+y3kp9zvU5EmfvDqVjbOSmxR3NNg1c1eYbqMFkdECn
# wHLFuk4fsbVYTXn+149zk6wsOeKlSNbwsDETqVcplicu9Yemj052FVUmcJgmf6Aa
# RyBD40NjgHt1biclkJg6OBGz9vae5jtb7IHeIhTZgirHkr+g3uM+onP65x9abJTy
# UpURK1h0QCirc0PO30qhHGs4xSnzyqqWc0Jon7ZGs506o9UD4L/wojzKQtwYSH8U
# NM/STKvvmz3+DrhkKvp1KCRB7UK/BZxmSVJQ9FHzNklNiyDSLFc1eSuo80VgvCON
# WPfcYd6T/jnA+bIwpUzX6ZhKWD7TA4j+s4/TXkt2ElGTyYwMO1uKIqjBJgj5FBAS
# A31fI7tk42PgpuE+9sJ0sj8eCXbsq11GdeJgo1gJASgADoRU7s7pXcheMBK9Rp61
# 03a50g5rmQzSM7TNsQIDAQABo4IBXTCCAVkwEgYDVR0TAQH/BAgwBgEB/wIBADAd
# BgNVHQ4EFgQUuhbZbU2FL3MpdpovdYxqII+eyG8wHwYDVR0jBBgwFoAU7NfjgtJx
# XWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUF
# BwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGln
# aWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJo
# dHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNy
# bDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEwDQYJKoZIhvcNAQEL
# BQADggIBAH1ZjsCTtm+YqUQiAX5m1tghQuGwGC4QTRPPMFPOvxj7x1Bd4ksp+3CK
# Daopafxpwc8dB+k+YMjYC+VcW9dth/qEICU0MWfNthKWb8RQTGIdDAiCqBa9qVbP
# FXONASIlzpVpP0d3+3J0FNf/q0+KLHqrhc1DX+1gtqpPkWaeLJ7giqzl/Yy8ZCaH
# bJK9nXzQcAp876i8dU+6WvepELJd6f8oVInw1YpxdmXazPByoyP6wCeCRK6ZJxur
# JB4mwbfeKuv2nrF5mYGjVoarCkXJ38SNoOeY+/umnXKvxMfBwWpx2cYTgAnEtp/N
# h4cku0+jSbl3ZpHxcpzpSwJSpzd+k1OsOx0ISQ+UzTl63f8lY5knLD0/a6fxZsNB
# zU+2QJshIUDQtxMkzdwdeDrknq3lNHGS1yZr5Dhzq6YBT70/O3itTK37xJV77Qpf
# MzmHQXh6OOmc4d0j/R0o08f56PGYX/sr2H7yRp11LB4nLCbbbxV7HhmLNriT1Oby
# F5lZynDwN7+YAN8gFk8n+2BnFqFmut1VwDophrCYoCvtlUG3OtUVmDG0YgkPCr2B
# 2RP+v6TR81fZvAT6gt4y3wSJ8ADNXcL50CN/AAvkdgIm2fBldkKmKYcJRyvmfxqk
# hQ/8mJb2VVQrH4D6wPIOK+XW+6kvRBVK5xMOHds3OBqhK/bt1nz8MIIFjTCCBHWg
# AwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwFADBlMQswCQYDVQQG
# EwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNl
# cnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcN
# MjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEVMBMG
# A1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEw
# HwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKnJS7JIT3yithZwuEp
# pz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/WBTxSD1Ifxp4VpX6+
# n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHiLQwb7iDVySAdYykt
# zuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhmV1efVFiODCu3T6cw
# 2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQjdjUN6Qu
# BX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/CNdaSaTC
# 5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCiEhtmmnTK
# 3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZxd9LBADMfRyVw4/3
# IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QYuKZ3AeEP
# lAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvlEFDrMcXKchYiCd98
# THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t9dmpsh3l
# GwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU7NfjgtJx
# XWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8w
# DgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MEUGA1Ud
# HwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFz
# c3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAAMA0GCSqGSIb3DQEB
# DAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzshV6pGrsi+IcaaVQi
# 7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre+i1Wz/n096wwepqL
# sl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8vC6bp8jQ87PcDx4eo
# 0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38dglohJ9vytsgjTVg
# HAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNrIv8SuFQtJ37YOtnw
# toeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMYIDdjCCA3ICAQEwdzBjMQswCQYDVQQG
# EwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0
# IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBAhAMTWly
# S5T6PCpKPSkHgD1aMA0GCWCGSAFlAwQCAQUAoIHRMBoGCSqGSIb3DQEJAzENBgsq
# hkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjMwNDAzMjAxMDIzWjArBgsqhkiG
# 9w0BCRACDDEcMBowGDAWBBTzhyJNhjOCkjWplLy9j5bp/hx8czAvBgkqhkiG9w0B
# CQQxIgQgl6+So1iW2jGhiFaW9whUrvfOghxGVeaymz5OA3+y2mswNwYLKoZIhvcN
# AQkQAi8xKDAmMCQwIgQgx/ThvjIoiSCr4iY6vhrE/E/meBwtZNBMgHVXoCO1tvow
# DQYJKoZIhvcNAQEBBQAEggIAZ9i/WD5xwt6YQDjwcGAR5hNi7PwOdw9iuARGntK8
# naCwAB6xDUE1+/99uMVY4s7H1gAfhkC6eNr4E6QY3H89LeZLAcjL72bT+OnzdJ1U
# B5ZWjfWeR5N+cEV1ltC6B7AzdLTHgeFGbicCeIwfWSjTvCSZrK7KcLzeRh0Q9OiE
# if38rgygemrJ2HLzGxo7loX+FvijtQEYmQLbqEo+mg43iw3p2fhjVfVuNBF4jeNw
# oGXnKIk1ADGLSJKs0c+LpU88qHcHHkPBXL2W2ePb4qK61nHkHIA+ypAVs2SeX+c+
# WrCbVS41sTazKcKkJ3AQyom0GyePrCM0hKisqZ7rpRA1HFnFymIrXyInCG7V47GO
# I3fpAaGvzff7kbQB3V7W8SF+9YCckxdpL2R1/2scQmEQD+7v2lZlp5192Bl8BJ0D
# g4khhUAEa3s5P8TgirSJlD/+jlOGOWKpAWcy0YHRK9JDBEdwYllKtd48oYO8WjA+
# 0UH9UF3NBxxLSq+uSDtUC4ExeT7u599zb/XY+/4P/CZK6hujFY173yl5tlmewdHF
# QeaEUW66gsCkSWrOBqU/3mVTz214Er5OMjboepx8EHbMzVGkZYi/sVoS0NdZs3QB
# 8Dk5Mx2Ksm2KNNVVh8qyoAUHn65GPl0MWKaBGfNq4BKynRFwnMqm+wEYdWSi2DVz
# WRg=
# SIG # End signature block
