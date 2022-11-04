Function Test-InternetConnection {
[cmdletbinding(
    DefaultParameterSetName = 'Site'
)]
param(
    [Parameter(
        Mandatory = $True,
        ParameterSetName = '',
        ValueFromPipeline = $True)]
        [string]$Site,
    [Parameter(
        Mandatory = $True,
        ParameterSetName = '',
        ValueFromPipeline = $False)]
        [Int]$Wait
    )
    #Clear the screen
    Clear
    #Start testing the connection and continue until the connection is good.
    While (!(Test-Connection -computer $site -count 1 -quiet)) {
        Write-Host -ForegroundColor Red -NoNewline "Connection down..."
        Start-Sleep -Seconds $wait
        }
    #Connection is good
    Write-Host -ForegroundColor Green "$(Get-Date): Connection up!"
}

$ErrorActionPreference = "Continue"

Write-Host "Testing connection to required websites"

Try {
    $response = (Invoke-WebRequest "https://jhadownloads.jackhenry.com").StatusCode
    if ($response -like "200"){
        $jackhenryTest = "Successful"
    }
    else {
    $jackhenryTest = $response
    }
}
Catch {
    if($_.ErrorDetails.Message) {
        $jackhenryTest = $_.ErrorDetails.Message
    } else {
        $jackhenryTest = $_
    }
}
Try {
    $response = (Invoke-WebRequest "https://secure.jhahosted.com").StatusCode
    if ($response -like "200"){
        $jhahostedTest = "Successful"
    }
    else {
    $jhahostedTest = $response
    }
}
Catch {
    if($_.ErrorDetails.Message) {
        $jhahostedTest = $_.ErrorDetails.Message
    } else {
        $jhahostedTest = $_
    }
}
Try {
    $response = (Invoke-WebRequest "https://go.Microsoft.com").StatusCode
    if ($response -like "200"){
        $MicrosoftTest = "Successful"
    }
    else {
    $MicrosoftTest = $response
    }
}
Catch {
    if($_.ErrorDetails.Message) {
        $MicrosoftTest = $_.ErrorDetails.Message
    } else {
        $MicrosoftTest = $_
    }
}
Try {
    $response = (Invoke-WebRequest "https://api.Github.com").StatusCode
    if ($response -like "200"){
        $GithubTest = "Successful"
    }
    else {
    $GithubTest = $response
    }
}
Catch {
    if($_.ErrorDetails.Message) {
        $GithubTest = $_.ErrorDetails.Message
    } else {
        $GithubTest = $_
    }
}

$testResults = New-Object -TypeName PSObject -Property @{
    'JackHenry.com' = $jackhenryTest
    'JHAHosted.com' = $jhahostedTest
    'Microsoft.com' = $MicrosoftTest
    'Github.com' = $GithubTest
}

return $testResults
