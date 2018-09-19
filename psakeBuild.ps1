$psDeployScript = "$PSScriptRoot\IAT.psdeploy.ps1"
$testResultsFileName = 'unittests_report.xml'
$coverageResultsFileName = 'test_coverage_report.xml'

task default -depends Analyze, Test, Coverage, PackageSxS

task Analyze {
    $saResults = Invoke-ScriptAnalyzer -Path $PSScriptRoot -Recurse -Severity Error -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table
        Write-Error -Message 'One or more Script Analyzer errors/warnings were found. Build cannot continue!'
    }
}

task Test {
    $testPath = Join-Path $PSScriptRoot -ChildPath 'IAT\tests\unit'
    $testResults = Invoke-Pester -Path $testpath -PassThru -OutputFile $testResultsFileName -OutputFormat NUnitXml 

    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}

task Coverage {
    $coverageResults = Invoke-Pester -CodeCoverage ".\IAT\functions\Test-Tests.ps1" -CodeCoverageOutputFile $coverageResultsFileName -CodeCoverageOutputFileFormat JaCoCo -PassThru

    $coveragePercent = ($coverageResults.CodeCoverage.NumberOfCommandsExecuted / $coverageResults.CodeCoverage.NumberOfCommandsAnalyzed) * 100
    Write-Output "Code Coverage: $coveragePercent%"

    if ($coveragePercent -lt 80)
    {
        throw "Code Coverage is too low for a passing build ($coveragePercent)"
    }

    Write-Output "Code Coverage is sufficient to pass tests ($coveragePercent)"

}

task PackageSxS {
    $version = (Invoke-Expression (Get-Content .\IAT\IAT.psd1 | Out-String)).ModuleVersion
    $package = New-Item -ItemType Directory -Path ".\PackageSxS\IAT\$version" -Force
    Copy-Item -Recurse -Path ".\IAT\*" -Destination $package.FullName
}

task DeployToDev {
    Invoke-PSDeploy -Path $psDeployScript -Verbose:$VerbosePreference -Tags Dev -Force
}

task DeployToProd {
    Invoke-PSDeploy -Path $psDeployScript -Verbose:$VerbosePreference -Tags Prod -Force
}