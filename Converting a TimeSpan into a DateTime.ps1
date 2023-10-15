# Convert a TimeSpan to a DateTime

# Start with a DateTime of zero ticks
$dt = Get-Date -Year 1 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0

# Create the TimeSpan from a tick count (can use New-TimeSpan, too)
$Ticks = 621355788000000000  # Unix time epoch
$ts = [TimeSpan]::New($Ticks)

# Simply add them together and voila!
$dt += $ts

$dt
