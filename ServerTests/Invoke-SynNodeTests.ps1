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

if (Get-Module -ListAvailable -Name Carbon) {
    Write-Host "Carbon Module already installed"
    Import-Module carbon
} 
else {
    try {
        Write-Host "Downloading Carbon PowerShell module"
        Invoke-Expression ('$module="carbon";$user="awil897";$branch="main";$repo="EWF-Implementations-Public"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/awil897/EWF-Implementations-Public/main/download-EWFModules.ps1'))
        Import-Module carbon
    }
    catch [Exception] {
        $_.message 
        exit
    }
}


$jxfarm = Read-host "JX Farm URL"



$Inputs = Get-FormItemProperties -item $Inputs -dialogTitle "Fill these required fields"

if ($jxfarm -like $null){
   Write-Host "Please restart this script and check that you are inputting a valid JX farm" -ForegroundColor Red
   return
}

Write-host "`nChecking DNS for $jxfarm"
Try {
    $dns = (Resolve-DnsName $jxfarm -DnsOnly -ErrorAction Stop).Ipaddress -join ', '
    if ($dns){
        $jxFarmTest = $dns
        Write-Host "Success!" -ForegroundColor Green
    }
    else {
    $ewfFarmTest = $dns
    Write-Host "There was an issue verifying DNS records for $jxfarm" 
    }
}
Catch {
    Write-Host "There was an issue verifying DNS records for $jxfarm"
    if($_.ErrorDetails.Message) {
        $jxFarmTest = $_.ErrorDetails.Message
    } else {
        $jxFarmTest = $_
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
Write-Host "Checking jhadownloads.JackHenry.com"
Try {
    $response = (Invoke-WebRequest "https://jhadownloads.jackhenry.com" -UseBasicParsing).StatusCode
    if ($response -like "200"){
        $jackhenryTest = "Successful"
        Write-Host "Success!" -ForegroundColor Green
    }
    else {
    $jackhenryTest = $response
    }
}
Catch {
    Write-Host "There was an issue verifying this URL"
    if($_.ErrorDetails.Message) {
        $jackhenryTest = $_.ErrorDetails.Message
    } else {
        $jackhenryTest = $_
    }
    Start-Sleep -Seconds 1
}
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
    'JX URL' = $jxFarm
    'EWF DNS Records' = $jxFarmTest
    'Server Hostname' = $env:COMPUTERNAME
    'SmartTech Entry Name' = $HNA
})

Write-Host "`nPlease screenshot or copy the results below and email to INeedASynergyEmail@jackhenry.com" -BackgroundColor Yellow -ForegroundColor Black
Write-Host "If you have multiple SynNode application servers, please repeat this process on those additional servers"

Start-Sleep -Seconds 2

#outputting the log to a csv file
$outputDir = "C:\SynergyTests"
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

Write-Host "Loading Test UI"
Invoke-Expression (Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/awil897/EWF-Implementations-Public/main/ServerTests/Get-SGProviderInformation.ps1')
https://raw.githubusercontent.com/awil897/EWF-Implementations-Public/main/ServerTests/Get-SGProviderInformation.ps1

return $testResults