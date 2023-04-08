@{
    Root = 'E:\EWF-Implementations-Public\ServerTests\Synergy\Synergy Test Tool.ps1'
    OutputPath = 'e:\EWF-Implementations-Public\out'
    Package = @{
        Enabled = $true
        Obfuscate = $false
        HideConsoleWindow = $true
        DotNetVersion = 'v4.6.2'
        FileVersion = '1.0.1'
        FileDescription = 'Testing tool for Synergy and EWF Integrations'
        Platform = 'x64' # Sets the architecture of the executable. Can be either 'x86' or 'x64'
        Package    = @{
            Enabled   = $true
            Resources = [string[]]@("favicon.ico")
        }
        ApplicationIconPath = 'E:\EWF-Implementations-Public\ServerTests\Synergy\favicon.ico'
        ProductName = 'Synergy Test Tool'
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
        