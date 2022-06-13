<#
Author: DSD-TECH
Script: Get Battery Compliance
Descri: Gets battery lifecycle values and chemistry types
Versio: 1.00

## Chemistry Types ##
'Other'
    Unknown
'Unknown'
    Unknown
'Lead Acid';
    Environmental hazard due to Lead.
'Nickel Cadmium';
    Environmental hazard due to Cadmium - prohibited in Europe.
'Nickel Metal Hydride';
    Environmental hazrd due to Nickel
'Lithium-ion';
    Environmental hazard due to mining - Industry Standard
'Zinc air';
    Environmental hazard due to potential mercury
'Lithium Polymer';
    Environmental hazard due to mining 
#>

[int]$BatteryCapacityTarget = 65 #Compliance Target
[array]$ChemistryTypesToAvoid =  'Nickel Cadmium','Lead Acid' # Battery Chemistry Types
[string]$OutpoutErrorColor = "Red"
[string]$OutputOKColor = "Green"

Function Get-BatteryDetails{
    try
    {
        $Batteries = (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI") | Select-Object DeviceName, ManufactureName, SerialNumber, DesignedCapacity, InstanceName

        Foreach($Battery in $Batteries)
        {
            $BatteryFullChargedCapacity = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI") | Select-Object InstanceName, FullChargedCapacity
            
            Foreach($ChargedCapacity in $BatteryFullChargedCapacity)
            {
                if($ChargedCapacity.InstanceName -eq $Battery.InstanceName)
                    {
                        $Battery | Add-Member -NotePropertyName BatteryFullChargedCapacity -NotePropertyValue $ChargedCapacity.FullChargedCapacity
                        $Battery | Add-Member -NotePropertyName BatteryLifecycle -NotePropertyValue ([math]::Round((100*$ChargedCapacity.FullChargedCapacity/$Battery.DesignedCapacity)))
                    }
            }

            $BatteryChemistryType = (Get-WmiObject -Class "Win32_Battery" -Namespace "ROOT\CIMV2") | Select-Object Name, Chemistry

            ForEach($ChemistryType in $BatteryChemistryType)
            {
                if($ChemistryType.Name -eq $Battery.DeviceName)
                    {
                        [hashtable]$Chemistry = @{1 = 'Other';2 = 'Unknown';3 = 'Lead Acid';4 = 'Nickel Cadmium';5 = 'Nickel Metal Hydride';6 = 'Lithium-ion';7 = 'Zinc air';8 = 'Lithium Polymer'}
                        $Battery | Add-Member -NotePropertyName Chemistry -NotePropertyValue $Chemistry[[int]$ChemistryType.Chemistry]
                    }
            }
        }
            Return($Batteries | Select-Object DeviceName, ManufactureName,SerialNumber, Chemistry, BatteryLifecycle)
    }
   
    catch 
    {
        write-host $_.Exception.Message
        return 999
    }
}

Function Get-BatteryCompliance
{
    param($BatteryCapacityTarget,$BatteryChemistryCompliance,$Batteries)
    $i = 0

    try
    {
        ForEach($BatteryCompliance in $Batteries)
        {
            if($BatteryCompliance.Chemistry -in $ChemistryTypesToAvoid)
            {
                (write-host 'Battery' ($i++) '-' $BatteryCompliance.DeviceName '- Chemistry is Non-compliant' $BatteryCompliance.Chemistry -ForegroundColor $OutpoutErrorColor)
                return 1
            }
            else
            {
                $TotalBatteryCapacity = $TotalBatteryCapacity + $BatteryCompliance.BatteryLifecycle

                if($BatteryCompliance.BatteryLifecycle -lt $BatteryCapacityTarget)
                {
                    (write-host 'Battery' ($i++) '-' $BatteryCompliance.DeviceName '- Lifecycle is Non-compliant at' $BatteryCompliance.BatteryLifecycle '%' -ForegroundColor $OutpoutErrorColor)
                }
                else
                {
                    (write-host 'Battery' ($i++) '-' $BatteryCompliance.DeviceName '- Lifecycle is Compliant at' $BatteryCompliance.BatteryLifecycle '%' -ForegroundColor $OutputOKColor)
                }
            }
    }

        if($i -gt 1) # if multiple batteries found return the global compliance level
        {
            If(([math]::Round(($TotalBatteryCapacity/$Batteries.Count))) -gt $BatteryCapacityTarget)
                {
                    write-host 'Battery (All) - Total Lifecycle is Compliant at' ([math]::Round(($TotalBatteryCapacity/$Batteries.Count))) '%' -ForegroundColor $OutputOKColor
                }
            else
                {
                    write-host 'Battery (All) - Total Lifecycle is Non-Compliant at' ([math]::Round(($TotalBatteryCapacity/$Batteries.Count))) '%' -ForegroundColor $OutpoutErrorColor
                    return 1
                }
        }
    }
    
    catch
    {
        write-host $_.Exception.Message
        return 1
    }
}
 
$Result = (Get-BatteryCompliance -Batteries (Get-BatteryDetails) -BatteryCapacityTarget $BatteryCapacityTarget -BatteryChemistryCompliance $ChemistryTypesToAvoid)
exit($Result)
