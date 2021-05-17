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
            $gitCommit = 0
        }
    }
}

# Commit and push
If ($gitCommit)
{
    Git pull
    Git commit -m "Update EPG" --all
    Git push
}
