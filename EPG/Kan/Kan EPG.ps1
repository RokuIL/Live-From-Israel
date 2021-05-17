$gitCommit = 1

# Delete previous files
Del "Kan-*.json"

# Loop through all stations
Foreach($stationID in 1, 2, 4, 5, 7, 8, 9, 11, 19)
{
    # Get data for 3 days 
    For ($i = 0; $i -lt 3; $i++)
    { 
        $date = Get-Date -Date (Get-Date).AddDays($i) -Format "d/M/yyyy"
        $fileName = "Kan-$stationID-$date.json".Replace("/", "-")
        $uri = "https://www.kan.org.il/tv-guide/tv_guidePrograms.ashx?stationID=$stationID&day=$date"

        Try 
        {
            $Response = Invoke-WebRequest -OutFile $fileName -URI $uri
        }
        Catch
        {
            Write-Host "Caught an error (check geolocation). Will not commit!" -ForegroundColor Red
            Write-Host $Error -ForegroundColor Red
            $gitCommit = 0
            break
        }
    }

    If ($gitCommit -eq 0)
    {
        break
    }
}

# Commit and push
If ($gitCommit)
{
    "Pulling..." | Out-File -FilePath "c:\tmp\Kan EPG.log" -Append
    Write-Host "Pulling..." -ForegroundColor Green
    Git pull | Out-File -FilePath "c:\tmp\Kan EPG.log" -Append

    "Adding..." | Out-File -FilePath "c:\tmp\Kan EPG.log" -Append
    Write-Host "Adding..." -ForegroundColor Green
    Git add *.json | Out-File -FilePath "c:\tmp\Kan EPG.log" -Append

    "Committing..." | Out-File -FilePath "c:\tmp\Kan EPG.log" -Append
    Write-Host "Committing..." -ForegroundColor Green
    Git commit -m "Update EPG" --all | Out-File -FilePath "c:\tmp\Kan EPG.log" -Append

    "Pushing..." | Out-File -FilePath "c:\tmp\Kan EPG.log" -Append
    Write-Host "Pushing..." -ForegroundColor Green
    Git push | Out-File -FilePath "c:\tmp\Kan EPG.log" -Append
}
