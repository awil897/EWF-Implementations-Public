$Form1 = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Button]$btn = $null
[System.Windows.Forms.Label]$lblSqlInstance = $null
[System.Windows.Forms.TextBox]$txtSqlInstance = $null
[System.Windows.Forms.Label]$lblDataFolder = $null
[System.Windows.Forms.TextBox]$txtDataFolder = $null
[System.Windows.Forms.Label]$lblLogsFolder = $null
[System.Windows.Forms.TextBox]$txtLogsFolder = $null
[System.Windows.Forms.CheckBox]$chkMoveTempDb = $null
[System.Windows.Forms.Label]$lblTempDbFolder = $null
[System.Windows.Forms.TextBox]$txtTempDbFolder = $null
function InitializeComponent
{
$btn = (New-Object -TypeName System.Windows.Forms.Button)
$lblSqlInstance = (New-Object -TypeName System.Windows.Forms.Label)
$txtSqlInstance = (New-Object -TypeName System.Windows.Forms.TextBox)
$lblDataFolder = (New-Object -TypeName System.Windows.Forms.Label)
$txtDataFolder = (New-Object -TypeName System.Windows.Forms.TextBox)
$lblLogsFolder = (New-Object -TypeName System.Windows.Forms.Label)
$txtLogsFolder = (New-Object -TypeName System.Windows.Forms.TextBox)
$chkMoveTempDb = (New-Object -TypeName System.Windows.Forms.CheckBox)
$lblTempDbFolder = (New-Object -TypeName System.Windows.Forms.Label)
$txtTempDbFolder = (New-Object -TypeName System.Windows.Forms.TextBox)
$form1.SuspendLayout()
#
# lblSqlInstance
#
$lblSqlInstance.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]10))
$lblSqlInstance.Name = [System.String]'lblSqlInstance'
$lblSqlInstance.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$lblSqlInstance.TabIndex = 1
$lblSqlInstance.Text = 'SqlInstance'
$lblSqlInstance.UseCompatibleTextRendering = $true
#
# txtSqlInstance
#
$txtSqlInstance.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]120,[System.Int32]10))
$txtSqlInstance.Name = [System.String]'txtSqlInstance'
$txtSqlInstance.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]200,[System.Int32]23))
$txtSqlInstance.TabIndex = 2
#
# lblDataFolder
#
$lblDataFolder.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]40))
$lblDataFolder.Name = [System.String]'lblDataFolder'
$lblDataFolder.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$lblDataFolder.TabIndex = 3
$lblDataFolder.Text = 'DataFolder'
$lblDataFolder.UseCompatibleTextRendering = $true
#
# txtDataFolder
#
$txtDataFolder.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]120,[System.Int32]40))
$txtDataFolder.Name = [System.String]'txtDataFolder'
$txtDataFolder.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]200,[System.Int32]23))
$txtDataFolder.TabIndex = 4
#
# lblLogsFolder
#
$lblLogsFolder.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]70))
$lblLogsFolder.Name = [System.String]'lblLogsFolder'
$lblLogsFolder.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$lblLogsFolder.TabIndex = 5
$lblLogsFolder.Text = 'LogsFolder'
$lblLogsFolder.UseCompatibleTextRendering = $true
#
# txtLogsFolder
#
$txtLogsFolder.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]120,[System.Int32]70))
$txtLogsFolder.Name = [System.String]'txtLogsFolder'
$txtLogsFolder.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]200,[System.Int32]23))
$txtLogsFolder.TabIndex = 6
#
# chkMoveTempDb
#
$chkMoveTempDb.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]100))
$chkMoveTempDb.Name = [System.String]'chkMoveTempDb'
$chkMoveTempDb.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$chkMoveTempDb.TabIndex = 7
$chkMoveTempDb.Text = 'MoveTempDb'
$chkMoveTempDb.UseCompatibleTextRendering = $true
$chkMoveTempDb.UseVisualStyleBackColor = $true
#
# lblTempDbFolder
#
$lblTempDbFolder.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]130))
$lblTempDbFolder.Name = [System.String]'lblTempDbFolder'
$lblTempDbFolder.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$lblTempDbFolder.TabIndex = 8
$lblTempDbFolder.Text = 'TempDbFolder'
$lblTempDbFolder.UseCompatibleTextRendering = $true
#
# txtTempDbFolder
#
$txtTempDbFolder.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]120,[System.Int32]130))
$txtTempDbFolder.Name = [System.String]'txtTempDbFolder'
$txtTempDbFolder.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]200,[System.Int32]23))
$txtTempDbFolder.TabIndex = 9
#
# btn
#
$btn.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]220,[System.Int32]160))
$btn.Name = [System.String]'btn'
$btn.Padding = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]3))
$btn.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]23))
$btn.TabIndex = 10
$btn.Text = 'Submit'
$btn.UseVisualStyleBackColor = $true
$btn.add_Click($btn_Click)
$Form1.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]380,[System.Int32]250))
$Form1.Controls.Add($lblSqlInstance)
$Form1.Controls.Add($txtSqlInstance)
$Form1.Controls.Add($lblDataFolder)
$Form1.Controls.Add($txtDataFolder)
$Form1.Controls.Add($lblLogsFolder)
$Form1.Controls.Add($txtLogsFolder)
$Form1.Controls.Add($chkMoveTempDb)
$Form1.Controls.Add($lblTempDbFolder)
$Form1.Controls.Add($txtTempDbFolder)
$Form1.Controls.Add($btn)
$Form1.Text = [System.String]'Database Move Tool'
$Form1.ResumeLayout($true)
Add-Member -InputObject $Form1 -Name btn -Value $btn -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name lblSqlInstance -Value $lblSqlInstance -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name txtSqlInstance -Value $txtSqlInstance -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name lblDataFolder -Value $lblDataFolder -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name txtDataFolder -Value $txtDataFolder -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name lblLogsFolder -Value $lblLogsFolder -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name txtLogsFolder -Value $txtLogsFolder -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name chkMoveTempDb -Value $chkMoveTempDb -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name lblTempDbFolder -Value $lblTempDbFolder -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name txtTempDbFolder -Value $txtTempDbFolder -MemberType NoteProperty
}
. InitializeComponent
