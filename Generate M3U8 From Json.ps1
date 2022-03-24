$title = ""
$logo = ""
$private = 0
$streamUrls = ""

$nextLineIsStreamURL = 0

$excludeList = "Keshet 12", "N12 News"

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

                # "Private": "True"
                ElseIf ($line -like "*Private*")
                {
                    $private = 1
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
                    If (($test -ne $title) -and ($private -ne 1))
                    {
                        "" | Out-File -Append -FilePath Channels.m3u8
                        "#EXTINF:0, logo=""$logo"", $title" | Out-File -Append -FilePath Channels.m3u8
                        "$mediaUrl" | Out-File -Append -FilePath Channels.m3u8
                    }

                    $private = 0         
                    $nextLineIsStreamURL = 0
                }
            }
        }
    }
}
