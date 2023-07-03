@{
    Root = 'E:\EWF-Implementations-Public\StandaloneTools\MoveDatabases\Move-Databases.form.ps1'
    OutputPath = 'e:\EWF-Implementations-Public\out'
    Package = @{
        Enabled = $true
        Obfuscate = $false
        HideConsoleWindow = $false
        DotNetVersion = 'v4.6.2'
        FileVersion = '1.0.0'
        FileDescription = 'Database move tool, requires DbaTools PS Module'
        Package    = @{
            Enabled   = $true
            Resources = [string[]]@("favicon.ico")
        }
        ApplicationIconPath = 'E:\EWF-Implementations-Public\ServerTests\eSign\favicon.ico'
        ProductName = 'Database Move Tool'
        ProductVersion = '1.0.0'
        Copyright = '2023'
        RequireElevation = $false
        PackageType = 'Console'
    }
    Bundle = @{
        Enabled = $true
        Modules = $true
        # IgnoredModules = @()
    }
}
        