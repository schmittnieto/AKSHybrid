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
#region Snippet 2: Requierements: Winget, Az CLI and kubectl

<# Installing Winget (https://stackoverflow.com/questions/74166150/install-winget-by-the-command-line-powershell)
# get latest download url 
$URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$URL = (Invoke-WebRequest -Uri $URL).Content | ConvertFrom-Json |
        Select-Object -ExpandProperty "assets" |
        Where-Object "browser_download_url" -Match '.msixbundle' |
        Select-Object -ExpandProperty "browser_download_url"

# download
Invoke-WebRequest -Uri $URL -OutFile "Setup.msix" -UseBasicParsing

# install
Add-AppxPackage -Path "Setup.msix"

# delete file
Remove-Item "Setup.msix"

#restart powershell
exit

#>


<# Install Az CLI
Write-Host "Installing AzCLI....                                                           " 
    start-bitstransfer https://aka.ms/installazurecliwindows ".\AzureCLI.msi" -Priority High -RetryInterval 60  -Verbose -SecurityFlags 0,0,0 -TransferPolicy Always #faster
    Msiexec.exe /i AzureCLI.msi /qn
    #sleep 40 (it takes 1 minute for installation),

#restart powershell
exit

# Install az extension
az extension add --name connectedk8s --only-show-errors

#>


<# Install Kubectl
winget install -e --id Kubernetes.kubectl

#restart powershell
exit

#>
#endregion
#region Snippet 3: Creating Service Barier Token
#region 3.1: Starting Proxy for AKS
#az login
Write-Host "Select the AKS Subscription" -ForegroundColor Green
$AZsubscription = Get-Option-Az $(az account list --output json) "name"
az account set --name $AZsubscription
Write-Host "Select the AKS Resource Group" -ForegroundColor Green
$resource_group = Get-Option-Az $(az group list --output json) "name"
Write-Host "Select the AKS Cluster" -ForegroundColor Green
$AKSCluster = Get-Option-Az $(az resource list -g $resource_group --resource-type "Microsoft.Kubernetes/connectedClusters" --output json) "name"
Write-Host "Generating Kubectl" -ForegroundColor Green
az connectedk8s proxy -n $AKSCluster -g $resource_group --file .\aks-arc-kube-config
#endregion

#region 3.1: Generating the service barier token (in New Powershell tab)
cd $env:USERPROFILE"\.kube"
Write-Host "Testing aks cluster connection" -ForegroundColor Green
kubectl get node -A --kubeconfig .\aks-arc-kube-config

$AdminUser = Read-Host -Prompt 'Input the user name for Service Barier Token'
$YamlSecret = "$AdminUser-user-secret.yaml"
Get-AksHciCredential -Name $AKSCluster
kubectl create serviceaccount $AdminUser -n default --kubeconfig .\aks-arc-kube-config
kubectl create clusterrolebinding "$Adminuser-binding" --clusterrole cluster-admin --serviceaccount default:$AdminUser --kubeconfig .\aks-arc-kube-config
New-Item $YamlSecret
"apiVersion: v1
kind: Secret
metadata:
  name: $AdminUser-secret
  annotations:
    kubernetes.io/service-account.name: $AdminUser
type: kubernetes.io/service-account-token" | Out-File $YamlSecret
kubectl apply -f $YamlSecret --kubeconfig .\aks-arc-kube-config
$TOKEN = ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl get secret "$AdminUser-secret" --kubeconfig .\aks-arc-kube-config -o jsonpath='{$.data.token}'))))
$TOKEN
$TOKEN | Out-File $AdminUser-Secret-Token.txt
#endregion
#endregion
 