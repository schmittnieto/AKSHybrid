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
#region Snippet 2: Modification from NodePool (VM Size and Node Count)

## Get AKS Cluster
Write-Host "Select AKS Cluster:" -ForegroundColor Green
$AKSCluster = Get-Option "Get-AksHciCluster" "Name"

## Select Node Pool
Write-Host "Select AKS Cluster Nodepool:" -ForegroundColor Green
$AKSNodepool = Get-Option "Get-AksHCiNodePool -clusterName $AKSCluster" "NodePoolName"

## Node Count
$AKSNodepoolCount = (Get-AksHCiNodePool -clusterName $AKSCluster).NodeCount
Write-Host "Actually Node count on node pool $AKSNodepool : $AKSNodepoolCount " -ForegroundColor Green

Write-Host "Do you want to use Modify the node count on Node Pool $AKSNodepool?" 
  Write-Host "1. Yes" 
  Write-Host "2. No" 
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
          Write-Host "Invalid option. Please choose a valid option (1 or 2)" 
          Start-Sleep 3
          $option = & $giveMeNumber
      }
       switch ($option) {
        1 {
            [int]$AKSNodepoolCount = Read-Host "Introduce new nodepool node counter"
        }
        2 {
            $AKSNodepoolCount = (Get-AksHCiNodePool -clusterName $AKSCluster).NodeCount
        }
        }

## VM Size

$AKSNodepoolVMSize = (Get-AksHCiNodePool -clusterName $AKSCluster).VmSize
Write-Host "Actually VMSize on node pool $AKSNodepool : $AKSNodepoolVMSize"
Start-Sleep 2


Write-Host "Do you want to use Modify VM Size on Node Pool?" 
  Write-Host "1. Yes" 
  Write-Host "2. No" 
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
          Write-Host "Invalid option. Please choose a valid option (1 or 2)" 
          Start-Sleep 3
          $option = & $giveMeNumber
      }
       switch ($option) {
        1 {
            ## Get AKS VM Sizes
            Write-Host "Posible AKS VM Sizes:" -ForegroundColor Green
            Get-AksHciVmSize
            Start-Sleep 2
            Write-Host "Select New AKS VM Size:" -ForegroundColor Green
            $AKSVMSize = Get-Option "Get-AksHciVmSize" "VmSize"
        }
        2 {
            $AKSVMSize = (Get-AksHCiNodePool -clusterName $AKSCluster).VmSize
        }
        }
  


## Set AKS HCI Node Pool
Set-AksHciNodePool -clusterName $AKSCluster -name $AKSNodepool -vmsize $AKSVMSize -count $AKSNodepoolCount
#endregion