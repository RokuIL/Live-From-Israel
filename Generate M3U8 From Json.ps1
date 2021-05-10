$title = ""
$logo = ""
$streamUrls = ""

$nextLineIsStreamURL = 0

$excludeList = "Keshet 12", "Channel 20"

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
                #            "TitleEng": "Kan 11",
                If ($line -like "*TitleEng*")
                {
                    $regex = [regex] "(?<="":\s"").*(?="".)"
                    $title = $regex.Matches($line) | %{ $_.value }
                }

                #             "Logo": "https://raw.githubusercontent.com/RokuIL/Live-From-Israel/master/Logos/Kan%2011.png",
                ElseIf ($line -like "*Logo*")
                {
                    $regex = [regex] "(?<="":\s"").*(?="".)"
                    $logo = $regex.Matches($line) | %{ $_.value }
                }

                #             "StreamUrls": [
                ElseIf ($line -like "*StreamUrls*")
                {
                    $nextLineIsStreamURL = 1
                }
                # Media URL
                ElseIf ($nextLineIsStreamURL)
                {
                    $regex = [regex] "(?<="").*(?="")"
                    $mediaUrl = $regex.Matches($line) | %{ $_.value }

                    $nextLineIsStreamURL = 0

                    $test = $excludeList | Where-Object { $_ -in $title }
                    If ($test -ne $title) 
                    {
                        "" | Out-File -Append -FilePath Channels.m3u8
                        "#EXTINF:0, logo=""$logo"", $title" | Out-File -Append -FilePath Channels.m3u8
                        "$mediaUrl" | Out-File -Append -FilePath Channels.m3u8
                    }            
                }
            }
        }
    }
}
