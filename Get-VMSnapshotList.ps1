function Get-VMSnapshotList {
	<#
    .SYNOPSIS
    Displays basic data about all VM snapshots.

    .DESCRIPTION
    Displays select useful data about all VM snapshots.

    .INPUTS
    This script does not take pipelined inputs.

    .OUTPUTS
    This script does not output any objects.
    #>

	Get-VM | Get-Snapshot | Select-Object VM,Name,SizeGB,Created
}
