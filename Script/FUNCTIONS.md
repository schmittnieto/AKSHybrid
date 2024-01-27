# Functions
The scripts make use of functions and derivations of functions, which have been created or modified simply to facilitate the implementation of the AKS.
The authorship of these functions will be exposed in these functions.
 - Get-Option
    - SourceCode
        - [From Script](https://github.com/bfrankMS/AzStackHCI/blob/main/AKS/AKS%2BARB.ps1)
    - Function to provide menu to select result
    - Usage Example
        - `$vswitchname = Get-Option "Get-VMSwitch -SwitchType External" "Name"`
 - Get-Option-Az
    - Modification from Get-Option for AZ CLI
    - Usage Example
        - `$customlocationID = Get-Option-Az $(az customlocation list --output json) "id"`
    - You can see more examples of it on the following script: [Get-Option-Az.ps1](/Script/Get-Option-Az.ps1)

# Disclaimer 
- This is not official Microsoft documentation or software.
- This sample is not supported under any Microsoft standard support program or service.
- In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the script be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample or documentation, even if Microsoft has been advised of the possibility of such damages.
- This is a personal project derived from the need to carry out certain tasks after the HCI Deployment, which takes up the process in an automated way. I am not responsible for any error caused by this script or any future failure of it.
