# Transcript to user %TEMP%
Start-Transcript -Path "$env:temp\Get-BannedTaskbarPins.log" | Out-Null

# Banned apps array
[array]$banlist = 'Microsoft Store','Mail'

Function Get-BannedTaskbarPins{

    BEGIN
    {
        
        try
        {
            # Initialise $found
            $found = 0

            # Get Apps
            $Apps = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items()
        }
        catch
        {
            Return($Error[0].Exception.Message)
        }
    }

    PROCESS
    {
        # For each App
        Foreach($App in $Apps)
        {
            # If App Name is in the banlist
            if($App.Name -in $banlist)
            {
                # Loop through each verb in the current App
                Foreach($verb in $app.Verbs())
                {
                    # if there is a verb called 'Unpin from tas&kbar'
			        if($verb.Name -eq 'Unpin from tas&kbar')
                    {
                        # return 1 from the function
				        write-host $app.Name "is pinned" -ForegroundColor Red
                        $found = 1
                    }
                }
            }
        }
    }
    END
    {
        Stop-Transcript | Out-Null
        Return($found)
    }
}

EXIT(Get-BannedTaskbarPins)
