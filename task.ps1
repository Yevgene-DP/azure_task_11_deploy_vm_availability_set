# ==============================
# task.ps1 — розгортання двох VM в одному Availability Set без публічних IP
# ==============================

$location = "uksouth"
$resourceGroupName = "mate-azure-task-11"
$networkSecurityGroupName = "defaultnsg"
$virtualNetworkName = "vnet"
$subnetName = "default"
$sshKeyName = "linuxboxsshkey"
$vmImage = "Ubuntu2204"
$vmSize = "Standard_B1s"
$availabilitySetName = "mateavalset"

# Створення групи ресурсів (якщо не існує)
if (-not (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $location
}

# Створення Availability Set
New-AzAvailabilitySet `
    -ResourceGroupName $resourceGroupName `
    -Name $availabilitySetName `
    -Location $location `
    -Sku aligned `
    -PlatformFaultDomainCount 2 `
    -PlatformUpdateDomainCount 2 -ErrorAction Stop

# Розгортання двох VM у Availability Set
for ($i = 1; $i -le 2; $i++) {
    New-AzVm `
        -ResourceGroupName $resourceGroupName `
        -Name "$($vmImage)-vm-$i" `
        -Location $location `
        -VirtualNetworkName $virtualNetworkName `
        -SubnetName $subnetName `
        -SecurityGroupName $networkSecurityGroupName `
        -AvailabilitySetName $availabilitySetName `
        -Image $vmImage `
        -Size $vmSize `
        -SshKeyName $sshKeyName `
        -OpenPorts 22 `
        -ErrorAction Stop
}
