# [HKEY_LOCAL_MACHINE\SYSTEM\Setup\LabConfig]
# "BypassTPMCheck"=dword:00000001
# "BypassSecureBootCheck"=dword:00000001
# "BypassRAMCheck"=dword:00000001

# Test registry path
$RegistryPath = 'HKLM:\SYSTEM\Setup\LabConfig'
if (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  

# Set keys
New-ItemProperty -Path $RegistryPath -Name 'BypassTPMCheck' -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path $RegistryPath -Name 'BypassSecureBootCheck' -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path $RegistryPath -Name 'BypassRAMCheck' -Value 1 -PropertyType DWord -Force


# [HKEY_LOCAL_MACHINE\SYSTEM\Setup\MoSetup]
# "AllowUpgradeWithUnsupportedTPMOrCPU"=dword:00000001

# Test registry path
$RegistryPath = 'HKLM:\SYSTEM\Setup\MoSetup'
if (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  

# Set keys
New-ItemProperty -Path $RegistryPath -Name 'AllowUpgradeWithUnsupportedTPMOrCPU' -Value 1 -PropertyType DWord -Force
