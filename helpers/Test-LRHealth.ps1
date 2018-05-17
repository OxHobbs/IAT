Function Test-LRHealth
{
    [CmdletBinding()]

    param()

	$lrLog = "C:\Program Files\LogRhythm\LogRhythm Mediator Server\logs\scmedsvr.log"
	return -not ((Get-Content $lrLog -Tail 1) -match "Unprocessed log realtime queue size \(\d+\) exceeds maximum queue size \(\d+\), spooling to disk")

	$logFolderItems = Get-ChildItem 'C:\Program Files\LogRhythm\LogRhythm Mediator Server\state\UnprocessedLogs'
	if ($logFolderItems)
	{
		return $logFolderItems.Count -lt 10
	}
}