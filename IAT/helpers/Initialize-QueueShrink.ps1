Function Initialize-QueueShrink
{
    [CmdetBinding()]

    param
    (
        [Parmeter()]
        [Int]
        $QueueShrinkTimeout = 180
    )

	Write-host "  Validating that the queue is shrinking" -foregroundcolor cyan
	$beginTime = Get-Date
	$expireTime = $beginTime.AddMinutes($QueueShrinkTimeout)
	$shrinkageResult = $null

	$startItemCount = (Get-ChildItem -Path $processingFolder).Count
	if ($startItemCount -eq 0) { return $true }

	Write-host "  There are $startItemCount files in processing"
	$count = 0
	$failedToShrinkCount = 0
	$previousCount = $startItemCount
	while ((Get-Date) -lt $expireTime)
	{
		if (-not (Test-LrHealth)) { CycleServices }

		$count++
		Start-Sleep -Seconds 30
		$currentCount = (Get-ChildItem -Path $processingFolder).Count

		if ($currentCount -eq 0)
		{
			Write-Host " All logs appear to have been processed" -foregroundcolor green
			$shrinkageResult = $true
			break
		}
		elseif ($currentCount -eq $previousCount)
		{
			Write-Host "  Still $currentCount left to process"
			$failedToShrinkCount++
		}
		elseif ($currentCount -lt $previousCount)
		{
			$failedToShrinkCount = 0
			Write-Host "  Log is shrinking. $currentCount / $startItemCount left."
		}
		if ($failedToShrinkCount -ge 10)
		{
			Write-Host "  It appears that logs are not being processed.  Exiting" -ForegroundColor Red
			$shrinkageResult = $false
			break
		}

		$previousCount = $currentCount

	}

	return $shrinkageResult
}
