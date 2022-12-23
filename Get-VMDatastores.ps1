function Get-VMDatastores {
    <#
    .SYNOPSIS
    Retrieves the datastore names that are in use for each VM.

    .DESCRIPTION
    This function retrieves the datastore names that are in use for each VM and outputs the
    VM name, power state, and a comma-separated list of datastore names.

    .INPUTS
    This function does not accept any inputs.

    .OUTPUTS
    This function does not produce any outputs.
    #>

    Get-VM |
	Select-Object Name,
	@{N="PowerState";E={($_.PowerState).ToString()}},
	@{N="Datastore";E={[string]::Join(',',(Get-Datastore -Id $_.DatastoreIdList | Select-Object -ExpandProperty Name))}}
}
