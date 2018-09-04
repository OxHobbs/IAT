[CmdletBinding()]

param
(
    [String[]]
    $Task = 'default'
)

$ErrorActionPreference = 'Stop'
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent

if (-not (Get-PackageProvider -Name 'NuGet' -ErrorAction SilentlyContinue))
{
    Install-PackageProvider -Name Nuget -Force -Confirm:$False
}

$requiredModules = @(
    'Pester',
    'psake',
    'PSDeploy',
    'PSScriptAnalyzer'
)

foreach ($requiredModule in $requiredModules)
{   
    if (-not (Get-Module -Name $requiredModule -ListAvailable))
    {
        Install-Module -Name $requiredModule -Force -Confirm:$false 
    }
}

Invoke-psake -buildFile "$PSScriptRoot\psakeBuild.ps1" -taskList $Task -Verbose:$VerbosePreference

if ($psake.build_success -eq $false) 
{
    exit 1
} 
else 
{
    exit 0 
}