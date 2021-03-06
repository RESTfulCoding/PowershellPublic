##### Global Variables

# Network hash table for gateway to file share detection.
$networks = @{"10.*.*.*" = "\\server01\ldshare\software";
              "10.*.*.*" = "\\server02\ldshare\software";
              "10.*.*.*" = "\\server03\ldshare\software";
              "10.*.*.*" = "\\server04\ldshare\software";
              "10.*.*.*" = "\\server05\ldshare\software";
              "10.*.*.*" = "\\server06\ldshare\software"
             }

# Network credentials (note $ symbols are escaped with `)
[string]$credSAUsername = "domain\serviceaccount"
[string]$credSAPassword = "password"

# Create variable for OS build version
$OSVersion = Get-WmiObject -Class Win32_OperatingSystem


function main{
  aq1
    # Setup the environment
    set-env
    
	# Install applications
		
		# Disable OneDrive - OneDrive is not uninstalled during this process
		if($OSVersion.BuildNumber -eq "10240"){
			
			# Create registry key OneDrive and DWord DisableFilesSyncNGSC to disable OneDrive
			New-Item -Path HKLM:"\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name OneDrive -Force
			New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -PropertyType DWord -Value 1 -Force
		}
		
        # LANDesk Agent
		$LANDeskAgents = @()
		$LANDeskAgents += (ls "Z:\LANDesk\Agents\" | Where-Object{$_.Name -match ".*.exe"} | sort -property "CreationTime" -Descending)
        New-Item "C:\Windows\Temp\LANDesk" -ItemType Directory -Force
        Copy-Item -Path $LANDeskAgents[0].FullName -Destination "C:\Windows\Temp\LANDesk" -Force -PassThru -Recurse 

        [string]$LANDeskRun = "C:\Windows\Temp\LANDesk\" + $LANDeskAgents[0].Name
		New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "00_LANDeskAgent" -PropertyType String -Value $LANDeskRun -Force
				
		# .NET Framework 4.5
        $dotNET = @()
		$dotNET += (ls "Z:\Microsoft\dotNETFramework\" | Where-Object{$_.Name -match ".*.exe"} | sort -property "CreationTime" -Descending)
        New-Item "C:\Windows\Temp\dotNet" -ItemType Directory -Force
        Copy-Item -Path $dotNET[0].FullName -Destination "C:\Windows\Temp\dotNet" -Force -PassThru -Recurse

        [string]$dotNETRun = "`"C:\Windows\Temp\dotNet\" + $dotNET[0].Name + "`" /passive /norestart"
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "01_dotNETFramework" -PropertyType String -Value $dotNETRun -Force
        		        
        # Kaspersky
        $kaspersky = @()
		$kaspersky += (ls "Z:\Kaspersky\KasperskySysprep\" | Where-Object{$_.Name -match ".*.exe"} | sort -property "CreationTime" -Descending)
        New-Item "C:\Windows\Temp\Kaspersky" -ItemType Directory -Force
        Copy-Item -Path $kaspersky[0].FullName -Destination "C:\Windows\Temp\Kaspersky" -Force -PassThru -Recurse
			
		[string]$kasperskyRun = "`"C:\Windows\Temp\Kaspersky\" + $kaspersky[0].Name + "`" /s"
		New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "02_Kaspersky" -PropertyType String -Value $kasperskyRun -Force
        
        # Lenovo HotKey
        New-Item "C:\Windows\Temp\LenovoHotKey" -ItemType Directory -Force
        Copy-Item -Path "Z:\Lenovo\Hotkeys\*" -Destination "C:\Windows\Temp\LenovoHotKey" -Force -PassThru -Recurse
        
        [string]$hotKeyRun = "`"C:\Windows\Temp\LenovoHotKey\" + $hotKey[0].Name + "`" /SP- /SILENT /NORESTART /SUPPRESSMSGBOXES"
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "03_LenovoHotKey" -PropertyType String -Value $hotKeyRun -Force
        
        # BluTooth Win 7
        New-Item "C:\Windows\Temp\BluToothWin7" -ItemType Directory -Force
        Copy-Item -Path "Z:\Lenovo\BluToothWin7\*" -Destination "C:\Windows\Temp\BluToothWin7" -Force -PassThru -Recurse
        
        [string]$bluToothRun = "C:\Windows\Temp\BluToothWin7\setup.exe /qn /norestart"
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "04_BluToothRun" -PropertyType String -Value $blueToothRun -Force
        
        
        
        # MBAM
        if(is64){Start-Process -FilePath "Z:\Microsoft\BitLocker2.0\MBAMClient.msi" -ArgumentList "/qb" -Wait -PassThru}
        else{Start-Process -FilePath "Z:\Microsoft\BitLocker2.0\MBAMClient_x86.msi" -ArgumentList "/qb" -Wait -PassThru}

        # Pulse Secure
        if(is64){
            Start-Process -FilePath "Z:\PulseSecure\ps-pulse-win-5.1r5.0-b60701-64bitinstaller.msi" -ArgumentList "/qb REBOOT=ReallySuppress" -Wait -PassThru
            Remove-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "PulseSecure"
        }
        
        # Office
        if(is64){Start-Process -FilePath "Z:\Microsoft\MSOfficeProPlus2016x64\setup.exe" -Wait -PassThru}
        
        # Adobe Reader XI
        Start-Process -FilePath "Z:\Adobe\AdobeReaderDC\AcroRead.msi" -ArgumentList "/qb REBOOT=ReallySuppress TRANSFORMS=AcroRead.mst" -Wait -PassThru
        Start-Process -FilePath "Z:\Adobe\AdobeReaderDC\AcroRdrDCUpd1500820082.msp" -ArgumentList "REINSTALLMODE=omus REINSTALL=ALL REBOOT=ReallySuppress /qb /L*V C:\Windows\Logs\AcroRdrDCUpd1500820082.log" -Wait -PassThru

        # HipChat
        Start-Process -FilePath "Z:\Atlassian\HipChat\HipChat.exe" -ArgumentList "/SP- /SILENT /NORESTART /SUPPRESSMSGBOXES" -Wait -PassThru
		
        # Java Runtime
		    # x64
            if(is64){Start-Process -FilePath "Z:\Oracle\JREx64\jre-8u102-windows-x64.exe" -ArgumentList "/s" -Wait -PassThru}
        
        # Chrome
        Start-Process -FilePath "Z:\Google\Chrome\setup.exe" -ArgumentList "/install" -Wait -PassThru
        Stop-Process -Name "chrome"

        # Firefox
        Start-Process -FilePath "Z:\Mozilla\Firefox\setup.exe" -ArgumentList "-ms" -Wait -PassThru

        # Internet Explorer 11
		if((($OSVersion.BuildNumber -eq "7601") -or ($OSVersion.BuildNumber -eq "9600")) -and (is64)){
			Start-Process -FilePath "Z:\Microsoft\MSInternetExplorer11\IE11-Windows6.1-x64-en-us.exe" -ArgumentList "/passive /norestart" -Wait -PassThru
		}
			
        elseif(($OSVersion.BuildNumber -eq "7601") -or ($OSVersion.BuildNumber -eq "9600")){
			Start-Process -FilePath "Z:\Microsoft\MSInternetExplorer11\IE11-Windows6.1.exe" -ArgumentList "/passive /norestart" -Wait -PassThru
		}
		
		# CrashPlan
        if(is64){
			Start-Process -FilePath "Z:\Code42\CrashPlanPROe\CrashPlanPROe-x64_Win.msi" -ArgumentList "/qb! REBOOT=ReallySuppress /L*V C:\Windows\Temp\CrashPlanPROe_4.6.0.log" -Wait -PassThru
			Stop-Process -Name "CrashPlanDesktop"
		}
        
        # Enable Telnet
        dism /online /Enable-Feature /Featurename:TelnetClient /NoRestart
	
     # Install manufacturer specific software
	
		# Dell Inc.
		if((get-manufacturer) -eq "Dell Inc."){
			
			# Install 1
		}
		
		# LENOVO
		if((get-manufacturer) -eq "LENOVO"){
			# All OSes
                #Hotkeys
                #Start-Process -FilePath "Z:\Lenovo\HotKeys\Setup.exe" -ArgumentList "/SP- /SILENT /NORESTART /SUPPRESSMSGBOXES" -Wait -PassThru

            # For Windows 10
			if(($OSVersion.BuildNumber -eq "10240") -or ($OSVersion.BuildNumber -eq "9600")){
			}
			# For Windows 7
			elseif($OSVersion.BuildNumber -eq "7601"){	
				# HotFix KB2459268
				New-Item "C:\Windows\Temp\Lenovo\KBHotFix" -ItemType Directory -Force
				Copy-Item -Path "Z:\Lenovo\KBHotFix\windows6.1-kb2459268-x64.msu" -Destination "C:\Windows\Temp\Lenovo\KBHotFix" -Force -PassThru -Recurse
	
                # Stop error in Windows 7 when the computer enters or resumes from the Soft Off (S5) power state.
				[string]$KB2459268Run = "`"C:\Windows\Temp\Lenovo\KBHotFix\windows6.1-kb2459268-x64.msu`" /quiet /norestart"
				New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "05_KB2459268" -PropertyType String -Value $KB2459268Run -Force

                # BluTooth Installer
                # Start-Process -FilePath "Z:\Lenovo\T460pBlueTooth\setup.exe" -ArgumentList "/qn /norestart" -Wait -PassThru   
			}
		}	

        # Wacom Co.,Ltd
		if((get-manufacturer) -eq "Wacom Co.,Ltd"){
			
			Start-Process -FilePath "Z:\Wacom\Setup.exe" -ArgumentList "/S" -Wait -PassThru
		}

    # Shutdown services
    
        # Service cmd
        # Stop-Service -Name
        
        
        # Service 2 
        # Stop-Service -Name 
    
    # Cleanup
	clean-env

    # Done
    return 0
}

##### set-env
    # Setup the environment.
    # return null
function set-env{

    # Get host's default gateway
	$strGateway = Get-WmiObject -Class Win32_IP4RouteTable | 
                          where { $_.destination -eq '0.0.0.0' -and $_.mask -eq '0.0.0.0'} | 
                          Sort-Object metric1 | select nexthop, metric1, interfaceindex
 
    [string]$strGateway = $strGateway.nexthop
 
    # Mount network shares
    [string]$strShare = $networks.Get_Item($strGateway)
    $smb = new-object -ComObject WScript.Network
    $smb.MapNetworkDrive("Z:", $strShare, $false, $credSAUsername, $credSAPassword)

	# Turn off UAC
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system" -Name EnableLUA -PropertyType DWord -Value 0 -Force
	
	# Turn on Aero
	if($OSVersion.BuildNumber -ne "10240"){	
		reg load "HKLM\Default" "C:\Users\Default\NTUSER.dat"

		New-PSDrive -Name HKDU -PSProvider Registry -Root "HKLM:\Default"
		New-ItemProperty -Path "HKLM:\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "00_Theme" -PropertyType String -Value "C:\Windows\Resources\Themes\aero.theme" -Force

		Remove-PSDrive HKDU
		reg unload "HKLM\Default"
		[gc]::collect()
	}
	
	# Turn off Zone Checks
	$Env:SEE_MASK_NOZONECHECKS = 1
}

##### clean-env
    # Cleanup the environment.
    # return null
function clean-env{

    # Unmount network drive
    $smb = new-object -ComObject WScript.Network
    $smb.RemoveNetworkDrive("Z:")

	# Turn on Zone Checks
	$Env:SEE_MASK_NOZONECHECKS = 0

    # Delete 'DRIVERS' directory
    # New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "DelDriversdir" -PropertyType String -Value "powershell.exe -command `"Remove-Item -Recurse -Force -Path C:\DRIVERS`"" -Force
}

##### get-manufacturer
    # return the local host's manufacturer as string. 
    # return string
function get-manufacturer{

    [string]$manufacturer = (Get-WmiObject Win32_ComputerSystem).Manufacturer
                            
    return $manufacturer 

}


##### get-systemType
    # return the local host's system type as string. 
    # return string
function is64{

    [string]$systemType = (Get-WmiObject Win32_ComputerSystem).SystemType

    if($systemType -eq "x64-based PC"){
        return $true
    }
    else{
        return $false
    }
}

main