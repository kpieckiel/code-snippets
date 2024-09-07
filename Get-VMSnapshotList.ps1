function Get-VMSnapshotList {
	<#
    .SYNOPSIS
    Displays basic data about all VM snapshots.

    .DESCRIPTION
    Displays select useful data about all VM snapshots.

    .INPUTS
    This function does not take pipelined inputs.

    .OUTPUTS
    This function does not output any objects.
    #>

    Get-VM | Get-Snapshot | Select-Object Id, Name, VM, Created, SizeGB | ForEach-Object {
        $decodedName = $_.Name
        $decodedName = [System.Web.HttpUtility]::UrlDecode($decodedName)
        $decodedName = [System.Web.HttpUtility]::UrlDecode($decodedName)

        # Ensure the DateTime is marked as UTC
        $utcTime = [DateTime]::SpecifyKind($_.Created, [DateTimeKind]::Utc)
        
        # Convert from UTC to local time
        $localTime = $utcTime.ToLocalTime()
        
        [PSCustomObject]@{
            Id       = ($_.Id -split '-')[2]
            Name     = $decodedName
            VM       = $_.VM
            Created  = $_.Created
            SizeGB   = $_.SizeGB
        }
    }
}