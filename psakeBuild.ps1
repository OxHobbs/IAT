$psDeployScript = "$PSScriptRoot\Deploy.psdeploy.ps1"
$testResultsFileName = 'test_report.xml'

task default -depends Analyze, Test

task Analyze {
    $saResults = Invoke-ScriptAnalyzer -Path $PSScriptRoot -Recurse -Severity Error -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table
        Write-Error -Message 'One or more Script Analyzer errors/warnings were found. Build cannot continue!'
    }
}

task Test {
    $testResults = Invoke-Pester -Path $PSScriptRoot -PassThru -OutputFile $testResultsFileName -OutputFormat NUnitXml
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