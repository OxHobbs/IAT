Deploy "Deploy to Dev" {
    By Task PackageInVersionDir {
        $manifest = Import-LocalizedData -FileName 'IAT.psd1' -BaseDirectory 'IAT'
        $version = $manifest.ModuleVersion
        $deployDir = "c:\deployments\dev\IAT\$version"

        if (Test-Path $deployDir)
        {
            throw "Version is already deployed.  Must bump version properly before deploying a new version"
        }
    }

    By FileSystem  {
        FromSource 'IAT'
        To $deployDir
        Tagged Dev
        DependingOn 'PackageVersionDir'
        WithOptions @{
            Mirror = $true
        }
    }
}

Deploy "Deploy to Prod" {
    By Task PackageInVersionDir {
        $manifest = Import-LocalizedData -FileName 'IAT.psd1' -BaseDirectory 'IAT'
        $version = $manifest.ModuleVersion
        $deployDir = "c:\deployments\prod\IAT\$version"

        if (Test-Path $deployDir)
        {
            throw "Version is already deployed.  Must bump version properly before deploying a new version"
        }
    }

    By FileSystem  {
        FromSource 'IAT'
        To $deployDir
        Tagged Prod
        DependingOn 'PackageVersionDir'
        WithOptions @{
            Mirror = $true
        }
    }
}