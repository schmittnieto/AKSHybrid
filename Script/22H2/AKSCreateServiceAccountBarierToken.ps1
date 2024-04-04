#region Snippet 1: Functions Get-Option helper function to provide menu
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
#endregion
#region Snippet 2: Create Service Barier Token
$AKSCluster = Get-Option "Get-AksHciCluster" "Name"
$AdminUser = Read-Host -Prompt 'Input the user name'
$YamlSecret = "$AdminUser-user-secret.yaml"
Get-AksHciCredential -Name $AKSCluster
Set-Location $env:USERPROFILE"\.kube"
kubectl create serviceaccount $AdminUser -n default 
kubectl create clusterrolebinding "$Adminuser-binding" --clusterrole cluster-admin --serviceaccount default:$AdminUser
New-Item $YamlSecret
"apiVersion: v1
kind: Secret
metadata:
  name: $AdminUser-secret
  annotations:
    kubernetes.io/service-account.name: $AdminUser
type: kubernetes.io/service-account-token" | Out-File $YamlSecret
kubectl apply -f $YamlSecret
$TOKEN = ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl get secret "$AdminUser-secret" -o jsonpath='{$.data.token}'))))
$TOKEN
$TOKEN | Out-File $AdminUser-Secret-Token.txt
#endregion
  
  