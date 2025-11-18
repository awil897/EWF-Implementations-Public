<#
.SYNOPSIS
    Gathers system hardware specs and local IP addresses for a new EWF install.
    It then checks if port 443 is in use by IIS.
    - If 443 is in use, it attempts to read the IIS SSL Certificate CN
      and provides 'Test-NetConnection' commands.
    - If 443 is NOT in use, it starts a temporary listener on 443
      that serves a JSON report of the system specs, holding the port
      open until the user presses Enter.
.DESCRIPTION
    This script is designed to be run on an FI's server to:
    1. Collect essential hardware and network information.
    2. Provide a simple way to test network connectivity to port 443
       from another machine, which helps diagnose firewall issues.
.NOTES
    Requires PowerShell to be run as Administrator for two reasons:
    1. To reliably query IIS settings (Get-WebBinding).
    2. To bind to port 443 for the temporary listener.
#>
#Elevating Powershell if needed
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$testadmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if ($testadmin -eq $false) {
Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
exit $LASTEXITCODE
}

function Get-EWFUsers {
    $search = [adsisearcher]"(&(ObjectCategory=person)(ObjectClass=user)(samaccountname=*ewf*))"
    $users = $search.FindAll()
    $userArray = @()
    foreach($user in $users) {
        $SamAccountName = $user.Properties['SamAccountName']
        $userArray += $SamAccountName
        $SamAccountName = $null
    }
    $userString = $userArray # -join ", "
    return $userString
}
function Get-EWFGroups {
    $search = [adsisearcher]"(&(objectCategory=group)(|(samaccountname=*ewf*)(samaccountname=JhaSMCUsers)(samaccountname=JXSystemAdministrators)))"
    
    $groups = $search.FindAll()
    $groupsArray = @()
    
    foreach($group in $groups) {
        $SamAccountName = $group.Properties['SamAccountName'][0]
        if ($SamAccountName) {
            $groupsArray += $SamAccountName
        }
    }
    $groupsString = $groupsArray #-join ", "
    
    return $groupsString
}
function Get-SystemSpecs {  
    try {
        [void]($cpus = Get-CimInstance -ClassName Win32_Processor)

        $totalCores = ($cpus | Measure-Object -Property NumberOfCores -Sum).Sum
        $totalThreads = ($cpus | Measure-Object -Property NumberOfLogicalProcessors -Sum).Sum
        $cpuName = ($cpus | Select-Object -First 1).Name.Trim()

        $cpuInfo = @{
            Type       = $cpuName
            Cores      = $totalCores
            Logical    = $totalThreads
        }

        [void]($computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem)
        $ramGB = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
        
        [void]($disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3")
        $diskList = foreach ($disk in $disks) {
            $sizeGB = [math]::Round($disk.Size / 1GB, 2)
            "$($disk.DeviceID) $sizeGB GB"
        }
        $diskInfo = $diskList

        $ipAddressObjects = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
            Where-Object { $_.OperationalStatus -eq "Up" -and $_.NetworkInterfaceType -like "Ethernet" } |
            ForEach-Object { $_.GetIPProperties().UnicastAddresses } |
            Where-Object { $_.Address.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork } |
            Select-Object -ExpandProperty Address
        
        $localIPs = @(
            $ipAddressObjects | ForEach-Object { $_.IPAddressToString } | Where-Object { -not [System.String]::IsNullOrWhiteSpace($_) }
        )

        $specs = [PSCustomObject]@{
            Local_IP_List = $localIPs -join ", "
            Server_Hostname = $env:COMPUTERNAME
            CPU_Type    = $cpuInfo.Type
            CPU_Cores   = $cpuInfo.Cores
            CPU_Threads = $cpuInfo.Logical
            RAM         = "$ramGB GB"
            Storage     = $diskInfo
            Local_IPs_Array = $localIPs
        }
        
        return $specs
    }
    catch {
        Write-Host "ERROR: Failed to gather system specs. $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "-------------------------------" -ForegroundColor Cyan
        Write-Host
        return $null 
    }
}
function Test-Port443 {
    Import-Module WebAdministration -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    if (!(Get-Command Get-WebBinding -ErrorAction SilentlyContinue)) {
        Write-Host "IIS is not installed or the WebAdministration module is missing." -ForegroundColor Yellow
        return $false
    }
    else {
        $binding = Get-ChildItem IIS:SSLBindings -ErrorAction SilentlyContinue | Where-Object {$_.port -eq 443} -ErrorAction SilentlyContinue
        return $binding -ne $null
    }
}
function Get-SSL-CN {
    try {
        $siteThumb = (Get-ChildItem IIS:SSLBindings -ErrorAction SilentlyContinue | Where-Object {$_.port -eq 443}  -ErrorAction SilentlyContinue ).thumbprint
        $cert = (Get-ChildItem -path Cert:\* -Recurse     -ErrorAction SilentlyContinue  | where {$_.thumbprint –like $siteThumb}  -ErrorAction SilentlyContinue ).Subject
        $cn = (($cert -replace "CN=","") -split ",")[0]
        if($cn){
            return $cn
        }
        else {
            throw
        }
    }
    catch {
        return $null
    }
}
function Test-CurrentUserIsAdmin {
    param()
    Write-Host "Checking current user's administrative privileges..." -ForegroundColor Gray
    
    try {
        $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [System.Security.Principal.WindowsPrincipal]$identity
        
        $isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
        
        if ($isAdmin) {
            Write-Host "Success: The current user is an Administrator." -ForegroundColor Green
            return $true
        } else {
            Write-Host "FAILURE: The current user is NOT an Administrator." -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERROR: Could not determine admin status. $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}
function Get-LocalAdmins {
    $adminGroup = [ADSI]"WinNT://./Administrators,group"
    
    $admins = $adminGroup.Members() | ForEach-Object {
        $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
    }
    return $admins
}

Write-Host "Checking if current user is an Administrator"
Try {
    $isAdmin = Test-CurrentUserIsAdmin
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
}
Catch{
    $isAdmin = $false
    $currentUser = "Error: $($_.Exception.Message)"
    Start-Sleep -Seconds 1
}
Write-Host "Gathering members of local Adminstrators group"
Try {
    $admins = Get-LocalAdmins
}
Catch{
    $adminsErrors = "$($_.Exception.Message)"
    $admins = @($adminsErrors)
    Start-Sleep -Seconds 1
}
Write-Host "Getting a list of possible EWF AD Groups"
Try {
    $groupsFound = Get-EWFGroups
    Write-Host "Complete!" -ForegroundColor Green
    if ($groupsFound -like $null){
        Write-Host "No Groups Found"
        $groupsFound = "No Groups Found"
    }
}
Catch {
    $groupsFound = "Error"
    Write-Host "Error while looking up EWF Groups"
}
Write-Host "Getting a list of possible EWF AD Users"
Try {
    $usersFound = Get-EWFUsers
    Write-Host "Complete!" -ForegroundColor Green
    if ($usersFound -like $null){
        Write-Host "No Users Found"
        $usersFound = "No Users Found"
    }
}
Catch {
    $usersFound = "Error"
    Write-Host "Error while looking up EWF Users" 
}

Write-Host "Checking if Webex Access is installed"
Try {
    $HNA = (Get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\WebEx\Config\RA\General -Name "HNA" -ErrorAction SilentlyContinue).HNA 
    If ($HNA -like $null){
        $HNA = "Not Installed"
        Write-Host "Complete!" -ForegroundColor Green
    }
}
Catch {
    $HNA = "Error querying the Registry"
    Start-Sleep -Seconds 1
}
$testResults = New-Object -TypeName PSObject -Property ([ordered]@{
    'Is Current User Admin' = $isAdmin
    'Current User' = $currentUser
    'EWF Users Found' = $usersFound
    'EWF Groups Found' = $groupsFound
    'SmartTech Entry Name' = $HNA
})
Write-Host "Please copy the entire output below and provide to your assigned Engineer for review." -ForegroundColor Yellow
$systemSpecs = Get-SystemSpecs
Write-Host "-------- System Info --------" -ForegroundColor Cyan

$global:combinedReport = $null
if ($null -ne $systemSpecs) {
    $global:combinedReport = [PSCustomObject]@{
        'Is_Admin' = $testResults.'Is Current User Admin'
        'Current_User'          = $testResults.'Current User'
        'Admins' = $admins
        'EWF_Users'       = $testResults.'EWF Users Found'
        'EWF_Groups'      = $testResults.'EWF Groups Found'
        'SmartTech_Entry'  = $testResults.'SmartTech Entry Name'
        
        '...'                   = '...' 

        'Local_IP_List'   = $systemSpecs.Local_IP_List
        'Server_Hostname' = $systemSpecs.Server_Hostname
        'CPU_Type'        = $systemSpecs.CPU_Type
        'CPU_Cores'       = $systemSpecs.CPU_Cores
        'CPU_Threads'     = $systemSpecs.CPU_Threads
        'RAM'             = $systemSpecs.RAM
        'Storage'         = $systemSpecs.Storage
    }
    $global:combinedReportString = [PSCustomObject]@{
        'Is_Admin' = $testResults.'Is Current User Admin'
        'Current_User'          = $testResults.'Current User'
        'Admins' = $admins -join ", "
        'EWF_Users'       = $testResults.'EWF Users Found' -join ", "
        'EWF_Groups'      = $testResults.'EWF Groups Found' -join ", "
        'SmartTech_Entry'  = $testResults.'SmartTech Entry Name'
        
        '...'                   = '...' 

        'Local_IP_List'   = $systemSpecs.Local_IP_List
        'Server_Hostname' = $systemSpecs.Server_Hostname
        'CPU_Type'        = $systemSpecs.CPU_Type
        'CPU_Cores'       = $systemSpecs.CPU_Cores
        'RAM'             = $systemSpecs.RAM
        'Storage'         = $systemSpecs.Storage -join ", "
    }
    $combinedReportString | Format-List
}

Write-Host "-------------------------------" -ForegroundColor Cyan
Write-Host ""

if ($null -eq $systemSpecs) {
    Write-Host "Critical error: Could not get system specs (try running as Administrator?). Exiting." -ForegroundColor Red
    return
}

$localIPs = $systemSpecs.Local_IPs_Array

if ([array]::IndexOf($localIPs, $null) -ne -1 -or $localIPs.Count -eq 0) {
    Write-Host "Critical error: No valid local IP addresses were found. Cannot start listener." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    return
}

if (Test-Port443) {
    Write-Host "Port 443 is already in use."
    Write-Host "Checking Certificate"
    $cn = Get-SSL-CN
    $hasCN = $false
    Write-Host "Run the following command to tests connectivity:`n"
    if($cn){ 
        Write-Host "`nResolve-DnsName $cn -NoHostsFile" -ForegroundColor Green
        foreach ($ip in $localIPs) {
        Write-Host "`nTest-NetConnection $ip -Port 443 " -ForegroundColor Green
    }
    }
    else {
        Write-Host "`nCould not retrieve SSL certificate CN. Using IP-based test" 
        foreach ($ip in $localIPs) {
            Write-Host "`nTest-NetConnection $ip -Port 443" -ForegroundColor Green
        }
    } 
} else {
    $tcpListener = Get-NetTCPConnection -LocalPort 443 -State Listen -ErrorAction SilentlyContinue
    if ($tcpListener -ne $null) {
        Write-Host "Port 443 is in use by another service (not IIS). Listener not required." -ForegroundColor Yellow
        Write-Host "`nTest by IP Address:" -ForegroundColor White
        foreach ($ip in $localIPs) {
            Write-Host "Test-NetConnection $ip -Port 443" -ForegroundColor Green
        }
        Write-Host
        Read-Host "Press Enter to exit"
        return
    }

    Write-Host "Setting up temporary HTTP listener..."
    $listener = New-Object System.Net.HttpListener
    try {
        foreach ($ip in $localIPs) {
            $prefix = "http://$($ip):443/"
            Write-Host "Registering prefix: $prefix" -ForegroundColor Gray
            $listener.Prefixes.Add($prefix)
        }
        
        $listener.Start()
    } catch {
        Write-Host "ERROR: Could not bind to port 443." -ForegroundColor Red
        Write-Host "This port may be reserved, or you may not be running as Administrator."
        Write-Host "Error details: $($_.Exception.Message)"
        Read-Host "Press Enter to exit"
        return
    }

    try {
        Write-Host "Listener active on port 443." -ForegroundColor Green
        Write-Host "`nRun the following command from another machine to test connectivity:" -ForegroundColor White
        foreach ($ip in $localIPs) {
            Write-Host "Invoke-RestMethod -Uri http://$($ip):443" -ForegroundColor Green
        }
        Write-Host "`nWaiting for connections..."
        
        while ($true) {
            try {
                $context = $listener.GetContext()
                $request = $context.Request
                $response = $context.Response

                Write-Host "`n[$(Get-Date)] Connection received from: $($request.RemoteEndPoint)" -ForegroundColor Cyan
                
                $jsonReport = $global:combinedReport | ConvertTo-Json -Depth 5
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($jsonReport)
                
                $response.ContentType = "application/json"
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
                $response.Close()
                
            } catch {
                Write-Host "`nError processing request: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "`nStopping listener due to Ctrl+C or error..." -ForegroundColor Yellow
    }
    finally {
        $listener.Stop()
        $listener.Close()
        Write-Host "Listener stopped." -ForegroundColor Yellow
    }
}
Read-Host "Press Enter to exit"
