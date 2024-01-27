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

#region Snippet 2: Connect the Network to Azure (it need to run externaly, not on the cluster) 
az login --use-device-code
$clustervnetname = Read-Host "Enter Cluster Network Name (take the same name as you used on AKSNetworkConfigCreate)" # For Example: "testaksvnet" take the same name ($clustervnetname) as you used on AKSNetworkConfigCreate 
Write-Host "Select a resource Group"
$resource_group = Get-Option-Az $(az group list --output json) "name"
az extension add --name customlocation --allow-preview true --only-show-errors
az extension update --name customlocation --allow-preview true --only-show-errors
Write-Host "Select a customlocation"
$customlocationID = Get-Option-Az $(az customlocation list --output json) "id"
az extension add --name akshybrid --allow-preview true --only-show-errors
az extension update --name akshybrid --allow-preview true --only-show-errors
az akshybrid vnet create -n $clustervnetname -g $resource_group --custom-location $customlocationID --moc-vnet-name $clustervnetname
#endregion