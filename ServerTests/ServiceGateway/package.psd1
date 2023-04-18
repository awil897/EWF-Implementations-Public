@{
    Root = 'E:\EWF-Implementations-Public\ServerTests\ServiceGateway\Get-SGProviderInformation.ps1'
    OutputPath = 'E:\EWF-Implementations-Public\ServerTests\ServiceGateway'
    Package = @{
        Enabled = $true
        Obfuscate = $false
        HideConsoleWindow = $true
        DotNetVersion = 'v4.6.2'
        FileVersion = '1.0.1'
        FileDescription = 'Testing tool to retrieve Service Gateway Providers'
        Platform = 'x64' # Sets the architecture of the executable. Can be either 'x86' or 'x64'
        Package    = @{
            Enabled   = $true
            Resources = [string[]]@("favicon.ico")
        }
        ApplicationIconPath = 'E:\EWF-Implementations-Public\ServerTests\Synergy\favicon.ico'
        ProductName = 'Get-SGProviderInformation'
        ProductVersion = '1.0.1'
        Copyright = '2023'
        RequireElevation = $true
        PackageType = 'Console'
    }
    Bundle = @{
        Enabled = $true
        Modules = $true
        #IgnoredModules = [string[]]@('WebAdministration','IISAdministration')
    }
}
        