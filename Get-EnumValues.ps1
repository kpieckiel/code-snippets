function Get-EnumValues {
	<#
	.SYNOPSIS
	List enumeration names and values.

	.DESCRIPTION
	This script lists all of the names and values of an enumeration.

	.PARAMETER Name
	The name of the enumeration to be viewed.
	
	.EXAMPLE
	Get-EnumValues -Name System.IO.FileAttributes
 
             Name  Value
             ----  -----
             None      0
         ReadOnly      1
           Hidden      2
           System      4
        Directory     16
          Archive     32
           Device     64
           Normal    128
        Temporary    256
       SparseFile    512
     ReparsePoint   1024
       Compressed   2048
          Offline   4096
NotContentIndexed   8192
        Encrypted  16384
  IntegrityStream  32768
      NoScrubData 131072

	.EXAMPLE
	Get-EnumValues -Name VMware.Vim.VirtualMachineGuestOsIdentifier
 
                      Name Value
                      ---- -----
                  dosGuest     0
                win31Guest     1
                win95Guest     2
                win98Guest     3
                winMeGuest     4
                winNTGuest     5
           win2000ProGuest     6
          win2000ServGuest     7
       win2000AdvServGuest     8
            winXPHomeGuest     9
             winXPProGuest    10
           winXPPro64Guest    11
            winNetWebGuest    12

[...]

             vmkernelGuest   182
            vmkernel5Guest   183
            vmkernel6Guest   184
           vmkernel65Guest   185
            vmkernel7Guest   186
            vmkernel8Guest   187
      amazonlinux2_64Guest   188
      amazonlinux3_64Guest   189
              crxPod1Guest   190
        rockylinux_64Guest   191
         almalinux_64Guest   192
                otherGuest   193
              otherGuest64   194	

	.EXAMPLE
	Get-EnumValues -Name Microsoft.Win32.RegistryValueKind
 
        Name Value
        ---- -----
     Unknown     0
      String     1
ExpandString     2
      Binary     3
       DWord     4
 MultiString     7
       QWord    11
        None    -1

	.INPUTS
	This script does not take pipelined inputs.

	.OUTPUTS
	This script does not output any objects.
	#>

	[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Name
	)

	try
	{
		# Get system file attribute values
		[System.Enum]::GetValues($Name) | ForEach-Object -Process {
			[PSCustomObject]@{
				Name = $_
				Value = $_.value__
			}
		} -ErrorAction Stop
	}
	catch
	{
		Write-Error "$($Name) isn't a valid enumeration type."
	}
}
