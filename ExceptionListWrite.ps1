$ErrorActionPreference="SilentlyContinue"

function main{
	# Default Location
	Set-Location -Path "C:\"
	
	# Generate user paths
	[string[]]$usersPaths = @()
	$usersPaths += "AppData\LocalLow\Sun\Java\Deployment\security\"
	$paths += getUserFilePaths -usersPaths $usersPaths
	
	# Program parameters
	[string]$filePath = "exception.sites"
	[string]$strException = "https://vpn.domain.com"
	
	# Add content to file
	foreach($path in $paths){
		
		# Test to see if "C:\Users\<username>\AppData\LocalLow\Sun\Java\Deployment\security" exists
		if(Test-Path $path){
			
			# Create the exceptions.sites file path
			$path = $path + $filePath
			
			# If the file is not there or the entry already exists, create/add it.  Otherwise, do nothing
			if(!((Get-Content $path) -contains $strException)){
				Out-File -Encoding Default -FilePath $path -Append -InputObject $strException
			}		
		}	
	}
	
	return 0
}

# Enumerate user specific paths
function getUserFilePaths{

	param(
		[string[]]$usersPaths
	)	

	# Set working directory
	Set-Location -Path "C:\Users"
	$users = Get-ChildItem . | Where-Object{$_.Attributes -like "*Directory*"}
	
	# Intialize output array
	[string[]]$paths = @()
	
	# Generate file paths
	foreach($user in $users){
		foreach($userPath in $usersPaths){
			$paths += "C:\Users\" + $user.Name + "\" + $userPath
		}
	}
	
	return $paths
}

main