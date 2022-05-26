$channelsStarted = 0
$title = ""
$logo = ""
$headers = 0
$streamUrls = ""

$nextLineIsStreamURL = 0

$excludeList = "N12 News"

$files = Get-ChildItem -File -Path * -Include Channels.json
Foreach ($file in $files)
{
    If ($file -ne $null)
    {
        "#EXTM3U" | Out-File -FilePath Channels.m3u8

        # For each line in the file
        Foreach ($line in Get-Content $file) 
        {
            If ($line -ne $null)
            {
                # Get to Channels first
                If ($line -like "*Channels*")
                {
                    $channelsStarted = 1
                }
                If ($channelsStarted -eq 0)
                {
                    continue
                }
                 
                # "TitleEng": "Kan 11",
                If ($line -like "*TitleEng*")
                {
                    $regex = [regex] "(?<="":\s"").*(?="".)"
                    $title = $regex.Matches($line) | %{ $_.value }
                }

                # "Logo": "https://raw.githubusercontent.com/RokuIL/Live-From-Israel/master/Logos/Kan%2011.png",
                ElseIf ($line -like "*Logo*")
                {
                    $regex = [regex] "(?<="":\s"").*(?="".)"
                    $logo = $regex.Matches($line) | %{ $_.value }
                }

                # "Headers":
                ElseIf ($line -like "*Headers*")
                {
                    $headers = 1
                }

                # "StreamUrls": [
                ElseIf ($line -like "*StreamUrls*")
                {
                    $nextLineIsStreamURL = 1
                }
                # Media URL
                ElseIf ($nextLineIsStreamURL)
                {
                    $regex = [regex] "(?<="").*(?="")"
                    $mediaUrl = $regex.Matches($line) | %{ $_.value }

                    $test = $excludeList | Where-Object { $_ -in $title }
                    If (($test -ne $title) -and ($headers -ne 1))
                    {
                        "" | Out-File -Append -FilePath Channels.m3u8
                        "#EXTINF:0, logo=""$logo"", $title" | Out-File -Append -FilePath Channels.m3u8
                        "$mediaUrl" | Out-File -Append -FilePath Channels.m3u8
                    }

                    $headers = 0    
                    $nextLineIsStreamURL = 0
                }
            }
        }
    }
}
