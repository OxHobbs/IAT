Function Restart-LRMediatorServices
{
	try
	{
		$crashCount++
		Write-Host "  Attempting to self heal due to assumed crash" -ForegroundColor Yellow
		Write-Host "  Stopping Mediator service..."
		Stop-Service -Name scmedsvr -ErrorAction Stop
		Write-Host "  Stopped Mediator service"

		Start-Sleep -Seconds 5

		Write-Host "  Restarting SQL Service..."
		Restart-Service MSSQLSERVER -Force -ErrorAction Stop
		Write-Host "  Restarted SQL Service"

		Start-Sleep -Seconds 5

		Write-Host "  Starting Mediator service..."
		Start-Service scmedsvr -ErrorAction Stop
		Write-Host "  Started Mediator service"
		Start-Sleep -seconds 10

	}
	catch
	{
		Write-Error $_.Exception.ToString()
	}
}
