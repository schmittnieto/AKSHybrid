#region Snippet 1: Functions
function Get-Option-Az ($azcmd, $filterproperty) {
    # Usage: $rg = Get-Option-Az $(az group list --output json --all) "name"
    # This function is similar to the Get-Option function, but uses the az cli instead of Invoke-Expression.
    $items = @("")
    $selection = $null
    $filteredItems = @()
    # Execute az cli command and convert JSON output to PowerShell objects.
    $result = $azcmd | ConvertFrom-Json
    # Sorts the objects by the filter property and adds them to the element array
    $i = 0
    $result | Sort-Object $filterproperty | ForEach-Object -Process {
      $items += "{0}. {1}" -f $i, $_.$filterproperty
      $i++
    } 
    # Filters empty items and displays them in columns
    $filteredItems += $items | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $filteredItems | Format-Wide { $_ } -AutoSize -Force | Out-Host
    # prompts the user to select an item by number and returns the filter property of the selected item
    do {
      $r = [int]::Parse((Read-Host "Select by number"))
      $selection = $filteredItems[$r] -split "\.\s" | Select-Object -Last 1
      if ([String]::IsNullOrWhiteSpace($selection)) { Write-Host "You must make a valid selection" -ForegroundColor Red }
      else {
        Write-Host "Selecting $($filteredItems[$r])" -ForegroundColor Green
      }
    }until (!([String]::IsNullOrWhiteSpace($selection)))
      
    return $selection
  }
#endregion
#region Snippet 2: Requierements: Az CLI and arcdata extension

<# Install Az CLI
Write-Host "Installing AzCLI....                                                           " 
    start-bitstransfer https://aka.ms/installazurecliwindows ".\AzureCLI.msi" -Priority High -RetryInterval 60  -Verbose -SecurityFlags 0,0,0 -TransferPolicy Always #faster
    Msiexec.exe /i AzureCLI.msi /qn
    #sleep 40 (it takes 1 minute for installation),

#restart powershell
exit

# Install az extension
az extension add --name arcdata --allow-preview --only-show-errors
az extension update --name arcdata --allow-preview --only-show-errors
az extension add --name stack-hci-vm --allow-preview --only-show-errors
az extension update --name stack-hci-vm --allow-preview --only-show-errors
az extension add --name customlocation --allow-preview --only-show-errors
az extension update --name customlocation --allow-preview --only-show-errors
#>

#endregion
#region Snippet 3: Deploying SQL Managed Instance
az login --use-device-code
Write-Host "Select the AKS Subscription" -ForegroundColor Green
$AZsubscription = Get-Option-Az $(az account list --output json) "name"
az account set --name $AZsubscription
Write-Host "Select the AKS Resource Group" -ForegroundColor Green
$resource_group = Get-Option-Az $(az group list --output json) "name"
Write-Host "Select the AKS Cluster" -ForegroundColor Green
$AKSCluster = Get-Option-Az $(az resource list -g $resource_group --resource-type "Microsoft.Kubernetes/connectedClusters" --output json) "name"
Write-Host "Select a customlocation"
$customlocationID = Get-Option-Az $(az customlocation list --output json) "id"

#region Snippet 3.1: Storage Path Creation
# https://learn.microsoft.com/en-us/azure-stack/hci/manage/create-storage-path?tabs=azurecli

$path = "C:\ClusterStorage\UserStorage_1\SQLmi"
Write-Host "Path: $path"
$storagepathname = "sqlmi-storagepath"
Write-Host "Storagepathname: $storagepathname"
az stack-hci-vm storagepath create --resource-group $resource_group --custom-location $customLocationID --name $storagepathname --path $path
$storagepathID = az stack-hci-vm storagepath show --name $storagepathname --resource-group $resource_group --query "id" -o tsv
#endregion

#region 3.2: Create custom Storage class for disks
# https://learn.microsoft.com/en-us/azure/aks/hybrid/container-storage-interface-disks#create-custom-storage-class-for-disks

$kubecfgfolder = "$env:USERPROFILE\.kube"
if (-not (Test-Path $kubecfgfolder -ErrorAction Ignore)){
    New-Item -Path $kubecfgfolder -ItemType Directory
}
$kubecfgdata = "$kubecfgfolder\aks-arc-kube-config"
if (Test-Path $kubecfgdata) {
    Remove-Item $kubecfgdata
}
Set-Location $kubecfgfolder
az akshybrid get-credentials --name $AKSCluster --resource-group $resource_group --file aks-arc-kube-config --admin

$SQLmiStorageYaml = "SQLmiStorage.yaml"
New-Item $SQLmiStorageYaml
"kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
 name: aks-hci-disk-custom
provisioner: disk.csi.akshci.com
parameters:
 blocksize: `"33554432`"
 container: $storagepathID
 dynamic: `"true`"
 group: sqlmi-storagepath
 hostname: sqlmi-storagepath
 logicalsectorsize: `"4096`"
 physicalsectorsize: `"4096`"
 port: `"55000`"
 fsType: ext4
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: Immediate" | Out-File $SQLmiStorageYaml

kubectl apply -f $SQLmiStorageYaml --kubeconfig .\aks-arc-kube-config

#region 3.3: Configure Storage
$AZsubscriptionID = az account show --query "id" -o tsv
$arcdataprofilname = "azure-arc-aks-hci"
Write-Host "Storagepathname: $arcdataprofilname"
Write-Host "Select location for arcdata dc"
$K8Location = Get-Option-Az $(az resource list -g $resource_group --resource-type "Microsoft.Kubernetes/connectedClusters" --name $AKSCluster) "location"
$K8Namespace = "default"
Write-Host "K8Namespace: $K8Namespace"
az arcdata dc create --profile-name $arcdataprofilname  --k8s-namespace $K8Namespace --use-k8s --name arc --subscription $AZsubscriptionID --resource-group $resource_group --location $K8Location --connectivity-mode indirect
#endregion
#endregion