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
    $null = Invoke-Pester -CodeCoverage ".\IAT\functions\Test-Tests.ps1" -CodeCoverageOutputFile $coverageResultsFileName -CodeCoverageOutputFileFormat JaCoCo 
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}

task DeployToDev {
    
    Invoke-PSDeploy -Path $psDeployScript -Verbose:$VerbosePreference -Tags Dev -Force
}

task DeployToProd {
    Invoke-PSDeploy -Path $psDeployScript -Verbose:$VerbosePreference -Tags Prod -Force
}