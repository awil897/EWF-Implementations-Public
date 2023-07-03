import-module dbatools
Import-Module carbon
. 'e:\EWF-Implementations-Public\StandaloneTools\MoveDatabases\Move-Databases.ps1'
Add-Type -AssemblyName System.Windows.Forms
$btn_Click = {
	Move-DatabaseFiles -SqlInstance $txtSqlInstance.Text -DataFolder $txtDataFolder.Text -LogsFolder $txtLogsFolder.Text -MoveTempDb:$chkMoveTempDb.Checked -TempDbFolder $txtTempDbFolder.Text 
}
. 'e:\EWF-Implementations-Public\StandaloneTools\MoveDatabases\Move-Databases.form.designer.ps1'
$Form1.ShowDialog()
