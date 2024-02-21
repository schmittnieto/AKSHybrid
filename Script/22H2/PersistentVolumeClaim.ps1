#region Snippet 1: Functions Get-Option helper function to provide menu
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
  #region Snippet 2: Create Service Barier Token
  $AKSCluster = Get-Option "Get-AksHciCluster" "Name"
  $PerStorageName = Read-Host -Prompt 'Input the persistent storage name'
  $PerStorageCapacity = Read-Host -Prompt 'Input the persistent storage Capacity (Gi) in Numbers: f.E. "10"'
  $Yaml = "$AKSCluster$PerStorageName.yaml"
  Get-AksHciCredential -Name $AKSCluster
  New-Item $Yaml
  "apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
   name: $PerStorageName
  spec:
   accessModes:
   - ReadWriteOnce
   resources:
    requests:
     storage: $PerStorageCapacity`Gi " | Out-File $Yaml

  kubectl create -f $Yaml

  #endregion
  
  