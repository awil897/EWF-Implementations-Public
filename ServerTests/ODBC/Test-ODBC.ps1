function Test-ODBC {
    [CmdletBinding()]
    Param(
    [Parameter(ParameterSetName='SQLAuth', Mandatory=$False)]
    [switch]$SqlAuth,
    
    [Parameter(ParameterSetName='SQLAuth', Mandatory=$True)]
    [string]$SqlAuthUsername,
    
    [Parameter(ParameterSetName='SQLAuth', Mandatory=$True)]
    [string]$SqlAuthPassword,
    
    [Parameter(ParameterSetName='IntegratedAuth', Mandatory=$False)]
    [switch]$IntegratedAuth,
    
    [Parameter(Mandatory=$True)]
    [string]$SqlQuery
    )
    
    
    $dsn = (Get-OdbcDsn | Out-GridView -PassThru).name
    if ($integratedAuth){
    $me = whoami
    Write-Host "Connecting to SQL as $me using the $dsn DSN"
    $connectstring = "DSN=$dsn;"
    }
    elseif ($sqlAuth) {
    Write-Host "Connecting to SQL as $sqlAuthUsername using the $dsn DSN"
    $connectstring = "DSN=$dsn;Uid=$sqlAuthUsername;Pwd=$sqlAuthPassword;"
    }
    
    $conn = New-Object System.Data.Odbc.OdbcConnection($connectstring)
    $conn.open()
    $cmd = New-Object system.Data.Odbc.OdbcCommand($sqlQuery,$conn)
    $da = New-Object system.Data.Odbc.OdbcDataAdapter($cmd)
    $dt = New-Object system.Data.datatable
    $null = $da.fill($dt)
    $conn.close()
    $dt
    }