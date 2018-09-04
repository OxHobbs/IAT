Deploy "Deploy to Dev" {
    By Task PackageInVersionDir {
        $manifest = Import-LocalizedData -FileName 'IAT.psd1' -BaseDirectory 'IAT'
        $version = $manifest.ModuleVersion
        $env:DevDeployDir = "c:\deployments\dev\IAT\$version"

        if (Test-Path $deployDir)
        {
            throw "Version is already deployed.  Must bump version properly before deploying a new version"
        }

        Copy-Item -Path IAT -Recurse -Destination $deployDir
    }

    By FileSystem  {
        FromSource 'IAT'
        To $env:DevDeployDir
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
        $env:ProdDeployDir = "c:\deployments\prod\IAT\$version"

        if (Test-Path $deployDir)
        {
            throw "Version is already deployed.  Must bump version properly before deploying a new version"
        }
    }

    By FileSystem  {
        FromSource 'IAT'
        To $env:ProdDeployDir
        Tagged Prod
        DependingOn 'PackageVersionDir'
        WithOptions @{
            Mirror = $true
        }
    }
}