$Form1 = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.TextBox]$endpointBox = $null
[System.Windows.Forms.Label]$endpointLabel = $null
[System.Windows.Forms.Label]$clientIdLabel = $null
[System.Windows.Forms.TextBox]$clientIdBox = $null
[System.Windows.Forms.Label]$emailLabel = $null
[System.Windows.Forms.TextBox]$emailBox = $null
[System.Windows.Forms.Button]$Button1 = $null
[System.Windows.Forms.RichTextBox]$RichText = $null
[System.Windows.Forms.Label]$SearchLabel = $null
[System.Windows.Forms.TextBox]$SearchBox = $null
[System.Windows.Forms.Button]$SearchButton = $null
[System.Windows.Forms.Button]$ListButton = $null
function InitializeComponent
{
$resources = . (Join-Path $PSScriptRoot 'adobesigntesttool.resources.ps1')
$endpointBox = (New-Object -TypeName System.Windows.Forms.TextBox)
$endpointLabel = (New-Object -TypeName System.Windows.Forms.Label)
$clientIdLabel = (New-Object -TypeName System.Windows.Forms.Label)
$clientIdBox = (New-Object -TypeName System.Windows.Forms.TextBox)
$emailLabel = (New-Object -TypeName System.Windows.Forms.Label)
$emailBox = (New-Object -TypeName System.Windows.Forms.TextBox)
$Button1 = (New-Object -TypeName System.Windows.Forms.Button)
$RichText = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$SearchLabel = (New-Object -TypeName System.Windows.Forms.Label)
$SearchBox = (New-Object -TypeName System.Windows.Forms.TextBox)
$SearchButton = (New-Object -TypeName System.Windows.Forms.Button)
$ListButton = (New-Object -TypeName System.Windows.Forms.Button)
$Form1.SuspendLayout()
#
#endpointBox
#
$endpointBox.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]29))
$endpointBox.Name = [System.String]'endpointBox'
$endpointBox.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]242,[System.Int32]21))
$endpointBox.TabIndex = [System.Int32]0
$endpointBox.Text = [System.String]'https://api.echosign.com/api/rest/v6'
#
#endpointLabel
#
$endpointLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]9))
$endpointLabel.Name = [System.String]'endpointLabel'
$endpointLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]203,[System.Int32]17))
$endpointLabel.TabIndex = [System.Int32]1
$endpointLabel.Text = [System.String]'Remote Signature Service URL'
#
#clientIdLabel
#
$clientIdLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]58))
$clientIdLabel.Name = [System.String]'clientIdLabel'
$clientIdLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]17))
$clientIdLabel.TabIndex = [System.Int32]2
$clientIdLabel.Text = [System.String]'Client ID'
#
#clientIdBox
#
$clientIdBox.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]78))
$clientIdBox.Name = [System.String]'clientIdBox'
$clientIdBox.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]242,[System.Int32]21))
$clientIdBox.TabIndex = [System.Int32]3
#
#emailLabel
#
$emailLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]111))
$emailLabel.Name = [System.String]'emailLabel'
$emailLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]17))
$emailLabel.TabIndex = [System.Int32]4
$emailLabel.Text = [System.String]'Email Address'
#
#emailBox
#
$emailBox.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]131))
$emailBox.Name = [System.String]'emailBox'
$emailBox.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]242,[System.Int32]21))
$emailBox.TabIndex = [System.Int32]5
#
#Button1
#
$Button1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]71,[System.Int32]172))
$Button1.Name = [System.String]'Button1'
$Button1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]105,[System.Int32]23))
$Button1.TabIndex = [System.Int32]6
$Button1.Text = [System.String]'Check User'
$Button1.UseVisualStyleBackColor = $true
$Button1.add_Click($checkUser)
#
#RichText
#
$RichText.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]293,[System.Int32]12))
$RichText.Name = [System.String]'RichText'
$RichText.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]389,[System.Int32]310))
$RichText.TabIndex = [System.Int32]7
$RichText.Text = [System.String]''
#
#SearchLabel
#
$SearchLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]209))
$SearchLabel.Name = [System.String]'SearchLabel'
$SearchLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]17))
$SearchLabel.TabIndex = [System.Int32]8
$SearchLabel.Text = [System.String]'Search String'
#
#SearchBox
#
$SearchBox.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]229))
$SearchBox.Name = [System.String]'SearchBox'
$SearchBox.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]242,[System.Int32]21))
$SearchBox.TabIndex = [System.Int32]9
#
#SearchButton
#
$SearchButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]270))
$SearchButton.Name = [System.String]'SearchButton'
$SearchButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$SearchButton.TabIndex = [System.Int32]10
$SearchButton.Text = [System.String]'Search Users'
$SearchButton.UseVisualStyleBackColor = $true
$SearchButton.add_Click($SearchUsers)
#
#ListButton
#
$ListButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]152,[System.Int32]270))
$ListButton.Name = [System.String]'ListButton'
$ListButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]102,[System.Int32]23))
$ListButton.TabIndex = [System.Int32]11
$ListButton.Text = [System.String]'List Users'
$ListButton.UseVisualStyleBackColor = $true
$ListButton.add_Click($ListUsers)
#
#Form1
#
$Form1.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]694,[System.Int32]334))
$Form1.Controls.Add($ListButton)
$Form1.Controls.Add($SearchButton)
$Form1.Controls.Add($SearchBox)
$Form1.Controls.Add($SearchLabel)
$Form1.Controls.Add($RichText)
$Form1.Controls.Add($Button1)
$Form1.Controls.Add($emailBox)
$Form1.Controls.Add($emailLabel)
$Form1.Controls.Add($clientIdBox)
$Form1.Controls.Add($clientIdLabel)
$Form1.Controls.Add($endpointLabel)
$Form1.Controls.Add($endpointBox)
$Form1.Icon = ([System.Drawing.Icon]$resources.'$this.Icon')
$Form1.Text = [System.String]' Adobe Sign Test Tool'
$Form1.ResumeLayout($false)
$Form1.PerformLayout()
Add-Member -InputObject $Form1 -Name endpointBox -Value $endpointBox -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name endpointLabel -Value $endpointLabel -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name clientIdLabel -Value $clientIdLabel -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name clientIdBox -Value $clientIdBox -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name emailLabel -Value $emailLabel -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name emailBox -Value $emailBox -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button1 -Value $Button1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name RichText -Value $RichText -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name SearchLabel -Value $SearchLabel -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name SearchBox -Value $SearchBox -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name SearchButton -Value $SearchButton -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name ListButton -Value $ListButton -MemberType NoteProperty
}
. InitializeComponent
