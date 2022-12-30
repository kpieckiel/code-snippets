<#
.SYNOPSIS
Display a PowerShell console color table.

.DESCRIPTION
Displays a table that demonstrates all the text colors available in
the PowerShell console.

.INPUTS
This script does not take pipelined inputs.

.OUTPUTS
This script does not output any objects.

.NOTES
A 136-character windows width is required to properly display the table.

.LINK
https://stackoverflow.com/a/41954792/5344665
#>

$colors = [enum]::GetValues([System.ConsoleColor])
ForEach ($bgcolor in $colors) {
    ForEach ($fgcolor in $colors) {
		Write-Host "$fgcolor|" -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine
	}
	
    Write-Host " on $bgcolor"
}