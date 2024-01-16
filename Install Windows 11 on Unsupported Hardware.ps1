# [HKEY_LOCAL_MACHINE\SYSTEM\Setup\LabConfig]
# "BypassTPMCheck"=dword:00000001
# "BypassSecureBootCheck"=dword:00000001
# "BypassRAMCheck"=dword:00000001


# Put registry data here as CSV text.
$CsvKeys = 'Key,Value,Type,Data
HKLM:\SYSTEM\Setup\LabConfig,BypassTPMCheck,DWord,1
HKLM:\SYSTEM\Setup\LabConfig,BypassSecureBootCheck,DWord,1
HKLM:\SYSTEM\Setup\LabConfig,BypassRAMCheck,DWord,1
'

# Convert the CSV text to something usable and extract the unique paths.
$Keys = $CsvKeys | ConvertFrom-Csv
$Paths = $Keys.Key | Sort-Object -Unique

# Make sure all of the paths exist, and create them if they don't.
$Paths | ForEach-Object -Process {
	if (-not (Test-Path -Path $_)) {
	  New-Item -Path $_ -Force | Out-Null
	}
}

# Create the properties and values.
$Keys | ForEach-Object -Process {
	New-ItemProperty -Path $_.Key -Name $_.Value -Value $_.Data `
		-PropertyType $_.Type -Force | Out-Null
}
