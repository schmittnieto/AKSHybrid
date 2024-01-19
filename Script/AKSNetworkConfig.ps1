#region Snippet 1: Functions
function Get-Option ($cmd, $filterproperty) {
    $items = @("")
    $selection = $null
    $filteredItems = @()
    Invoke-Expression -Command $cmd | Sort-Object $filterproperty | ForEach-Object -Begin { $i = 0 } -Process {
      $items += "{0}. {1}" -f $i, $_.$filterproperty
      $i++
    } 
    $filteredItems += $items | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $filteredItems | Format-Wide { $_ } -Column 4 -Force | Out-Host
    #$filteredItems.Count
    #$filteredItems | Out-Host
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
  function Get-Option-Az ($azcmd, $filterproperty) {
    # Usage: $rg = Get-Option-Az $(az group list --output json --all) "name"
    # This function is similar to the Get-Option function, but uses the az cli instead of Invoke-Expression.
    $items = @("")
    $selection = $null
    $filteredItems = @()
    # Execute az cli command and convert JSON output to PowerShell objects.
    $result = $azcmd | ConvertFrom-Json
    # Sorts the objects by the filter property and adds them to the element array
    $result | Sort-Object $filterproperty | ForEach-Object -Begin { $i = 0 } -Process {
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

#region Snippet 2: Network Configuration on HCI Host   
  Write-Host = "Select External Switch for AKS"
  $vswitchname = Get-Option "Get-VMSwitch -SwitchType External" "Name"
  $clustervnetname = Read-Host -Prompt 'Input the name for AKS Cluster VNET (Example: prodaksclust)'
  $ipaddressprefix = Read-Host -Prompt 'Input the Networkprefix (Example: 192.168.1.0/24)'
  $gateway = Read-Host -Prompt 'Input the Gateway (Example: 192.168.1.1)'
  $dnsservers = Read-Host -Prompt 'Input the DNS Server for AKS if more than 2 use "" and separated with , (Example: "192.168.1.10", "192.168.1.11")'
  $vmPoolStart = Read-Host -Prompt 'The start IP address of your VM IP pool. The address must be in range of the subnet (Example: 192.168.1.50)'
  $vmPoolEnd = Read-Host -Prompt 'The end IP address of your VM IP pool. The address must be in range of the subnet (Example: 192.168.1.60)'
  $vipPoolStart = Read-Host -Prompt 'The start IP address of the VIP pool. The address must be within the range of the subnet. The IP addresses in the VIP pool are for the API server and for Kubernetes services (Example: 192.168.1.61)'  
  $vipPoolEnd	= Read-Host -Prompt 'The end IP address of the VIP pool (Example: 192.168.1.70)'
  Write-Host "Do you want to use VLANs?  Please select number (1 or 2)             " 
  Write-Host "1. Yes                                                            " 
  Write-Host "2. No               " 
  $giveMeNumber = {
        try {
          [int]$option = Read-Host
          return $option
        }
        catch {
          Write-Output "Your input is not a valid number."
          return $null
        }
      }
      $option = & $giveMeNumber
      while ($option -eq $null -or $option -lt 1 -or $option -gt 2) {
          Write-Host "Invalid option. Please choose a valid option (1 or 2).                         " 
          sleep 3
          $option = & $giveMeNumber
      }
       switch ($option) {
        1 {$vlanId = Read-Host -Prompt 'he identification number of the VLAN in use. Every virtual machine is tagged with that VLAN ID.(Example: 3015)'}
        2 {sleep 1}
        }
  
  New-ArcHciVirtualNetwork -name $clustervnetname -vswitchname $vswitchname -ipaddressprefix $ipaddressprefix -gateway $gateway -dnsservers $dnsServers -vippoolstart $vipPoolStart -vippoolend $vipPoolEnd -k8snodeippoolstart $vmPoolStart -k8snodeippoolend $vmPoolEnd -vlanID $vlanid
  
#endregion

#region Snippet 3: Connect the Network to Azure (it need to run externaly, not on the cluster)
az login --use-device-code
# take the same name as you used on Snippet 2
$clustervnetname = "testaksvnet"
Write-Host "Select a resource Group"
$resource_group = Get-Option-Az $(az group list --output json) "name"
Write-Host "Select a customlocation"
$customlocationID = Get-Option-Az $(az customlocation list --output json) "id"
az extension add --name akshybrid --allow-preview true
az akshybrid vnet create -n $clustervnetname -g $resource_group --custom-location $customlocationID --moc-vnet-name $clustervnetname
#endregion