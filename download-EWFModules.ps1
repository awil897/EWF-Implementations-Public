# capture variable values
[string]$Url = Get-Variable -ValueOnly -ErrorAction SilentlyContinue Url;
[string]$User = Get-Variable -ValueOnly -ErrorAction SilentlyContinue User;
[string]$Repo = Get-Variable -ValueOnly -ErrorAction SilentlyContinue Repo;
[string]$Branch = Get-Variable -ValueOnly -ErrorAction SilentlyContinue Branch;
[string]$ModulePath = Get-Variable -ValueOnly -ErrorAction SilentlyContinue Module;

#set default values for Branch and ModulePath variables

If ( [string]::IsNullOrWhitespace($Branch) ) { $Branch = "master" }
If ( [string]::IsNullOrWhitespace($ModulePath) ) { $ModulePath = "" }

function Read-ParamMode {
    $c_url = New-Object System.Management.Automation.Host.ChoiceDescription '&Url', 'Define module repo path via repo URl'
    #$c_file_url = New-Object System.Management.Automation.Host.ChoiceDescription '&Url', 'Define powershell script file path via URl'
    $c_param = New-Object System.Management.Automation.Host.ChoiceDescription '&Params', 'Define module repo path one by one (user/repo/path)'
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($c_url, $c_param)

    $message = 'Select Module repo enter mode'
    return $host.ui.PromptForChoice($null, $message, $options, 1)
}
function Read-RepoInfo {
    param (
        [string]$User,
        [string]$Repo,
        [string]$ModulePath,
        [string]$Branch
    )
    $p_user = New-Object System.Management.Automation.Host.FieldDescription 'User ['+$User+']'
    $p_user.Label="Github repo user name"
    $p_user.IsMandatory=$true
    $p_user.SetParameterType([string])
    $p_user.DefaultValue = $User
    
    $p_repo = New-Object System.Management.Automation.Host.FieldDescription 'Repository ['+$Repo+']'
    $p_repo.HelpMessage="Github Repository"
    $p_repo.SetParameterType([string])
    $p_user.DefaultValue = $Repo

    $p_path = New-Object System.Management.Automation.Host.FieldDescription 'RepoFolder (empty for root) [' +$ModulePath +']'
    $p_path.Label="Repository Folder [Live empty for root repo folder]"
    $p_path.HelpMessage="Repository Folder [Live empty for root repo folder]"
    $p_path.SetParameterType([string])
    $p_path.DefaultValue = $ModulePath

    $p_branch = New-Object System.Management.Automation.Host.FieldDescription 'Branch ['+$Branch+']'
    $p_branch.HelpMessage="Repository branch [Default:master]"
    $p_branch.SetParameterType([string])
    $p_branch.DefaultValue = $Branch


    $res = $host.ui.Prompt($null,"Github Module Repository",@($p_user, $p_repo, $p_path, $p_branch))

    If ( ! [string]::IsNullOrWhitespace($res[$p_user.Name]) ) { $res[$p_user.Name] } Else {$res[$p_user.Name]=$p_user.DefaultValue} 
    If ( ! [string]::IsNullOrWhitespace($res[$p_repo.Name]) ) { $res[$p_repo.Name] } Else {$res[$p_repo.Name]=$p_repo.DefaultValue} 
    If ( ! [string]::IsNullOrWhitespace($res[$p_path.Name]) ) { $res[$p_path.Name] } Else {$res[$p_path.Name]=$p_path.DefaultValue} 
    If ( ! [string]::IsNullOrWhitespace($res[$p_branch.Name]) ) { $res[$p_branch.Name] } Else {$res[$p_branch.Name]=$p_branch.DefaultValue} 

    return @{
        User = $res[$p_user.Name]
        Repo = $res[$p_repo.Name]
        Branch = $res[$p_branch.Name]
        ModulePath = $res[$p_path.Name]
    }
}
function Get-LocalTempPath {
    param (
        [string] $RepoName
    )
    $tmpDir = [System.IO.Path]::GetTempPath();
    return "$tmpDir$RepoName";
}
function Receive-Module {
    param (
        [string] $File,
        [string] $Url
    )
    $client = New-Object System.Net.WebClient;
    
    try {

        $progressEventArgs = @{
            InputObject = $client
            EventName = 'DownloadProgressChanged'
            SourceIdentifier = 'ModuleDownload'
            Action = {
                
                Write-Progress -Activity "Module Installation" -Status `
                ("Downloading Module: {0} of {1}" -f $eventargs.BytesReceived, $eventargs.TotalBytesToReceive) `
                -PercentComplete $eventargs.ProgressPercentage 
            }
        };

        $completeEventArgs = @{
            InputObject = $client
            EventName = 'DownloadFileCompleted'
            SourceIdentifier = 'ModuleDownloadCompleted'
        };

        Register-ObjectEvent @progressEventArgs;
        Register-ObjectEvent @completeEventArgs;
    
        $client.DownloadFileAsync($Url, $File);

        Wait-Event -SourceIdentifier ModuleDownloadCompleted;
    }
    catch [System.Net.WebException]  
    {  
        Write-Host("Cannot download $Url");
    } 
    finally {
        $client.dispose();
        Unregister-Event -SourceIdentifier ModuleDownload;
        Unregister-Event -SourceIdentifier ModuleDownloadCompleted;
    }
    Write-Debug "Unblock downloaded file access $File";
    Unblock-File -Path $File;
}
function Expand-ModuleZip {
    param (
        [string] $Archive
    )

    #avoid errors on already existing file
    try {

        Write-Progress -Activity "Module Installation"  -Status "Unpack Module" -PercentComplete 0;
        Write-Debug "Unzip file to folder $Archive";
        Expand-Archive -Path "$($Archive).zip" -DestinationPath $Archive -Force;
    }
    catch { Write-Host "Error Unzipping Archive" }

    Write-Progress -Activity "Module Installation"  -Status "Unpack Module" -PercentComplete 40;
}
function Move-ModuleFiles {
    param (
        [string] $ArchiveFolder,
        [string] $Module,
        [string] $DestFolder,
        [string] $repoBranch,
        [string] $ModuleHash
    )
    
}
function Invoke-Cleanup{
    param (
        [string] $ArchiveFolder
    )
    Write-Progress -Activity "Module Installation"  -Status "Finishing Installation and Cleanup " -PercentComplete 80;
    Remove-Item "${ArchiveFolder}*" -Recurse -ErrorAction SilentlyContinue;
    Write-Progress -Activity "Module Installation"  -Status "Module installed sucessaful";
}
function Write-Finish {
    param (
        [string] $moduleName
    )
    Write-Host "Module installation complete";

    Write-Host "Type 'Import-Module $moduleName' to start using module";

}
function GetGroupValue($match, [string]$group, [string]$default = "") {
    $val = $match.Groups[$group].Value
    Write-Debug $val
    if ($val) {
        return $val
    }
    return $default
}
function Convert-GitHubUrl(){
    param (
        [string]$Url
    )
    
    $githubUriRegex = "(?<Scheme>https://)(?<Host>github.com)/(?<User>[^/]*)/(?<Repo>[^/]*)(/tree/(?<Branch>[^/]*)(/(?<Folder>.*))?)?(/archive/(?<Branch>.*).zip)?";

    $githubMatch = [regex]::Match($Url, $githubUriRegex);

    if ( ! $(GetGroupValue $githubMatch "Host") ) {
        throw [System.ArgumentException] "Incorrect 'Host' value. The 'github.com' domain expected";
        #Write-Error -Message "Incorrect 'Host' value. The 'github.com' domain expected" -Category InvalidArgument
    }
    return @{ 
        User = GetGroupValue $githubMatch "User"
        Repo = GetGroupValue $githubMatch "Repo"
        Branch = GetGroupValue $githubMatch "Branch" "master"
        ModulePath = GetGroupValue $githubMatch "Folder"
    }
}

# in case when both Url and Repo variables are empty - request params in the interactive mode
if ( "x$Url" -eq "x" -and "x$Repo" -eq "x" -and "x$FileUrl" -eq "x" ) {

    $result = Read-ParamMode
    switch ($result)
    {
        0 {
            $Url = $host.ui.Prompt($null,$null,"Github Module Url")
        }
        1 { 
            $res = Read-RepoInfo -User $User -Repo $Repo -ModulePath $ModulePath  -Branch $Branch
            $User = $res['User'];
            $Repo = $res['Repo'];
            $Branch = $res['Branch'];
            $ModulePath = $res['ModulePath'];
         }
        2 {
            $FileUrl = $host.ui.Prompt($null,$null,"Github File Url")
        }
    }
}
# try convert url to fully cvalified path
if( -not [string]::IsNullOrWhitespace($Url) ){
    $res = Convert-GitHubUrl -Url $Url
    $User = $res['User'];
    $Repo = $res['Repo'];
    $Branch = $res['Branch'];
    $ModulePath = $res['ModulePath'];
}
if( -not ([string]::IsNullOrWhitespace($ModulePath)) ){
    $moduleToLoad = $ModulePath;
    $moduleName = Split-Path $moduleToLoad -leaf;
    
}
else{
    $moduleName = $Repo;
    $moduleToLoad = "";
}
if( ([string]::IsNullOrWhitespace($Branch)) ){
    $Branch = "main";
}

$host.ui.WriteLine([ConsoleColor]::Green, [ConsoleColor]::Black, "Start downloading Module ${moduleName} from GitHub Repository:${Repo} User:${User} Branch:${Branch}")
$tempFile = Get-LocalTempPath -RepoName $Repo;
$moduleFolder = "$Env:Programfiles\WindowsPowerShell\Modules\$moduleName"
$downloadUrl = [uri]"https://github.com/${User}/${Repo}/archive/${Branch}.zip";
$file =  "${tempFile}.zip";
Receive-Module -Url $downloadUrl -File $file;
$archiveName = $tempfile;
$repoBranch =  $repo + "-" + $branch
Expand-Archive -Path "$($archiveName).zip" -DestinationPath $archiveName -Force;
Write-Progress -Activity "Module Installation"  -Status "Unpack Module" -PercentComplete 40;
$path = (Resolve-Path -Path "${archiveName}\$repoBranch\$moduleToLoad").Path
Write-Progress -Activity "Module Installation"  -PercentComplete 40;    
Write-Progress -Activity "Module Installation"  -Status "Copy Module to PowershellModules folder" -PercentComplete 50;
$destFolder = "$Env:Programfiles\WindowsPowershell\Modules\$module"
Move-Item -Path $path -Destination "$DestFolder" -Force;
Write-Progress -Activity "Module Installation"  -Status "Copy Module to PowershellModules folder" -PercentComplete 60;
#Move-ModuleFiles -ArchiveFolder $archiveName -RepoBranch $repoBranch -Module $moduleToLoad -DestFolder $moduleFolder;
Invoke-Cleanup -ArchiveFolder $archiveName
Write-Finish -moduleName $moduleName

# SIG # Begin signature block
# MIIvbQYJKoZIhvcNAQcCoIIvXjCCL1oCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC78Kv65A8f8uSk
# MO0ysIiylkhjWRqD5AiZwntRfMiwv6CCFFMwggWQMIIDeKADAgECAhAFmxtXno4h
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
# KoZIhvcNAQkEMSIEIN9TuiPU3Ztef+kxwJ4PPzfzL9xmw6GPvxHqElTse9xuMA0G
# CSqGSIb3DQEBAQUABIICABBsC0Kx8iszSP6CJBquUhtM5fcV4CouDvxWyOT35uay
# HMWBtzBstVkRcpuVKHGApmmRGIaqf1Bj74oe8hWqehGEo5jiNYUwaMUbEjt7lsfS
# fOn35zKIWYgfam57lYZiXaGn+7g/rezajcB4y90ynA4F3YBtmfPwfrFdKSbbhMhm
# P5uUA+OE3U0/VpX6H9NhcnzmWVJXLwl4b81PwB5MgHT8AGIZFY/TeHiTDUsFfgYi
# L7iMeITZFWrxRK0jpZI2VMmZNCz3BENxsZBJgbLiL521jkwYG7Bx/lp5jrXzVCKd
# ++5Ni2laf+qEafiDwMhF+UVfGx3qGsLjG9Vy6IHMqfvkdXp0jkNchE9gqNauhokd
# W/TjRHg60L64rycOhg18k6vIaTo5tg2tHRcX+luMygEf2VYrHJWJGY7FG4x4s/G3
# N4QVnICNQgn8rXaRVXw/8C/j51xIPrA88qbGMsGFKqT3i3c/KQmE0S6bNcybGSrV
# Rf359F+0o7vjujTPks6vYqi4v5rYuKZd5Z2R+Z6JlWMiDWUXa2+//dnCU0HeYCmE
# /LJmDutufqbpBPEOKEKqRe/FCswMAZeY9VgRMLu99J9Clv2Qzi3XAfROgZ+nAzAW
# 2lZMQQXycz4wb269/EBMwwmbl274dSOlWc8zifX+qlzV9oXyVh/gzUtAs5yBZUsj
# oYIXPTCCFzkGCisGAQQBgjcDAwExghcpMIIXJQYJKoZIhvcNAQcCoIIXFjCCFxIC
# AQMxDzANBglghkgBZQMEAgEFADB3BgsqhkiG9w0BCRABBKBoBGYwZAIBAQYJYIZI
# AYb9bAcBMDEwDQYJYIZIAWUDBAIBBQAEIHgNktox/iL82zZH/5/QGN7OgPdZYjW+
# lJjU8FhJAt+5AhAMnfcxXch5IY1q+xps/kvTGA8yMDIzMDQwMzIwMTAxNVqgghMH
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
# SIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMzA0MDMyMDEwMTVaMCsGCyqGSIb3
# DQEJEAIMMRwwGjAYMBYEFPOHIk2GM4KSNamUvL2Plun+HHxzMC8GCSqGSIb3DQEJ
# BDEiBCAkEMJT491E3hxvonhgzqQnE3CrzugE7vwcRbeh3cDG1DA3BgsqhkiG9w0B
# CRACLzEoMCYwJDAiBCDH9OG+MiiJIKviJjq+GsT8T+Z4HC1k0EyAdVegI7W2+jAN
# BgkqhkiG9w0BAQEFAASCAgAkjmdzwbeWgFpPr6e8eyhjxETCkovRRAy8Pr6UKXtt
# DxOx15W6SGAXiKm/cpnCybS3cYAKPVQ6vaiKEctoZacitFeczZ4pB2TBRQVEervP
# jI3aF8SYpXbKXrfx7TaKwKz+Ib6sz9phVMRhJZri9GeZ15zRpOIqvWBG054lAJkS
# mZBAZl6e02QUsVXkE311o9H77/WXo8pvyOxwgPfc1pl5sBgqo79Vj5JVEZdrVwgN
# HaopV8IOq+IsDDNhUG6431Pj/yIzDQvt8kyGHQCKdPuza2O6XRY1fLyQFMDtJF47
# FVlSP69d7IMnRdUFkRm27po3bkgH8+QYagIVqaLgbxehoKjRWhBLkEAXOzAURuEo
# IBX+8lx8aMEbugjSJJi77YfpXXUcsQGqc1GJFAfDKBUKfjEjpxRvPfPQhu8Rc0Zc
# z9f4T5iB0mhltjsPKLbnhdj2kuRzVd4lpqsxehKuq5x3xwrDy9LmCE+Cn1TeI0zV
# 9IAMYDz2Ow47pFwbWlEbvBdhJ6ZqEvJMErTRC40x0TRoXsDj5V3Wk9AyKPX8anTO
# gay7ID07IncAVCmq7AU7fChNFG8AjWeU767unePF73blIPqSPIrcxWOu/PFjh3uH
# nc3LNG9dIppX96rOAVcIm5D9P/Sy4kfDRnahoanFh6leVKtE1ucMT/nAkv3OEZcd
# MA==
# SIG # End signature block
