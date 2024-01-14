@ECHO OFF

REG ADD "HKLM\SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "00000001" /f
REG ADD "HKLM\SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "00000001" /f
REG ADD "HKLM\SYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "00000001" /f

REG ADD "HKLM\SYSTEM\Setup\MoSetup" /v "AllowUpgradeWithUnsupportedTPMOrCPU" /t REG_DWORD /d "00000001" /f
