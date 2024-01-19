# AKSHybrid
This is a repository that intends to automate and document the installation and management of AKS in Azure Stack HCI 23H2.

## Functions
The scripts make use of functions and derivations of functions, which have been created or modified simply to facilitate the implementation of the AKS.
The authorship of these functions will be exposed in these functions.
 - Get-Option
    - Authorship 
        - [@bfrankMS](https://github.com/bfrankMS)
        - [From Script](https://github.com/bfrankMS/AzStackHCI/blob/main/AKS/AKS%2BARB.ps1)
    - Function to provide menu to select result
    - Usage Example
        - `$vswitchname = Get-Option "Get-VMSwitch -SwitchType External" "Name"`
 - Get-Option-Az
    - Authorship
        - @Schmittnieto
    - Modification from Get-Option for AZ CLI
    - Usage Example
        - `$customlocationID = Get-Option-Az $(az customlocation list --output json) "id"`

## Network Configuration
In order to deploy AKS on Azure Stack HCI 23H2, a network needs to be configured using "New-ArcHciVirtualNetwork" and registered using "az akshybrid vnet create".

The network configuration is done based on the following article [Create networks for AKS](https://learn.microsoft.com/en-us/azure/aks/hybrid/aks-networks/).

For this purpose, the script [AKSNetworkConfig.ps1](Script/AKSNetworkConfig.ps1) is used, which will be used with Snippet 2 on the Host and with Snippet 3 from any administrative machine (not from the cluster).

## Create AKS Using Azure Portal
Following the [MSLearn](https://learn.microsoft.com/en-us/azure/aks/hybrid/aks-create-clusters-portal) article, the AKS can be easily provisioned from the portal: 
![AKS on Azure Portal](https://learn.microsoft.com/en-us/azure/aks/hybrid/media/aks-create-clusters-portal/cluster-portal.png) 

# Disclaimer 
- This is not official Microsoft documentation or software.
- This sample is not supported under any Microsoft standard support program or service.
- In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the script be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample or documentation, even if Microsoft has been advised of the possibility of such damages.
- This is a personal project derived from the need to carry out certain tasks after the HCI Deployment, which takes up the process in an automated way. I am not responsible for any error caused by this script or any future failure of it.
