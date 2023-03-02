# Transcript to user %TEMP%
Start-Transcript -Path "$env:temp\Set-BannedTaskbarPins.log" | Out-Null

# Banned apps array
[array]$banlist = 'Microsoft Store','Mail'

Function Set-BannedTaskbarPins{

    BEGIN
    {
        try
        {
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
                        # Invoke unpin from taskbar
                        $verb.DoIt()
                        write-host $app.Name "unpinned" -ForegroundColor Green
                    }
                }
            }
        }
    }
    END
    {
        Stop-Transcript | Out-Null
    }
}

Set-BannedTaskbarPins
