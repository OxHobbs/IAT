$psDeployScript = "$PSScriptRoot\IAT.psdeploy.ps1"
$testResultsFileName = 'unittests_report.xml'
$coverageResultsFileName = 'test_coverage_report.xml'

task default -depends Analyze, Test

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
    $coverageResults = Invoke-Pester -CodeCoverage ".\IAT\functions\Test-Tests.ps1" -CodeCoverageOutputFile $coverageResultsFileName -CodeCoverageOutputFileFormat JaCoCo -PassThru

    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }

    $coveragePercent = ($coverageResults.CodeCoverage.NumberOfCommandsExecuted / $coverageResults.CodeCoverage.NumberOfCommandsAnalyzed) * 100
    Write-Output "Code Coverage: $coveragePercent%"

    if ($coveragePercent -lt 80)
    {
        throw "Code Coverage is too low for a passing build ($coveragePercent)"
    }
}

task DeployToDev {
    
    Invoke-PSDeploy -Path $psDeployScript -Verbose:$VerbosePreference -Tags Dev -Force
}

task DeployToProd {
    Invoke-PSDeploy -Path $psDeployScript -Verbose:$VerbosePreference -Tags Prod -Force
}