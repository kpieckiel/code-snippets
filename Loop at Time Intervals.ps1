# Example of how to loop at time intervals (e.g., a game loop)

$Sync = New-TimeSpan -Seconds 2
$Tick = New-TimeSpan -Seconds 5
$Samples = 8640
1..$Samples | ForEach-Object -Begin {
	Clear-Host
	Write-Host 'Setting up'
	$Ticks = (Get-Date).Ticks
	$NextTick = $Ticks - ($Ticks % $Sync.Ticks) + $Sync.Ticks * 2
	Start-Sleep -Duration ([TimeSpan]::New($Sync.Ticks - ($Ticks % $Sync.Ticks)))
	Write-Host 'Starting now'
} -Process {
	Start-Sleep -Duration ([TimeSpan]::New($NextTick - (Get-Date).Ticks))
	$NextTick += $Tick.Ticks

	Write-Host 'Doing work now....'
}
