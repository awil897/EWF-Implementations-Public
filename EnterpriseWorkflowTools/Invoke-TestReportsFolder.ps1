Function Invoke-TestReportsFolder {
    $FolderName = "C:\inetpub\wwwroot\Reports"
    if (!(Test-Path $FolderName)){
        #PowerShell Create directory if not exists
        New-Item $FolderName -ItemType Directory | out-null
    }
}