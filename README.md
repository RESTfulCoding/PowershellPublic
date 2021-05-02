# PowershellPublic
The Adversaries.ps1 script was written to look for suspicious files on Windows 10 endpoints.
I emphasize this script alone due to its complexity and urgent need for completiona and rollout.
The script recursed through all of the existing user profiles on a Windows 7/10 machine whether users were currently logged in or not.
Registry keys were also recursed.
Regex queries were used and the results were put into an array.

If any results were returned, they were written to the registry. LANDesk attributes for the client were modified to look for values under this particular key and report back to LANDesk. These results can then be exported as a .csv and reviewed.
