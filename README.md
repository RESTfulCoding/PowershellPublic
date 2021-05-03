# PowershellPublic
# Adversaries.ps1
The Adversaries.ps1 script was written to look for suspicious files on Windows 10 endpoints.
I emphasize this script alone due to its complexity and urgent need for completiona and rollout.
The script recursed through all of the existing user profiles on a Windows 7/10 machine whether users were currently logged in or not.
Registry keys were also recursed.
Regex queries were used and the results were put into an array.

If any results were returned, they were written to the registry. LANDesk attributes for the client were modified to look for values under this particular key and report back to LANDesk. These results can then be exported as a .csv and reviewed.

# Patch Management
This patch management strategy was a temporary solution until the business agreed upon a long term plan.

# UnattendInstall.ps1
In WDS, this script is called from an unattend.xml file on the .wim image.
Existing on a local server, any imaging performed across the globe calls this file which in turn finds the closest application server listed in the hash table.
Location of the application server is determined through the IP4 route table which is the focus in this script:

    Get host's default gateway
	  $strGateway = Get-WmiObject -Class Win32_IP4RouteTable | 
                          where { $_.destination -eq '0.0.0.0' -and $_.mask -eq '0.0.0.0'} | 
                          Sort-Object metric1 | select nexthop, metric1, interfaceindex
 
    [string]$strGateway = $strGateway.nexthop
 
    # Mount network shares
    [string]$strShare = $networks.Get_Item($strGateway)
    $smb = new-object -ComObject WScript.Network
    $smb.MapNetworkDrive("Z:", $strShare, $false, $credSAUsername, $credSAPassword)
