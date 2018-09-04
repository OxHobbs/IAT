Deploy "Deploy to Dev" {
    By FileSystem  {
        FromSource 'IAT'
        To 'c:\deployments\dev'
        Tagged Dev
        WithOptions @{
            Mirror = $true
        }
    }
}

Deploy "Deploy to Prod" {
    By FileSystem  {
        FromSource 'IAT'
        To 'c:\deployments\prod'
        Tagged Prod
        WithOptions @{
            Mirror = $true
        }
    }
}