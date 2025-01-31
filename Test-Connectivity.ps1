# Function to check if port 443 is already in use
function Test-Port443 {
    Import-Module WebAdministration -ErrorAction SilentlyContinue
    if (!(Get-Command Get-WebBinding -ErrorAction SilentlyContinue)) {
        Write-Host "IIS is not installed or the WebAdministration module is missing." -ForegroundColor Yellow
        return $used -ne $null
    }
    else {
        return $used -eq $null
    }
}

# Function to get the CN of the SSL certificate bound to port 443
function Get-SSL-CN {
    try {
        $siteThumb = (Get-ChildItem IIS:SSLBindings -ErrorAction SilentlyContinue | Where-Object {$_.port -eq 443}  -ErrorAction SilentlyContinue ).thumbprint
        $cert = (Get-ChildItem -path Cert:\* -Recurse   -ErrorAction SilentlyContinue  | where {$_.thumbprint –like $siteThumb}  -ErrorAction SilentlyContinue ).Subject
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

# Get local IP addresses (IPv4 only)
$localIPs = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
    Where-Object { $_.OperationalStatus -eq "Up" -and $_.NetworkInterfaceType -like "Ethernet" } |
    ForEach-Object { $_.GetIPProperties().UnicastAddresses } |
    Where-Object { $_.Address.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork } |
    Select-Object -ExpandProperty Address | Select-Object -ExpandProperty ipaddresstostring

# Check if something is already bound to port 443
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
    # Start TCP listener on port 443, allowing us to test without having IIS running
    Write-Host "Setting up temporary listener"
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, 443)
    $listener.Start()

    Write-Host "Listening on port 443..."
    Write-Host "`nRun the following command from another machine to test connectivity:`n"
    foreach ($ip in $localIPs) {
        Write-Host "Test-NetConnection $ip -Port 443" -ForegroundColor Green
    }

    Write-Host "`nPress Enter to stop the listener..."
    $null = Read-Host
    $listener.Stop()
    Write-Host "Listener stopped."
}
