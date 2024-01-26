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
#region Snippet 2: Examples

az login --use-device-code
## Subscription
$AZsubscription = Get-Option-Az $(az account list --output json) "name"
Write-Host "You selected the $AZsubscription as Subscription for this Example"
az account set --name $AZsubscription

## Resource Group
Write-Host "Select the Resource Group" -ForegroundColor Green
$resource_group = Get-Option-Az $(az group list --output json) "name"
Write-Host "You selected the $resource_group as Resource Group for this Example"

## AKS Cluster
Write-Host "Select the AKS Cluster (needs to be in the Resource Group)" -ForegroundColor Green
$AKSCluster = Get-Option-Az $(az resource list -g $resource_group --resource-type "Microsoft.Kubernetes/connectedClusters" --output json) "name"
Write-Host "You selected the $AKSCluster as AKS Cluster for This Example"

## HCI Metadata Location
$HCILocation = get-option-az $(az provider show --namespace Microsoft.AzureStackHCI --query "resourceTypes[?resourceType=='virtualMachineInstances'].locations[]" --output json) "locations"
Write-Host "You selected the $HCILocation as location for HCI Metadata"

## Custom Location ID
$customlocationID = Get-Option-Az $(az customlocation list --output json) "id"
Write-Host "You selected the $customlocationID as customlocation ID"


#endregion