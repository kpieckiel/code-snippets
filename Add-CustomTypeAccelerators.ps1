# Add custom type accelerators.
$Accelerators = [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
$Accelerators::Add('VMFolder', [VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder])
#$Accelerators::Add('', [])
