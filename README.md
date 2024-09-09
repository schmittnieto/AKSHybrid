# AKSHybrid (Outdated)
This is a repository that intends to automate and document the installation and management of AKS in Azure Stack HCI 23H2.
The scripts were developed for the first versions of 23H2 (2310 and 2311), with the current 2311.2 update several parts of the scripts have become obsolete and will be moved to 2311. 
Leaving the part of the code that still serves in the 23H2 section.


## Create AKS Using Azure Portal
Following the [MSLearn](https://learn.microsoft.com/en-us/azure/aks/hybrid/aks-create-clusters-portal) article, the AKS can be easily provisioned from the portal: 
![AKS on Azure Portal](https://learn.microsoft.com/en-us/azure/aks/hybrid/media/aks-create-clusters-portal/cluster-portal.png) 

From version 2311.2 onwards, Azure ARC Resource Bridge logical networks will be listed as networks to be used by AKS Hybrid.
So far I have only implemented it on static logical networks and not on DHCP networks.

Upon successful Deployment in all the tests I am performing, I will proceed to document the process in this section. 

## AKS Management Scripts
In this section I will collect the different scripts that I have been developing during the preview phase to manage hybrid AKS in Azure Stack HCI 23H2.
These are mostly based on az cli and the aksarc extension, which is available as [GA](https://learn.microsoft.com/en-us/cli/azure/aksarc?view=azure-cli-latest).
We currently require these scripts because these functions are not available on the portal. 
### Update Version from Kubernetes
In order to update the Kubernetes version we will use the script [AKSGetUpdates.ps1](Script/23H2/AKSGetUpdates.ps1), this script obtains a list of possible updates in the customlocation and then proceeds to update the selected cluster. 
### Enable or Disable Hybrid User Benefits
If you have the corresponding licence, you can make use of Hybrid User Benefits, currently I have developed two scripts to activate or deactivate it ( [AKSEnableAzureHybridUserBenefits.ps1](Script/23H2/AKSEnableAzureHybridUserBenefits.ps1) and [AKSDisableAzureHybridUserBenefits.ps1](Script/23H2/AKSDisableAzureHybridUserBenefits.ps1) ), in the future I will try to concentrate this work in a single script. 
### Create Service Barier Token for Management purposes 
In order to create a Service Barier token to manage kubernetes resources from the portal, we proceed to configure it following the [MSLearn](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/cluster-connect?tabs=azure-cli%2Cagent-version#service-account-token-authentication-option) article.
To do this we will use the [AKSServiceBarierToken.ps1](Script/23H2/AKSServiceBarierToken.ps1), which will create a connection to the cluster and then using Kubectl (Snippet 3.1) we will proceed to the automated configuration of the service barier token.
The prerequisite for this configuration is local access to the cluster, either via a VM in the cluster's network or via VPN.

# Changes of the 2311.2 version compared to previous versions
In this section I will list the advantages over the new deployment and the points that could be even better.
## Improvements of this version
- The AKS can be provisioned after the installation of Azure Stack HCI, entirely from the Azure portal without having to run scripts on it. 
- AKS makes use of the networks "Azure Stack HCI Logical network" instead of the networks "microsoft.hybridcontainerservice/virtualnetworks" which makes it easier to manage and provision, as the networks "Azure Stack HCI Logical network" show the network range and other characteristics (Gatway, DNS, IP Pools and VLANID).
- Provisioning AKS does not require a VM for the Loadbalancer as this is done from the Control Plane VM, consolidating functions and resources. 
- Load balancer management is done from the portal, thus having an overview of the IPs in use and being able to define which IPs are to be used for which purpose.
- By configuring the AKS network on one of the clusters, the cluster can provision Azure Arc Data controllers (a requirement for SQL Managed Instances). Something that was very tedious in the past is now very easy and comfortable. 
## Points for improvement 
- ~~When creating a new AKS, the default nodepool is called "namefromaks-nodepool1" and does not respect the nomenclature needed to create it (11 characters and no special characters).~~
- When implementing the networks (Loadbalancer) in the AKS, a azure provider (Microsoft.ArcNetworking and Microsoft.KubernetesRuntime) is required. It would be good if this could be introduced in the installation (or in the installation guide) of the HCI to prevent project delays.
- There is currently little or no documentation on the new provisioning. Or at least I have not been able to find any. 
- ~~The commands used so far (az akshybrid) do not work because they are based on the old "microsoft.hybridcontainerservice/virtualnetworks" networks.~~ Resolved with implementation from az aksarc.
- In the network section of the AKS it is possible to find IPs of loadbalancers from other AKS that are in other logical networks but in the same network segment. I have yet to test if it is also possible to see them if they are on another network segment.
- When configuring Azure Arc Data Controller on an AKS with a default nodepool size (A4_v2), I am allowed to install it but the pods throw an error due to lack of RAM. In any article I have been able to see the minimum requirements to make use of the Data Controller. By increasing the RAM, the Data Controller can be provisioned correctly. 
- ~~I'm experiencing some issues by deleting clusters (it generate phantom resources in Azure).~~
- ~~Currently I have not been able to deploy kubernetes version 1.25.6 and the provisioning status remains at: Failed. This does not affect versions 1.26.6 and 1.27.1.~~
- It is not possible to view the IP and Count of the Control Plane from the Portal.
# Disclaimer 
- This is not official Microsoft documentation or software.
- This sample is not supported under any Microsoft standard support program or service.
- In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the script be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample or documentation, even if Microsoft has been advised of the possibility of such damages.
- This is a personal project derived from the need to carry out certain tasks after the HCI Deployment, which takes up the process in an automated way. I am not responsible for any error caused by this script or any future failure of it.
