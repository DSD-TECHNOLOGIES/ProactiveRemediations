# ProactiveRemediations

Scripts for use with Microsoft Endpoint Managers Proactive Remediation feature

# BannedTaskbarPins
Proactive Remediation to detect and remove Windows Taskbar pins based on a banlist 
* Detection script: Yes
* Remediation script: Yes
* Run this script using the logged-on credentials: Yes
* Enforce script signature check: No
* Run script in 64-bit PowerShell: Yes

## Get-BannedTaskbarPins.ps1
Detects pinned items from the $banlist

## Set-BannedTaskbarPins.ps1
Unpins items from the $banlist

# BatteryCompliance
Proactive Remediation to detect battery lifecycle and chemistry compliance
* Detection script: Yes
* Remediation script: No
* Run this script using the logged-on credentials: No
* Enforce script signature check: No
* Run script in 64-bit PowerShell: No

## Get-BatteryCompliance.ps1
Gets battery lifecycle values and chemistry types based on $BatteryCapacityTarget and $ChemistryTypesToAvoid

