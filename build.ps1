[CmdletBinding()]

param
(
    [String[]]
    $Task = 'default'
)

$ErrorActionPreference = 'Stop'
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent

if (-not (Get-Module -Name Pester -ListAvailable))   { Install-Module -Name Pester -Force -Confirm:$false }
if (-not (Get-Module -Name psake -ListAvailable))    { Install-Module -Name psake -Force -Confirm:$false }
if (-not (Get-Module -Name PSDeploy -ListAvailable)) { Install-Module -Name PSDeploy -Force -Confirm:$false }

Invoke-psake -buildFile "$PSScriptRoot\psakeBuild.ps1" -taskList $Task -Verbose:$VerbosePreference

if ($psake.build_success -eq $false) 
{
    exit 1
} 
else 
{
    exit 0 
}