# 2311
These scripts were designed for the 2311 version and were deprecated with the 2311.2 version. 
If you want to configure AKS hybrid in the current version, go to the main section of the repository.
The scripts will remain in the repository as documentation. 

## Network Configuration
In order to deploy AKS on Azure Stack HCI 23H2, a network needs to be configured using "New-ArcHciVirtualNetwork" and registered using "az akshybrid vnet create".

The network configuration is done based on the following article [Create networks for AKS](https://learn.microsoft.com/en-us/azure/aks/hybrid/aks-networks/).

For this purpose, the script [AKSNetworkConfigCreate.ps1](Script/01_AKSNetworkConfigCreate.ps1) is used for AKS Network Creation on the Cluster Host and the script [AKSNetworkConfigConnect.ps1](Script/02_AKSNetworkConfigConnect.ps1) is used for Network Connection over Az CLI on a Administrative VM (shouldn't run on the Cluster Host).

## Create SQL Managed Instance
https://learn.microsoft.com/en-us/azure/azure-arc/data/create-data-controller-direct-azure-portal
I am currently trying to create a script to automate the process, but compared to Deployment from the portal, it doesn't make sense to deploy via script. 

# Disclaimer 
- This is not official Microsoft documentation or software.
- This sample is not supported under any Microsoft standard support program or service.
- In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the script be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample or documentation, even if Microsoft has been advised of the possibility of such damages.
- This is a personal project derived from the need to carry out certain tasks after the HCI Deployment, which takes up the process in an automated way. I am not responsible for any error caused by this script or any future failure of it.
