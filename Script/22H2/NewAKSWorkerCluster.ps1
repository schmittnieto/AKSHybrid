#region Snippet 1: Functions: Get-Option helper function to provide menu
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
#region Snippet 2: Create New Cluster Network and New AKS Cluster
##Network Deployment 
#https://learn.microsoft.com/en-us/azure/aks/hybrid/reference/ps/new-akshciclusternetwork
#$vnet = New-AksHciClusterNetwork -name <String> -vswitchName <String> -gateway <String> -dnsServers <String[]> -ipAddressPrefix <String> -vipPoolStart <IP address> -vipPoolEnd <IP address> -k8sNodeIpPoolStart <IP address> -k8sNodeIpPoolEnd <IP address> -vlanID <int>

##AKS Worker Cluster Deployment
#https://learn.microsoft.com/de-de/azure/aks/hybrid/reference/ps/new-akshcicluster
#New-AksHciCluster -name mycluster -controlPlaneVmSize Standard_D4s_v3 -loadBalancerVmSize Standard_A4_v2 -nodePoolName nodepool1 -nodeCount 3 -nodeVmSize Standard_D8s_v3

#endregion