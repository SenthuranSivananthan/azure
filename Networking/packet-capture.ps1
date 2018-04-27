## This script will run packet capture on EVERY VIRTUAL MACHINE in the resource group
## Ensure that Network Watcher Extension is installed on the VMs

$VMResourceGroup = "demo-packet-capture"

# Storage account to save the packet captures
$StorageAccountId = "/subscriptions/0000000-0000-0000-0000-000000000000/resourceGroups/demo-packet-capture/providers/Microsoft.Storage/storageAccounts/packetcapture"

# Network Watcher
$NWResourceGroup = "---SET-RG-FOR-NETWROK-WATCHER---"
$NWNamePrefix = "NetworkWatcher_"

$PacketCaptureDurationInSeconds = 60

$PacketCaptureNamePrefix = "---CHANGE-PREFIX---"
$PacketCaptureNameSuffix = $(get-date -f yyyy-MM-dd-HHmmss)
$VMs = Get-AzureRmVM -ResourceGroup $VMResourceGroup

$NetworkWatcher = Get-AzureRmNetworkWatcher -Name $NWName -ResourceGroupName $NWResourceGroup

ForEach ($VM in $VMs)
{
    $NWName = $NWNamePrefix + $VM.Location
    $PacketCaptureName = $PacketCaptureNamePrefix + "-" + $VM.Name + "-" + $PacketCaptureNameSuffix

    #Initiate packet capture on the VM that fired the alert
    Write-Output "Initiating Packet Capture on $($VM.Name)"
    New-AzureRmNetworkWatcherPacketCapture -NetworkWatcher $NetworkWatcher -TargetVirtualMachineId $VM.Id -PacketCaptureName $PacketCaptureName -StorageAccountId $StorageAccountId -TimeLimitInSeconds $PacketCaptureDurationInSeconds
}
