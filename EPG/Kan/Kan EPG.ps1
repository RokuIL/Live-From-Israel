# Delete previous files
Del "Kan-*.json"

# Loop through all stations
Foreach($stationID in 1, 2, 4, 5, 7, 8, 9, 11, 19)
{
    # Get data for 5 days 
    For ($i = 0; $i -lt 5; $i++)
    { 
        $date = Get-Date -Date (Get-Date).AddDays($i) -Format "d/M/yyyy"
        $fileName = "Kan-$stationID-$date.json".Replace("/", "-")
        $uri = "https://www.kan.org.il/tv-guide/tv_guidePrograms.ashx?stationID=$stationID&day=$date"

        $Response = Invoke-WebRequest -OutFile $fileName -URI $uri
    }
}
