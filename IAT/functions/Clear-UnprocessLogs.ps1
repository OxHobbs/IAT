<#
.SYNOPSIS
Clear logs that are waiting to be processed by the LogRhythm Mediator server.

.DESCRIPTION
This cmdlet will automate the process of ensuring the LogRhtyhm Mediator server is processing logs that are in the 'UnprocessedLogs' folder.  If the Mediataor server fails during the process the cmdlet will attempt to self heal the service.

.PARAMETER ToProcessLimit
This parameter allows you to limit the number of gz files to process.  Normally this paramter is only used during testing or test runs of the cmdlet.

.PARAMETER ProcessTimeout
Specify the threshold for the amount of time the cmdlet will wait for a log unit (gz file) to be processed by LogRhythm in minutes.  If this threshold is hit then the cmdlet will throw an error for the administrator to troubleshoot.

.EXAMPLE
This example shows the standard way to run this cmdlet.  Note that this cmdlet should be ran locally from the Mediator Server.

Clear-UnprocessedLogs
#>
Function Clear-UnprocessedLogs
{
    [CmdetBinding()]

    param
    (
        [Parmeter()]
        [Int]
        $ToProcessLimit,

        [Parameter()]
        [Int]
        $ProcessTimeout = 5
    )
    
    
    $unprocessedLogs = Get-ChildItem 'C:\Program Files\LogRhythm\LogRhythm Mediator Server\state\UnprocessedLogsToMove'
    
    if ($ToProcessLimit)
    {
        $unprocessedLogs = $unprocessedLogs | Select-Object -First $ToProcessLimit
    }
    
    $processingFolder = "C:\Program Files\LogRhythm\LogRhythm Mediator Server\state\UnprocessedLogs"
    $successCount = 0
    
    if (-not $unprocessedLogs)
    {
        Write-Host "There are no logs that need to be processed."
    }
    
    $existingProcessingLogs = Get-ChildItem $processingFolder
    
    if ($existingProcessingLogs)
    {
        Write-Host "There are $($existingProcessingLogs.Count) files already in the processing folder"
        Write-Host "  Attempting to clear logs before continuing"
        $null = Initialize-QueueShrink
    }
    
    Write-Host "There are $($unprocessedLogs.Count) that need to be processed`n"
    if (-not (Test-LRHealth)) { $null = Initialize-QueueShrink }
    
    foreach ($log in $unprocessedLogs)
    {
    
        if (-not (Test-LRHealth)) { $null = Initialize-QueueShrink }
    
        $StartTime = Get-Date
        $TimeoutTime = $StartTime.AddMinutes($ProcessTimeout)
    
        $logInProcessing = Join-Path -Path $processingFolder -ChildPath $log.Name
    
        Write-Host "Processing log: $($log.Name)" -ForegroundColor Magenta
        Write-Host "  Moving $($log.Name) to Process folder" -NoNewLine
        Move-Item -Path $log.FullName -Destination $logInProcessing
        Write-Host " -> Moved" -ForegroundColor Green
    
        $whileCount = 0
        Write-Host "  Monitoring the log in processing, timeout is set to $ProcessTimeout minutes..."
        While ((Get-Date) -lt $TimeoutTime)
        {
            $whileCount++
            Start-Sleep -Seconds 5
            $IsStillProcessingTest = Test-Path -Path $logInProcessing
    
            if ($IsStillProcessingTest)
            {
                if (($whileCount % 3) -eq 0)
                {
                    $diff = (Get-Date) - $StartTime
                    Write-Host "  $($log.Name) time in processing -> $($diff.Minutes) mins $($diff.Seconds) seconds"
                }
                Continue
            }
    
            $successCount++
            Write-Host "  Processed $($log.Name) Successfully --> $successCount total processed" -ForegroundColor Green
            break
        }
    
        if (Test-Path -Path $logInProcessing)
        {
            $null = Initialize-QueueShrink
        }
    }
}
