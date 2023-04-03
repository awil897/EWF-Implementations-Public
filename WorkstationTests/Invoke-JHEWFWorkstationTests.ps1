enum ControlType {
    RadioButtons = 1
    ComboBox = 2
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
    
    #-----------------------------------------------------------------------
    # Convert the object to hashtable
    #-----------------------------------------------------------------------
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
    
    #-----------------------------------------------------------------------
    # Create a group that will contain textboxes
    #-----------------------------------------------------------------------
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

    #-----------------------------------------------------------------------
    # Add a note
    #-----------------------------------------------------------------------
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

    
    #-----------------------------------------------------------------------
    # Add an OK button
    #-----------------------------------------------------------------------
    $ActionButtonHeight = 40
    $ActionButtonY = $GroupBox.size.Height + $GroupBox.Location.Y + 10
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Size = "100,$ActionButtonHeight" 
    $textboxY+= 30
    $OKButton.Location = "20,$textboxY"
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
 
    #-----------------------------------------------------------------------
    # Add an Cancel button
    #-----------------------------------------------------------------------
    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = "370,$textboxY"
    $CancelButton.Size = "100,$ActionButtonHeight"
    $CancelButton.Text = "Cancel"
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel


     
    #-----------------------------------------------------------------------
    # Set the font of the text to be used within the form
    #-----------------------------------------------------------------------
    $Font = New-Object System.Drawing.Font("Times New Roman", 10)
    $Form.Font = $Font
        
    $form.Controls.AddRange(@($Panel))
    
    $Panel.Controls.AddRange(@($OKButton, $CancelButton))
    
    #-----------------------------------------------------------------------
    # Assign the Accept and Cancel options in the form to the corresponding buttons
    #-----------------------------------------------------------------------
    $form.AcceptButton = $OKButton
    $form.CancelButton = $CancelButton

        
    #-----------------------------------------------------------------------
    # Activate the form
    #-----------------------------------------------------------------------
    $form.Add_Shown( { $form.Activate() })   
    #-----------------------------------------------------------------------
    # Get the results from the button click
    #-----------------------------------------------------------------------
    $dialogResult = $form.ShowDialog() 
        
    #-----------------------------------------------------------------------
    # If the OK button is selected
    #-----------------------------------------------------------------------
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
function Get-FormBinaryAnswer {
    Param(
        [Parameter(Position = 0)] $dialogTitle
    )

    $options = @([pscustomobject]@{Value = $true; Name = "Yes" }, [pscustomobject]@{Value = $false; Name = "No" })
    $answer = Get-FormArrayItem -items $options -key "Name" -dialogTitle $dialogTitle
    return $answer.Value
}
function Get-FormStringInput {
    Param(
        [Parameter(Mandatory = $true, Position = 0)] $dialogTitle,
        [Parameter(Position = 1)] $defaultValue 
    )

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")     

    $label = New-Object System.Windows.Forms.Label
    $label.size = "350,50"
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $label.Text = $dialogTitle
    $Font = New-Object System.Drawing.Font("Times New Roman", 12)
    $label.Font = $Font

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.size = "400,50"
    $textBox.Location = New-Object System.Drawing.Point(10, 60)
    $Font = New-Object System.Drawing.Font("Times New Roman", 15)
    $textBox.Font = $Font
    $textBox.Text = $defaultValue

    #-----------------------------------------------------------------------
    # Add an OK button
    #-----------------------------------------------------------------------
    $ActionButtonHeight = 40
    $ActionButtonY = 140
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = "130,$ActionButtonY"
    $OKButton.Size = "100,$ActionButtonHeight" 
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
 
    #-----------------------------------------------------------------------
    # Add an cancel button
    #----------------------------------------------------------------------
    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = "255,$ActionButtonY"
    $CancelButton.Size = "100,$ActionButtonHeight"
    $CancelButton.Text = "Cancel"
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

    $Form = New-Object System.Windows.Forms.Form
    $Form.width = $textBox.size.Width + 50
    $Form.height = $OKButton.Location.Y + $OKButton.Height + 80
    $Form.Text = $dialogTitle
    $Form.Topmost = $true
    $Form.StartPosition = "CenterScreen"
 
    #-----------------------------------------------------------------------
    # Set the font of the text to be used within the form
    #-----------------------------------------------------------------------
    $Font = New-Object System.Drawing.Font("Times New Roman", 10)
    $Form.Font = $Font
 
    #-----------------------------------------------------------------------
    # Add all the Form controls on one line 
    #-----------------------------------------------------------------------
    $form.Controls.AddRange(@($label, $textBox, $OKButton, $CancelButton))
    
    # Assign the Accept and Cancel options in the form to the corresponding buttons
    $form.AcceptButton = $OKButton
    $form.CancelButton = $CancelButton
 
    #-----------------------------------------------------------------------
    # Activate the form
    #-----------------------------------------------------------------------
    $form.Add_Shown( { $form.Activate() })    
    
    #-----------------------------------------------------------------------
    # Get the results from the button click
    #-----------------------------------------------------------------------
    $dialogResult = $form.ShowDialog()
 
    #-----------------------------------------------------------------------
    # If the OK button is selected
    #-----------------------------------------------------------------------
    if ($dialogResult -eq "OK") {
        return $textBox.Text   
        
    }
    else {
        throw "Execution was cencelled by the user"
    }
}
function Get-FormArrayItem {
    Param(
        [Parameter(Mandatory = $true)] $items,
        [Parameter(Mandatory = $false)] $key,
        [Parameter(Mandatory = $false)] $dialogTitle,
        [Parameter()] $defaultValue ,
        [ControlType]
        [Parameter(Mandatory = $false)] $ControlType = [ControlType]::RadioButtons
    )
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

    if ($items.Count -eq 0) {
        Write-Host "'$dialogTitle' dialog did not contain any items. Returning `$null"
        return $null
    }

    if($key -eq $null){
        $key = "Name"
    }

    if($dialogTitle -eq $null){
        $dialogTitle = "Choose one:"
    }

    #-----------------------------------------------------------------------
    # Create a group that will contain your radio buttons
    #-----------------------------------------------------------------------
    $TitleLabel = New-Object System.Windows.Forms.Label
    $TitleLabel.Location = '40,5'
    $TitleLabel.Text = $dialogTitle
    $Font = New-Object System.Drawing.Font("Times New Roman", 13)
    $TitleLabel.Font = $Font 
    $TitleLabel.Width = 350

    $Panel = New-Object System.Windows.Forms.Panel
    $Panel.Location = '40,30'
    $Panel.size = '400,1'
    $Panel.text = $dialogTitle

    $inputControlY = 10
    $radioButtonHeight = 20
    $spaceBetweenControls = $radioButtonHeight + 10
    $Panel.Height = $spaceBetweenControls + 20
    $MaximumPanelHeight = 290
    $RadioFont = New-Object System.Drawing.Font("Times New Roman", 12)

    $OKButton = New-Object System.Windows.Forms.Button
    
     
    if($ControlType -eq [ControlType]::RadioButtons){
        #-----------------------------------------------------------------------
        # Create the collection of radio buttons
        #-----------------------------------------------------------------------
        foreach ($item in $items) {
            $RadioButton = New-Object System.Windows.Forms.RadioButton
            $RadioButton.Location = "20,$inputControlY"
            $RadioButton.size = "550,$radioButtonHeight" 
            $RadioButton.Font = $RadioFont

            $props = Get-Member -InputObject $item -MemberType NoteProperty
        
            $prop = $props | Where-Object { $_.name -eq $key }
            $propValue = $item | Select-Object -ExpandProperty $prop.Name
            $RadioButton.Text = $propValue
            if ($RadioButton.Text -eq $defaultValue) {
                $RadioButton.Checked = $true 
            }
            else {
                $RadioButton.Checked = $false 
            }
            $Panel.Controls.AddRange($RadioButton)
            $inputControlY += $spaceBetweenControls

            if ($Panel.Height -lt $MaximumPanelHeight) {
                $Panel.Height += $spaceBetweenControls    
            }else{
                $Panel.BorderStyle = 1
                $Panel.VerticalScroll.Enabled = $true;
                $Panel.VerticalScroll.Visible = $true;
                $Panel.AutoScroll = $true;
            }
        }    
      
     }

    if($ControlType -eq [ControlType]::ComboBox){
        #-----------------------------------------------------------------------
        # Add Combobox with autocomplete
        #-----------------------------------------------------------------------
        $ComboBox                       = New-Object system.Windows.Forms.ComboBox
        $ComboBox.text                  = "comboBox"
        $ComboBox.width                 = 580
        $ComboBox.height                = 50
        $ComboBox.Location              = New-Object System.Drawing.Point(10,20)
        $ComboBox.Font                  = 'Times New Roman,12'

        ##############   DropDown #################

        $ComboBox.DropDownStyle  = [System.Windows.Forms.ComboBoxStyle]::DropDown;                      
        foreach($item in $items){
            $suppress = $ComboBox.Items.add($item)
        }
        $ComboBox.SelectedIndex = 1        
  
        ##############   AutoComplite #################

        $ComboBox.AutoCompleteSource      ='CustomSource'
        $ComboBox.AutoCompleteMode        ='SuggestAppend'
        foreach($item in $items){$ComboBox.AutoCompleteCustomSource.AddRange($item)}
        $choice = $ComboBox.Text

        ######## If Combobox text is different from list or null ###############

        $ComboBox.add_TextChanged({Combobox})
        $Panel.Controls.Add($ComboBox)
        $Panel.Height += $spaceBetweenControls    

        function Combobox{
            if ($ComboBox.SelectedItem -eq $null){
                $OKButton.Enabled = $false
            }else{
                $OKButton.Enabled = $true
            }
        }
    }


    #-----------------------------------------------------------------------
    # Add an OK button
    #-----------------------------------------------------------------------
    $ActionButtonHeight = 40
    $ActionButtonY = $Panel.size.Height + $Panel.Location.Y + 10
    # $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = "130,$ActionButtonY"
    $OKButton.Size = "100,$ActionButtonHeight" 
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
 
    #-----------------------------------------------------------------------
    #Add a cancel button
    #-----------------------------------------------------------------------
    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = "255,$ActionButtonY"
    $CancelButton.Size = "100,$ActionButtonHeight"
    $CancelButton.Text = "Cancel"
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

    $Form = New-Object System.Windows.Forms.Form
    $Form.width = $Panel.size.Width + 80
    $Form.height = $OKButton.Location.Y + $OKButton.Height + 60
    $Form.Text = $dialogTitle
    $Form.Topmost = $true
    $Form.StartPosition = "CenterScreen"
 
    #-----------------------------------------------------------------------
    # Set the font of the text to be used within the form
    #-----------------------------------------------------------------------
    $Font = New-Object System.Drawing.Font("Times New Roman", 10)
    $Form.Font = $Font 
    
    $form.Controls.AddRange(@($TitleLabel, $Panel, $OKButton, $CancelButton))
    
    #-----------------------------------------------------------------------
    # Assign the Accept and Cancel options in the form to the corresponding buttons
    #-----------------------------------------------------------------------
    $form.AcceptButton = $OKButton
    $form.CancelButton = $CancelButton
 
    #-----------------------------------------------------------------------
    # Activate the form
    #-----------------------------------------------------------------------
    $form.Add_Shown( { $form.Activate() })
       
    $dialogResult = $form.ShowDialog()
    
 
    #-----------------------------------------------------------------------
    # Get the results of the dialog
    #-----------------------------------------------------------------------
    if ($dialogResult -eq "OK") { 

        if($ControlType -eq [ControlType]::RadioButtons){
            $checkedControl = $Panel.Controls | Where-Object { ([System.Windows.Forms.RadioButton]$_).Checked -eq $true }
            $selectedValue = $checkedControl.Text
        }

        if($ControlType -eq [ControlType]::ComboBox){
             $selectedValue = $ComboBox.Text
        }


        return $items | Where-Object {                  
            $propValue = $_ | Select-Object -ExpandProperty $prop.Name
            $propValue.ToString() -eq $selectedValue
        }
        Write-Host $selectedValue
    }
    else {
        throw "Execution was cancelled by the user"
    }
}
function Test-Port {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, HelpMessage = 'Could be suffixed by :Port')]
        [String[]]$ComputerName,

        [Parameter(HelpMessage = 'Will be ignored if the port is given in the param ComputerName')]
        [Int]$Port = 443,

        [Parameter(HelpMessage = 'Timeout in millisecond. Increase the value if you want to test Internet resources.')]
        [Int]$Timeout = 500
    )

    begin {
        $result = [System.Collections.ArrayList]::new()
    }

    process {
        foreach ($originalComputerName in $ComputerName) {
            $remoteInfo = $originalComputerName.Split(":")
            if ($remoteInfo.count -eq 1) {
                # In case $ComputerName in the form of 'host'
                $remoteHostname = $originalComputerName
                $remotePort = $Port
            } elseif ($remoteInfo.count -eq 2) {
                # In case $ComputerName in the form of 'host:port',
                # we often get host and port to check in this form.
                $remoteHostname = $remoteInfo[0]
                $remotePort = $remoteInfo[1]
            } else {
                $msg = "Got unknown format for the parameter ComputerName: " `
                    + "[$originalComputerName]. " `
                    + "The allowed formats is [hostname] or [hostname:port]."
                Write-Error $msg
                return
            }

            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $portOpened = $tcpClient.ConnectAsync($remoteHostname, $remotePort).Wait($Timeout)

            $null = $result.Add([PSCustomObject]@{
                RemoteHostname       = $remoteHostname
                RemotePort           = $remotePort
                PortOpened           = $portOpened
                TimeoutInMillisecond = $Timeout
                SourceHostname       = $env:COMPUTERNAME
                OriginalComputerName = $originalComputerName
                })
        }
    }

    end {
        return $result
    }
}
function Test-Endpoint{
    param (
        [Parameter()]
        [String]$Endpoint
    )
    $dnsTest = $null
    $dnsResult = $null
    $portTest = $null
    $isIpAddress = [bool]($endpoint -as [ipaddress])

    Write-Host "`nTesting $endpoint" -ForegroundColor Yellow
    if ($isIpAddress -like "False"){
        Write-host "Checking DNS for $Endpoint"
        Try {
            $dnsTest = (Resolve-DnsName $Endpoint -DnsOnly  -ErrorAction SilentlyContinue).Ipaddress -join ', '
            if ($dnsTest){
                $dnsResult = 'Successful'
                Write-Host "Success!" -ForegroundColor Green
            }
            else {
            $dnsResult = 'Error'
            Write-Host "There was an issue verifying DNS records for $Endpoint" 
            }
        }
        Catch {
            Write-Host "There was an error verifying DNS records for $Endpoint"
            if($_.ErrorDetails.Message) {
                $dnsTest = $_.ErrorDetails.Message
                $dnsResult = 'Error'
            } else {
                $dnsTest = $_
                $dnsResult = 'Error'
            }
        }
        Start-Sleep -Seconds 1
    }

    if ($isIpAddress -like "True"){
        Write-Host "$endpoint is an IP address, skipping DNS tests"
        $dnsTest = "Test Skipped"
        $dnsResult = 'Test Skipped'
        Write-host "Checking connectivity to $Endpoint on port 443"
        Try {
            $portTest = Test-Port -ComputerName $Endpoint -Port 443 -Timeout 300
            if ($portTest.PortOpened -like "True"){
                $portTest = "Successful"
                Write-Host "Success!" -ForegroundColor Green
            }
            else {
            Write-Host "There was an issue verifying connectivity to $Endpoint"
            $portTest = "Error" 
            }
        }
        Catch {
            Write-Host "There was an issue verifying connectivity to $Endpoint"
            if($_.ErrorDetails.Message) {
                $portTest = $_.ErrorDetails.Message
                $portTest = "Error"
            } else {
                $portTest = $_
                $portTest = "Error"
            }
        }
    }
    if ($dnsResult -like 'Error'){$portTest = "Test Skipped"}
    if ($dnsResult -like 'Successful') {
        $ipAddresses = (Resolve-DnsName $Endpoint -DnsOnly  -ErrorAction SilentlyContinue).Ipaddress
        if ($ipAddresses -is [array]){
            $portTest = @()
            ForEach ($ipAddress in $ipAddresses){
                $endpointIp = $ipAddress
                Write-host "Checking connectivity to $endpointIp on port 443"
                Try {
                    $portTestAttempt = Test-Port -ComputerName $endpointIp -Port 443 -Timeout 300
                    if ($portTestAttempt.PortOpened -like "True"){
                        $portTestAttempt = "Successful"
                        Write-Host "Success!" -ForegroundColor Green
                        $portTest += $portTestAttempt
                    }
                    else {
                    Write-Host "There was an issue verifying connectivity to $endpointIp"
                    $portTestAttempt = "Error"
                    $portTest += $portTestAttempt
                    }
                }
                Catch {
                    Write-Host "There was an issue verifying connectivity to $endpointIp"
                    if($_.ErrorDetails.Message) {
                        $portTestAttempt = $_.ErrorDetails.Message
                        $portTestAttempt = "Error"
                        $portTest += $portTestAttempt
                    } else {
                        $portTestAttempt = $_
                        $portTestAttempt = "Error"
                        $portTest += $portTestAttempt
                    }
                }
            }
        }
        elseif ($ipAddresses){
            Write-host "Checking connectivity to $endpointIp on port 443"
            Try {
                $portTest = Test-Port -ComputerName $endpointIp -Port 443 -Timeout 300
                if ($portTest.PortOpened -like "True"){
                    $portTest = "Successful"
                    Write-Host "Success!" -ForegroundColor Green
                }
                else {
                Write-Host "There was an issue verifying connectivity to $Endpoint"
                $portTest = "Error" 
                }
            }
            Catch {
                Write-Host "There was an issue verifying connectivity to $Endpoint"
                if($_.ErrorDetails.Message) {
                    $portTest = $_.ErrorDetails.Message
                    $portTest = "Error"
                } else {
                    $portTest = $_
                    $portTest = "Error"
                }
            }
        }        
    }
    $endpointResults = [PSCustomObject]@{
        'Endpoint Address' = $Endpoint
        'DNS Records' = $dnsTest
        'DNS Result' = $dnsResult
        'Port 443' = $portTest
    }


  
    Start-Sleep -Seconds 1
    return $endpointResults
}

$testSet = @('EWF On-Premises', 'JX/XP On-Premises', 'JXAPP', 'XWF', 'XPH2019.0', 'XPH2021.1')
#$location = Get-FormArrayItem -items $locations -key "displayName" -dialogTitle "Choose location" -defaultValue "Canada Central"
$testItem = Get-FormArrayItem -items $testSet -dialogTitle "Choose the endpoint you would like to test" -defaultValue "EWF On-Premises" 

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = "Continue"

switch ($testItem) {
    "EWF On-Premises" {
        $endpoint = Get-FormStringInput -dialogTitle "Enter the EWF Farm URL" -defaultValue "EWF.CityState.Name.jha-sys.com"
        $testResults = Test-Endpoint -Endpoint $endpoint
        break
    }
    "JX/XP On-Premises"   {
        $endpoint = Get-FormStringInput -dialogTitle "Enter the JX Farm URL" -defaultValue "jXchange.CityState.Name.jha-sys.com"
        $testResults = Test-Endpoint -Endpoint $endpoint
        break
    }
    "JXAPP" {
        Write-Host "Testing connection to JXAPP by URL and IP Address" -ForegroundColor Yellow
        $endpoints = @("jxapp.jhahosted.com","10.23.24.145")
        $testResults = @()
        foreach ($endpoint in $endpoints){
            $obj = Test-Endpoint -Endpoint $endpoint
            $testResults += $obj
            $obj = $null
        }
        break
    }
    "XWF"  {
        Write-Host "Testing connection to XWF by URL and IP Address" -ForegroundColor Yellow
        $endpoints = @("ewfhstxp.jhahosted.com","10.49.128.22")
        $testResults = @()
        foreach ($endpoint in $endpoints){
            $obj = Test-Endpoint -Endpoint $endpoint
            $testResults += $obj
            $obj = $null
        }
        break
    }
    "XPH2019.0" {
        Write-Host "Testing connection to XPH 2019.0 by both URL and IP Address" -ForegroundColor Yellow
        $endpoints = @("hstxphprod.jhahosted.com","10.23.24.193","10.23.24.194") 
        $testResults = @()
        foreach ($endpoint in $endpoints){
            $obj = Test-Endpoint -Endpoint $endpoint
            $testResults += $obj
            $obj = $null
        }
        break
    }
    "XPH2021.1" {
        Write-Host "Testing connection to XPH 2021.1 by both URL and IP Address" -ForegroundColor Yellow
        $endpoints = @("xph.jhahosted.com","10.23.24.195","jx.xph.jhahosted.com", "10.23.24.196", "adfs.xph.jhahosted.com","10.23.24.197")
        $testResults = @()
        foreach ($endpoint in $endpoints){
            $obj = Test-Endpoint -Endpoint $endpoint
            $testResults += $obj
            $obj = $null
        }
        break
    }
}
Write-Host "`nChecking if .NET 4.8 is installed"
Try {
    $dotNetInstalled = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 528040
    Write-Host "Check Complete!" -ForegroundColor Green
    Write-Host ".NET Framework 4.8 Installed - $dotNetInstalled" -ForegroundColor Yellow
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
    $xcaInstalled = $installedList | Where-Object {$_ -like "*xperience*"}
    if (!$xcaInstalled){$xcaInstalled = "Not Installed"}
    Write-Host "Check Complete!" -ForegroundColor Green
}
Catch{
    $xcaInstalled = "XCA Version Unavailable"
    Write-Host "There was an issue verifying this application"
    Start-Sleep -Seconds 1
}
Write-Host "XCA Version - $xcaInstalled" -ForegroundColor Yellow
Start-Sleep -Seconds 1

Write-Host "`nConnectivity Test Results" -ForegroundColor Yellow
return $testResults

# SIG # Begin signature block
# MIIvbQYJKoZIhvcNAQcCoIIvXjCCL1oCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAAcJdwxmuK0Ge3
# uCoF30dBNA7ple6BWVMbL9Ayas7tTqCCFFMwggWQMIIDeKADAgECAhAFmxtXno4h
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
# cDCCGmwCAQEwfTBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIElu
# Yy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgQ29kZSBTaWduaW5nIFJT
# QTQwOTYgU0hBMzg0IDIwMjEgQ0ExAhAEnhjl/1RuI+msAJeJQ0XLMA0GCWCGSAFl
# AwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkD
# MQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJ
# KoZIhvcNAQkEMSIEIDRGvc+L4w909o86CeR3qRXlw/um78yqtQbPUZQ48cxpMA0G
# CSqGSIb3DQEBAQUABIICAHM9IbYHsbnGgUreyplIrt6ovVv8TKQw5aU7ujdaCLFk
# UBFFTFOtIZfWr/rRoE6U0JjvnFhAQdn2FMc9lkzKDQk5FIiXxkDQWRklZ9+Ie59x
# 5LAuNZtPzYf5lchmYXL/g7QKJvUPuUqa27RUX3guzpuR+ezDIQA6zP4yA/J8U4ee
# xfbpmpvoiqzp4g8d/dLlN03B+j65llzUj2uOAgFTRKV9U1p6eaUSgUCv1Wf+HKqt
# gvtoYAysoLYaeRoDJGqV165g4sKw7M8U8gEpdbsHsqGQJe0NeZfk1AMVmRnibtcj
# nr1eS24TsruT4XL4tfSO4IkeJcumsBVa0UWwm9k4qfFZWU7jn3H/g6ZQnD9E3sMq
# ryE+PB5A28OnxIwm5JcWlXAY0FrX1Dud9jOSRTkz58NnLisiFZp0YPafdA/a0pCv
# 7syf8ZnNAOy7BcDfa8f9bXt8/dyw1TFuBPROhps/5SIOqCxVZYxHi9DIWpi8wm73
# W7ca+rMg7GPpUz/GmLvn/9spWkQ17hklmMX4EAX3tLKtgC5b96Da91gSbpbGmBRn
# STeKwQF7Za8EHaqHfGRpIA05y6k4BmJRvlVPKooCxBAKeTKSdl8Zc4s91dECEjG2
# XMuB75bn0ixM4fSst9iKhnDRFusZ1gdK5kVJ6vI/7dhWlvQPdHwwEbV4bNrFr53i
# oYIXPTCCFzkGCisGAQQBgjcDAwExghcpMIIXJQYJKoZIhvcNAQcCoIIXFjCCFxIC
# AQMxDzANBglghkgBZQMEAgEFADB3BgsqhkiG9w0BCRABBKBoBGYwZAIBAQYJYIZI
# AYb9bAcBMDEwDQYJYIZIAWUDBAIBBQAEIIzJmO9c4xzqBwE/I4SY/jSjWamY2j7Z
# 6B1D93iVUS3nAhAjSln6Ax6qYCL7RjxxgUlNGA8yMDIzMDQwMzIwMTAyNVqgghMH
# MIIGwDCCBKigAwIBAgIQDE1pckuU+jwqSj0pB4A9WjANBgkqhkiG9w0BAQsFADBj
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMT
# MkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5n
# IENBMB4XDTIyMDkyMTAwMDAwMFoXDTMzMTEyMTIzNTk1OVowRjELMAkGA1UEBhMC
# VVMxETAPBgNVBAoTCERpZ2lDZXJ0MSQwIgYDVQQDExtEaWdpQ2VydCBUaW1lc3Rh
# bXAgMjAyMiAtIDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDP7KUm
# Osap8mu7jcENmtuh6BSFdDMaJqzQHFUeHjZtvJJVDGH0nQl3PRWWCC9rZKT9BoMW
# 15GSOBwxApb7crGXOlWvM+xhiummKNuQY1y9iVPgOi2Mh0KuJqTku3h4uXoW4VbG
# wLpkU7sqFudQSLuIaQyIxvG+4C99O7HKU41Agx7ny3JJKB5MgB6FVueF7fJhvKo6
# B332q27lZt3iXPUv7Y3UTZWEaOOAy2p50dIQkUYp6z4m8rSMzUy5Zsi7qlA4DeWM
# lF0ZWr/1e0BubxaompyVR4aFeT4MXmaMGgokvpyq0py2909ueMQoP6McD1AGN7oI
# 2TWmtR7aeFgdOej4TJEQln5N4d3CraV++C0bH+wrRhijGfY59/XBT3EuiQMRoku7
# mL/6T+R7Nu8GRORV/zbq5Xwx5/PCUsTmFntafqUlc9vAapkhLWPlWfVNL5AfJ7fS
# qxTlOGaHUQhr+1NDOdBk+lbP4PQK5hRtZHi7mP2Uw3Mh8y/CLiDXgazT8QfU4b3Z
# XUtuMZQpi+ZBpGWUwFjl5S4pkKa3YWT62SBsGFFguqaBDwklU/G/O+mrBw5qBzli
# GcnWhX8T2Y15z2LF7OF7ucxnEweawXjtxojIsG4yeccLWYONxu71LHx7jstkifGx
# xLjnU15fVdJ9GSlZA076XepFcxyEftfO4tQ6dwIDAQABo4IBizCCAYcwDgYDVR0P
# AQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgw
# IAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW
# 2W1NhS9zKXaaL3WMaiCPnshvMB0GA1UdDgQWBBRiit7QYfyPMRTtlwvNPSqUFN9S
# nDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGln
# aUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQ
# BggrBgEFBQcBAQSBgzCBgDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNl
# cnQuY29tMFgGCCsGAQUFBzAChkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0
# MA0GCSqGSIb3DQEBCwUAA4ICAQBVqioa80bzeFc3MPx140/WhSPx/PmVOZsl5vdy
# ipjDd9Rk/BX7NsJJUSx4iGNVCUY5APxp1MqbKfujP8DJAJsTHbCYidx48s18hc1T
# na9i4mFmoxQqRYdKmEIrUPwbtZ4IMAn65C3XCYl5+QnmiM59G7hqopvBU2AJ6KO4
# ndetHxy47JhB8PYOgPvk/9+dEKfrALpfSo8aOlK06r8JSRU1NlmaD1TSsht/fl4J
# rXZUinRtytIFZyt26/+YsiaVOBmIRBTlClmia+ciPkQh0j8cwJvtfEiy2JIMkU88
# ZpSvXQJT657inuTTH4YBZJwAwuladHUNPeF5iL8cAZfJGSOA1zZaX5YWsWMMxkZA
# O85dNdRZPkOaGK7DycvD+5sTX2q1x+DzBcNZ3ydiK95ByVO5/zQQZ/YmMph7/lxC
# lIGUgp2sCovGSxVK05iQRWAzgOAj3vgDpPZFR+XOuANCR+hBNnF3rf2i6Jd0Ti7a
# Hh2MWsgemtXC8MYiqE+bvdgcmlHEL5r2X6cnl7qWLoVXwGDneFZ/au/ClZpLEQLI
# gpzJGgV8unG1TnqZbPTontRamMifv427GFxD9dAq6OJi7ngE273R+1sKqHB+8JeE
# eOMIA11HLGOoJTiXAdI/Otrl5fbmm9x+LMz/F0xNAKLY1gEOuIvu5uByVYksJxlh
# 9ncBjDCCBq4wggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQEL
# BQAwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBS
# b290IEc0MB4XDTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UE
# BhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2Vy
# dCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTep
# l1Gh1tKD0Z5Mom2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt
# +FeoAn39Q7SE2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r
# 07G1decfBmWNlCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dh
# gxndX7RUCyFobjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfA
# csW6Th+xtVhNef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpH
# IEPjQ2OAe3VuJyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJS
# lRErWHRAKKtzQ87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0
# z9JMq++bPf4OuGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y
# 99xh3pP+OcD5sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBID
# fV8ju2TjY+Cm4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXT
# drnSDmuZDNIztM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0G
# A1UdDgQWBBS6FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFd
# ZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUH
# AwgwdwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0
# dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3Js
# MCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsF
# AAOCAgEAfVmOwJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoN
# qilp/GnBzx0H6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8V
# c40BIiXOlWk/R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJods
# kr2dfNBwCnzvqLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6sk
# HibBt94q6/aesXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82H
# hyS7T6NJuXdmkfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HN
# T7ZAmyEhQNC3EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8z
# OYdBeHo46Zzh3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIX
# mVnKcPA3v5gA3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZ
# E/6/pNHzV9m8BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSF
# D/yYlvZVVCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggWNMIIEdaAD
# AgECAhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYT
# AlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2Vy
# dC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0y
# MjA4MDEwMDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAf
# BgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4Smn
# PVirdprNrnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6f
# qVcWWVVyr2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O
# 7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZ
# Vu7Ke13jrclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4F
# fYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLm
# qaBn3aQnvKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMre
# Sx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/ch
# srIRt7t/8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+U
# DCEdslQpJYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xM
# dT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUb
# AgMBAAGjggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFd
# ZEzfLmc/57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAO
# BgNVHQ8BAf8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRw
# Oi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRz
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0f
# BD4wPDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNz
# dXJlZElEUm9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEM
# BQADggEBAHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLt
# pIh3bb0aFPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouy
# XtTP0UNEm0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jS
# TEAZNUZqaVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAc
# AgPLILCsWKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2
# h5b9W9FcrBjDTZ9ztwGpn1eqXijiuZQxggN2MIIDcgIBATB3MGMxCzAJBgNVBAYT
# AlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQg
# VHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAxNaXJL
# lPo8Kko9KQeAPVowDQYJYIZIAWUDBAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0GCyqG
# SIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMzA0MDMyMDEwMjVaMCsGCyqGSIb3
# DQEJEAIMMRwwGjAYMBYEFPOHIk2GM4KSNamUvL2Plun+HHxzMC8GCSqGSIb3DQEJ
# BDEiBCARENUWhTRxlQRt8vi7TcNKWIqUU7AE0iTGCMnFIKrNnDA3BgsqhkiG9w0B
# CRACLzEoMCYwJDAiBCDH9OG+MiiJIKviJjq+GsT8T+Z4HC1k0EyAdVegI7W2+jAN
# BgkqhkiG9w0BAQEFAASCAgADU/Z4BfDr71YLd4NNjlq+moNfe0H+D2my+twTrksj
# 5WalsXRH3hIBdwaXIHaCQHR6i/+oDhSuJDCfoWko19PN6iB1hbGEcKUHF7VXrIn7
# jUbpB61NNef9q2HlLG1pwUBgdbikuoM9Qy6K11BAIPsL9eJVD/TYMvIdbva2Ekw8
# q98enHDrK9ScyTtH2YMLLCeLP1Fn+czUzZXoWxmu/2uTobYgp8qemotpLVUx85Nj
# sD+NiukAK9XzGzXqFmhmr5GJXlpW+V3kd73kCfoR0FJbjTGYp7uwqdEBTV64DU3k
# DeezZrNgpQiMvfRv/onSvnJHwvxa2Ul2XiazTpTLJRpFkA5NQaGveJ+V1Elk3RAH
# AWjY13AaeoEyZhfmwWkOIUqp3kmcHEwDIITOmRnc6XWhOAE3Klv6YzNHYP7h5rDE
# XWImgDKvsy6bHlihehWCujKPKxfiLv4R/jLGDtN9ihos+uRb4uf6a2OWhQ8yl1CI
# BYfP0hrRUaMeSIeOwKy5ZhCPFra9Yfy5nht7zsbuq/GHeaGp/iTiIJclHZsPXTBU
# HsJmZ3UC3yxQTx6Pbd7fgamxywzVJ5XO/uPEDYxXEgF0qWdxFCUgtCLAsMMI9Nl5
# /PHEmF2QukitSqYGCF90AzlZ2S+nMDJt0Ra3RvKnlGTf5sgbbo/RP35sxuXtmyHg
# mg==
# SIG # End signature block
