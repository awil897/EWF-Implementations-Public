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
        $endpointIp = ($dnsTest | Select-Object -First 1)
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
