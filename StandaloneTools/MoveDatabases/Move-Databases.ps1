function Move-DatabaseFiles{
param (
    # SQL Instance to use
    [Parameter(Mandatory=$true)]
    [string]$SqlInstance,

    # Folder to store MDF Files
    [Parameter(Mandatory=$false)]
    [string]$DataFolder,
    
    # Folder to store LDF Files
    [Parameter(Mandatory=$false)]
    [string]$LogsFolder,

    [Parameter(Mandatory=$false)]
    [Switch]$MoveTempDb,

    [Parameter(Mandatory=$false)]
    [string]$TempDbFolder
)

    import-module dbatools
    Import-Module carbon
    Set-DbatoolsConfig -Name Import.EncryptionMessageCheck -Value $false -PassThru | Register-DbatoolsConfig
    Set-DbatoolsConfig -FullName 'sql.connection.trustcert' -Value $true -Register

    if ($DataFolder){
        $path =  $dataFolder
        If(!(test-path -PathType container $path)){
                Write-Host "Folder does not exist"
                Write-Host "Creating $($path)"
                (New-Item -ItemType Directory -Path $path) | Out-Null
        }
    }

    if ($LogsFolder){
        $path =  $logsFolder
        If(!(test-path -PathType container $path)){
                Write-Host "Folder does not exist"
                Write-Host "Creating $($path)"
                (New-Item -ItemType Directory -Path $path) | Out-Null
        }
    } 
    if (!$logsfolder -and !$datafolder){
        Write-Host "Skipping User Databases since no folders were supplied"
    }
    if (($MoveTempDb -like $true) -and ($TempDbFolder)){
        $path =  $TempDbFolder
        If(!(test-path -PathType container $path)){
                Write-Host "Folder does not exist"
                Write-Host "Creating $($path)"
                (New-Item -ItemType Directory -Path $path) | Out-Null
        }
    }


    $servicePrincipal = (Get-DbaService -SqlInstance $SqlInstance | Where-Object {($_.servicetype -like "engine") -or ($_.servicetype -like "agent")}).startname
    $servicePrincipal | ForEach-Object {
        if ($_ -notlike "LocalSystem"){
        Write-host "Setting ACL for $($_)"
            if ($DataFolder){
                Grant-CPermission -Identity $_ -Permission FullControl -Path $dataFolder
            }
            if ($logsFolder){
                Grant-CPermission -Identity $_ -Permission FullControl -Path $logsfolder
            }
            if (($MoveTempDb -like $true) -and ($TempDbFolder)){
                Grant-CPermission -Identity $_ -Permission FullControl -Path $TempDbFolder
            }
            #$ACL = get-acl -Path $datafolder
            #$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($_,"FullControl","ContainerInherit,ObjectInherit","InheritOnly","Allow")
            #$ACL.SetAccessRule($AccessRule)
            #$ACL = get-acl -Path $logsfolder
            #$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($_,"FullControl","ContainerInherit,ObjectInherit","InheritOnly","Allow")
            #$ACL.SetAccessRule($AccessRule)
        }
    }

    if ($logsfolder -and $datafolder){
        try {
            $databases = (Get-DbaDatabase -SqlInstance $SqlInstance -ExcludeDatabase model,master,tempdb,msdb | Select-Object -Property Name,SizeMb,RecoveryModel | Out-GridView -OutputMode Multiple -Title "Select multiple databases to move by holding down CTRL") | Select-Object -ExpandProperty name
            if (!$databases){
                throw
            }

        }
        catch {
            Write-Error "No databases were found or selected, or there was an error communicating with $($SqlInstance)"
            break
        }

        finally {
            if ($databases -and $datafolder -and $LogsFolder){
                foreach ($database in $databases){
                    $hashTable = @{}
                    Get-DbaDbFile -SqlInstance $SqlInstance -Database $database | Select-Object LogicalName, PhysicalName | ForEach {$hashTable[$_.LogicalName] = $_.PhysicalName}
                    $hashTable.Clone().GetEnumerator() | foreach-object {
                        if ($_.key -like "*log*"){
                            $hashTable.Set_Item($_.key, $logsFolder)
                        }
                        else {
                            $hashTable.Set_Item($_.key, $datafolder)
                        
                        }
                    }
                    Move-DbaDbFile -SqlInstance $SqlInstance  -Database $database -FileToMove $hashtable
                    Write-Host "$($database) has been moved`r`n"
                }
            }
        }
    }
    if (($MoveTempDb -like $true) -and ($TempDbFolder)){
        Write-Host "Moving TempDb files"
        $maxFileCount = 16
        $maxFileInitialSizeMB = 1024
        $maxFileGrowthSizeMB = 2048
        $fileGrowthMB = 512
        $coreMultiplier = 1.0

        #get a collection of physical processors
        [array] $procs = Get-WmiObject Win32_Processor
        $totalProcs = $procs.Count
        $totalCores = 0

        #count the total number of cores across all processors
        foreach ($proc in $procs){
            $totalCores = $totalCores + $proc.NumberOfCores
        }

        #get the amount of total memory (MB)
        $wmi = Get-WmiObject Win32_OperatingSystem
        $totalMemory = ($wmi.TotalVisibleMemorySize / 1024)

        $fileCount = $totalCores * $coreMultiplier
        if ($fileCount -gt $maxFileCount){
            $fileCount = $maxFileCount
        }

        $fileSize = $totalMemory / $fileCount
        if ($fileSize -gt $maxFileInitialSizeMB){ 
            $fileSize = $maxFileInitialSizeMB 
        }

        $fileSize = $fileSize * $fileCount
        $logFileSize = $fileSize * 2
        
        Set-DbaTempDbConfig -SqlInstance $SqlInstance -DataFileSize $fileSize -DataFileCount $fileCount -DataFileGrowth $fileGrowthMB -DataPath $TempDbFolder -LogFileSize $logFileSize -LogFileGrowth $fileGrowthMB -LogPath $TempDbFolder
    }
    Write-Host "DB move is complete" -ForegroundColor Green
}
