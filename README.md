# AKSHybrid
This is a repository that intends to automate and document the installation and management of AKS in Azure Stack HCI 23H2.
The scripts were developed for the first versions of 23H2 (2310 and 2311), with the current 2311.2 update several parts of the scripts have become obsolete and will be moved to 2311. 
Leaving the part of the code that still serves in the 23H2 section.


## Create AKS Using Azure Portal
Following the [MSLearn](https://learn.microsoft.com/en-us/azure/aks/hybrid/aks-create-clusters-portal) article, the AKS can be easily provisioned from the portal: 
![AKS on Azure Portal](https://learn.microsoft.com/en-us/azure/aks/hybrid/media/aks-create-clusters-portal/cluster-portal.png) 

From version 2311.2 onwards, Azure ARC Resource Bridge logical networks will be listed as networks to be used by AKS Hybrid.
So far I have only implemented it on static logical networks and not on DHCP networks.

## Create Service Barier Token for Management purposes 
In order to create a Service Barier token to manage kubernetes resources from the portal, we proceed to configure it following the [MSLearn](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/cluster-connect?tabs=azure-cli%2Cagent-version#service-account-token-authentication-option) article.
To do this we will use the [AKSServiceBarierToken.ps1](Script/03_AKSServiceBarierToken.ps1), which will create a connection to the cluster and then using Kubectl (Snippet 3.1) we will proceed to the automated configuration of the service barier token.
The prerequisite for this configuration is local access to the cluster, either via a VM in the cluster's network or via VPN.

## Create SQL Managed Instance
https://learn.microsoft.com/en-us/azure/azure-arc/data/create-data-controller-direct-azure-portal
I am currently trying to create a script to automate the process, but compared to Deployment from the portal, it doesn't make sense to deploy via script. 


# Disclaimer 
- This is not official Microsoft documentation or software.
- This sample is not supported under any Microsoft standard support program or service.
- In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the script be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample or documentation, even if Microsoft has been advised of the possibility of such damages.
- This is a personal project derived from the need to carry out certain tasks after the HCI Deployment, which takes up the process in an automated way. I am not responsible for any error caused by this script or any future failure of it.
