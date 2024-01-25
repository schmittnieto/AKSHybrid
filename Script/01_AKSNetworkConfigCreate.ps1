#region Snippet 1: Functions
function Get-Option ($cmd, $filterproperty) {
  $items = @("")
  $selection = $null
  $filteredItems = @()
  $i = 0
  Invoke-Expression -Command $cmd | Sort-Object $filterproperty | ForEach-Object -Process {
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
    while ($null -eq $option -or $option -lt 1 -or $option -gt 2) {
        Write-Host "Invalid option. Please choose a valid option (1 or 2).                         " 
        Start-Sleep 3
        $option = & $giveMeNumber
    }
     switch ($option) {
      1 {$vlanId = Read-Host -Prompt 'he identification number of the VLAN in use. Every virtual machine is tagged with that VLAN ID.(Example: 3015)'}
      2 {Start-Sleep 1}
      }

New-ArcHciVirtualNetwork -name $clustervnetname -vswitchname $vswitchname -ipaddressprefix $ipaddressprefix -gateway $gateway -dnsservers $dnsServers -vippoolstart $vipPoolStart -vippoolend $vipPoolEnd -k8snodeippoolstart $vmPoolStart -k8snodeippoolend $vmPoolEnd -vlanID $vlanid

#endregion
