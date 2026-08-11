# ============================================================
# GeneratePlaylist.ps1
# ============================================================

# ============================================================
# CONFIGURATION
# ============================================================
$StreamsUrl = "https://iptv-org.github.io/api/streams.json"
$LogosUrl   = "https://iptv-org.github.io/api/logos.json"

$OutputFile = Join-Path (Get-Location) "playlist.m3u8"

# Number of retries after the initial failed test.
# 2 = maximum 3 attempts total.
$StreamRetryCount = 2

# Seconds to wait between attempts.
$RetryDelaySeconds = 1

# Maximum number of seconds allowed for each HTTP request.
$StreamTimeoutSeconds = 5

# ============================================================
# LOAD .NET HTTP LIBRARY
# ============================================================
#
# Required when running under Windows PowerShell 5.1.
#
# ============================================================
try {
    Add-Type -AssemblyName System.Net.Http
}
catch {
    Write-Host "ERROR: Could not load System.Net.Http." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# ============================================================
# PLAYLIST HEADER
# ============================================================
$PlaylistHeader = '#EXTM3U'

# ============================================================
# CHANNEL LIST
# ============================================================
#
# Title:
#   Must match the "title" field in streams.json.
#
# Metadata:
#   These names map directly to the Roku M3U parser:
#
#       Title              -> display title
#       TitleEng           -> tvg-name
#       Logo               -> tvg-logo
#       GroupTitle         -> group-title
#       EPGProvider        -> tvg-provider
#       EPGStationId       -> tvg-id
#       EPGBackupProvider  -> tvg-backup-provider
#       EPGBackupStationId -> tvg-backup-id
#
# Logo:
#   Optional fallback logo.
#
#   Logo lookup order:
#
#       1. logos.json
#       2. Logo specified here
#       3. No logo
#
# ============================================================
$ChannelList = @(
    @{ Title = "Kan 11";                    TitleEng = "Kan 11";                    GroupTitle = "Israel";  EPGProvider = "WGP";     EPGStationId = "Kan%2011";    EPGBackupProvider = "XMLTV";  EPGBackupStationId = "11-kanal-il";                 Logo = "" }
    @{ Title = "Keshet 12";                 TitleEng = "Keshet 12";                 GroupTitle = "Israel";  EPGProvider = "Mako";    EPGStationId = "";            EPGBackupProvider = "WGP";    EPGBackupStationId = "Keshet%2012";                 Logo = "" }
    @{ Title = "Reshet 13";                 TitleEng = "Reshet 13";                 GroupTitle = "Israel";  EPGProvider = "WGP";     EPGStationId = "Reshet%2013"; EPGBackupProvider = "Reshet"; EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "Fox News International";    TitleEng = "Fox News International";    GroupTitle = "US News"; EPGProvider = "WGP.ENG"; EPGStationId = "465372";      EPGBackupProvider = "XMLTV";  EPGBackupStationId = "fox-news-hd";                 Logo = "" }
    @{ Title = "CBS News New York";         TitleEng = "CBS News New York";         GroupTitle = "US News"; EPGProvider = "WGP.ENG"; EPGStationId = "468311";      EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "FOX 5 New York NY (WNYW)";  TitleEng = "FOX 5 New York NY (WNYW)";  GroupTitle = "US News"; EPGProvider = "WGP.ENG"; EPGStationId = "469512";      EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "FOX Sports";                TitleEng = "FOX Sports";                GroupTitle = "Sports";  EPGProvider = "";        EPGStationId = "";            EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/FOX_Sports_logo.svg/960px-FOX_Sports_logo.svg.png" }
    @{ Title = "FOX Sports 1";              TitleEng = "FOX Sports 1";              GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "465291";      EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "FOX Sports 2";              TitleEng = "FOX Sports 2";              GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "465355";      EPGBackupProvider = "XMLTV";  EPGBackupStationId = "fox-sports2-us";              Logo = "" }
    @{ Title = "NBC Sports NOW";            TitleEng = "NBC Sports NOW";            GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "485735";      EPGBackupProvider = "XMLTV";  EPGBackupStationId = "nbc-sports-us-hd";            Logo = "" }
    @{ Title = "TSN1";                      TitleEng = "TSN1";                      GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "7592";        EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "TSN2";                      TitleEng = "TSN2";                      GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "6721";        EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "TSN3";                      TitleEng = "TSN3";                      GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "6987";        EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "TSN4";                      TitleEng = "TSN4";                      GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "7232";        EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "TSN5";                      TitleEng = "TSN5";                      GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "7658";        EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "NFL Channel";               TitleEng = "NFL Channel";               GroupTitle = "Sports";  EPGProvider = "";        EPGStationId = "";            EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "NFL Network";               TitleEng = "NFL Network";               GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "465311";      EPGBackupProvider = "XMLTV";  EPGBackupStationId = "nfl-network-us-hd";           Logo = "" }
    @{ Title = "MLB";                       TitleEng = "MLB";                       GroupTitle = "Sports";  EPGProvider = "";        EPGStationId = "";            EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "MLB Channel";               TitleEng = "MLB";                       GroupTitle = "Sports";  EPGProvider = "";        EPGStationId = "";            EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "MLB Network";               TitleEng = "MLB Network";               GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "407571";      EPGBackupProvider = "XMLTV";  EPGBackupStationId = "mlb-network-us-hd";           Logo = "" }
    @{ Title = "MLB Strike Zone";           TitleEng = "MLB Strike Zone";           GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "464844";      EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "SportsNet New York";        TitleEng = "SportsNet New York";        GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "408605";      EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "Fox Soccer Plus";           TitleEng = "Fox Soccer Plus";           GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "465214";      EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "Sky Sports F1";             TitleEng = "Sky Sports F1";             GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "10781";       EPGBackupProvider = "XMLTV";  EPGBackupStationId = "sky-sports-f1-uk-hd";         Logo = "" }
    @{ Title = "Sky Sports Football";       TitleEng = "Sky Sports Football";       GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "5791";        EPGBackupProvider = "XMLTV";  EPGBackupStationId = "sky-sports-football-uk-hd";   Logo = "" }
    @{ Title = "Sky Sports Main Event";     TitleEng = "Sky Sports Main Event";     GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "7673";        EPGBackupProvider = "XMLTV";  EPGBackupStationId = "sky-sports-main-event-uk-hd"; Logo = "" }
    @{ Title = "Sky Sports NFL";            TitleEng = "Sky Sports NFL";            GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "454969";      EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
    @{ Title = "Sky Mix";                   TitleEng = "Sky Mix";                   GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "526142";      EPGBackupProvider = "XMLTV";  EPGBackupStationId = "sky-sports-mix-uk-hd";        Logo = "" }
    @{ Title = "Yes Network";               TitleEng = "Yes Network";               GroupTitle = "Sports";  EPGProvider = "WGP.ENG"; EPGStationId = "427689";      EPGBackupProvider = "";       EPGBackupStationId = "";                            Logo = "" }
)

# ============================================================
# QUALITY SORTING
# ============================================================
#
# Higher resolution = better.
#
# Examples:
#
#   2160p -> 2160
#   1080p -> 1080
#   1080i -> 1080
#   720p  -> 720
#   576i  -> 576
#   480p  -> 480
#
# Unknown quality = 0
#
# ============================================================
function Get-QualityValue {
    param (
        [string]$Quality
    )

    if ([string]::IsNullOrWhiteSpace($Quality)) {
        return 0
    }

    if ($Quality -match '(\d+)') {
        return [int]$Matches[1]
    }

    return 0
}

# ============================================================
# TEST WHETHER A STREAM IS LIVE
# ============================================================
#
# HLS streams:
#
#   1. Request the M3U8.
#   2. Verify that it is HLS.
#   3. Follow a master playlist if necessary.
#   4. Find a media segment.
#   5. Request the media segment.
#   6. Confirm that actual data is returned.
#
# This is intentionally stronger than simply checking for
# HTTP 200 from the M3U8 URL.
#
# Non-HLS streams:
#
#   1. Request the stream.
#   2. Confirm HTTP success.
#   3. Read the first 4 KB of the response.
#
# Compatible with Windows PowerShell 5.1.
#
# ============================================================
function Test-StreamLive {
    param (
        [string]$Url,
        [string]$Referrer,
        [string]$UserAgent
    )

    if ([string]::IsNullOrWhiteSpace($Url)) {
        return $false
    }

    $Handler = $null
    $Client = $null
    $Response = $null

    try {
        # ====================================================
        # CREATE HTTP CLIENT
        # ====================================================
        $Handler = New-Object System.Net.Http.HttpClientHandler
        $Handler.AllowAutoRedirect = $true
        $Client = New-Object System.Net.Http.HttpClient($Handler)
        $Client.Timeout = [TimeSpan]::FromSeconds(
            $StreamTimeoutSeconds
        )

        # ====================================================
        # USER AGENT
        # ====================================================
        if (-not [string]::IsNullOrWhiteSpace($UserAgent)) {
            try {
                $Client.DefaultRequestHeaders.UserAgent.ParseAdd(
                    $UserAgent
                )
            }
            catch {
                $Client.DefaultRequestHeaders.UserAgent.ParseAdd(
                    "Mozilla/5.0"
                )
            }
        }
        else {
            $Client.DefaultRequestHeaders.UserAgent.ParseAdd(
                "Mozilla/5.0"
            )
        }

        # ====================================================
        # REFERRER
        # ====================================================
        if (-not [string]::IsNullOrWhiteSpace($Referrer)) {
            try {
                $ReferrerUri = New-Object System.Uri($Referrer)
                $Client.DefaultRequestHeaders.Referrer = $ReferrerUri
            }
            catch {
                # Ignore invalid referrer.
            }
        }

        # ====================================================
        # REQUEST INITIAL URL
        # ====================================================
        $Response = $Client.GetAsync(
            $Url,
            [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead
        ).GetAwaiter().GetResult()

        if (-not $Response.IsSuccessStatusCode) {
            return $false
        }

        # ====================================================
        # DETERMINE CONTENT TYPE
        # ====================================================
        $ContentType = ""
        if ($null -ne $Response.Content.Headers.ContentType) {
            $ContentType =
                $Response.Content.Headers.ContentType.MediaType
        }

        # ====================================================
        # DETERMINE WHETHER THIS IS HLS
        # ====================================================
        $IsHls = (
            $Url -match '(?i)\.m3u8($|[?#])'
        ) -or (
            $ContentType -match '(?i)mpegurl|x-mpegurl'
        )

        # ====================================================
        # NON-HLS STREAM
        # ====================================================
        if (-not $IsHls) {
            # ------------------------------------------------
            # Read only a small amount.
            #
            # We must NOT read the entire response because a
            # live video stream may never end.
            # ------------------------------------------------
            $Buffer = New-Object byte[] 4094
            $Stream = $Response.Content.ReadAsStreamAsync().
                GetAwaiter().
                GetResult()
            try {
                $BytesRead = $Stream.Read(
                    $Buffer,
                    0,
                    $Buffer.Length
                )
            }
            finally {
                $Stream.Dispose()
            }

            if ($BytesRead -gt 0) {
                return $true
            }

            return $false
        }

        # ====================================================
        # READ HLS PLAYLIST
        # ====================================================
        $PlaylistText = $Response.Content.ReadAsStringAsync().
            GetAwaiter().
            GetResult()

        $Response.Dispose()
        $Response = $null

        # ====================================================
        # VALIDATE HLS
        # ====================================================
        if ($PlaylistText -notmatch '#EXTM3U') {
            return $false
        }

        # ====================================================
        # BASE URL
        # ====================================================
        try {

            $BaseUri = New-Object System.Uri($Url)
        }
        catch {

            return $false
        }

        # ====================================================
        # MASTER PLAYLIST
        # ====================================================
        #
        # A master playlist contains:
        #
        #   #EXT-X-STREAM-INF
        #
        # followed by another M3U8 URL.
        #
        # ====================================================
        if ($PlaylistText -match '(?m)#EXT-X-STREAM-INF:') {
            $Lines = $PlaylistText -split "`r?`n"
            $VariantUrl = $null

            for ($i = 0; $i -lt $Lines.Count; $i++) {
                $Line = $Lines[$i].Trim()
                if ($Line -match '^#EXT-X-STREAM-INF:') {
                    for (
                        $j = $i + 1;
                        $j -lt $Lines.Count;
                        $j++
                    ) {
                        $Candidate = $Lines[$j].Trim()
                        if (
                            -not [string]::IsNullOrWhiteSpace($Candidate) -and
                            $Candidate -notmatch '^#'
                        ) {
                            $VariantUrl = $Candidate
                            break
                        }
                    }
                }

                if ($null -ne $VariantUrl) {
                    break
                }
            }

            if ([string]::IsNullOrWhiteSpace($VariantUrl)) {
                return $false
            }

            # ------------------------------------------------
            # Convert relative URL to absolute URL.
            # ------------------------------------------------
            try {
                $VariantUri = New-Object System.Uri(
                    $BaseUri,
                    $VariantUrl
                )
                $VariantUrl = $VariantUri.AbsoluteUri
            }
            catch {

                return $false
            }

            # ------------------------------------------------
            # Download variant playlist.
            # ------------------------------------------------
            $VariantResponse = $Client.GetAsync(
                $VariantUrl,
                [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead
            ).GetAwaiter().GetResult()

            if (-not $VariantResponse.IsSuccessStatusCode) {
                $VariantResponse.Dispose()
                return $false
            }

            $PlaylistText = $VariantResponse.Content.ReadAsStringAsync().
                GetAwaiter().
                GetResult()
            $VariantResponse.Dispose()

            # The media segments are relative to the variant
            # playlist, not necessarily the original URL.
            $BaseUri = New-Object System.Uri($VariantUrl)
        }

        # ====================================================
        # FIND MEDIA SEGMENT
        # ====================================================
        $Lines = $PlaylistText -split "`r?`n"
        $SegmentUrl = $null

        foreach ($Line in $Lines) {
            $Candidate = $Line.Trim()
            if ([string]::IsNullOrWhiteSpace($Candidate)) {
                continue
            }

            # Skip HLS directives.
            if ($Candidate.StartsWith("#")) {
                continue
            }

            # First non-comment URL should be a media segment.
            $SegmentUrl = $Candidate

            break
        }

        if ([string]::IsNullOrWhiteSpace($SegmentUrl)) {
            return $false
        }

        # ====================================================
        # RESOLVE MEDIA SEGMENT URL
        # ====================================================
        try {
            $SegmentUri = New-Object System.Uri(
                $BaseUri,
                $SegmentUrl
            )

            $SegmentUrl = $SegmentUri.AbsoluteUri
        }
        catch {
            return $false
        }

        # ====================================================
        # REQUEST MEDIA SEGMENT
        # ====================================================
        #
        # This is the important live-stream test.
        #
        # We don't need the whole segment. We only need to
        # confirm that actual media bytes are returned.
        #
        # ====================================================
        $SegmentResponse = $Client.GetAsync(
            $SegmentUrl,
            [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead
        ).GetAwaiter().GetResult()

        if (-not $SegmentResponse.IsSuccessStatusCode) {
            $SegmentResponse.Dispose()
            return $false
        }

        $SegmentStream = $SegmentResponse.Content.ReadAsStreamAsync().
            GetAwaiter().
            GetResult()

        $Buffer = New-Object byte[] 4096
        try {
            $BytesRead = $SegmentStream.Read(
                $Buffer,
                0,
                $Buffer.Length
            )
        }
        finally {
            $SegmentStream.Dispose()
            $SegmentResponse.Dispose()
        }

        # ====================================================
        # REQUIRE ACTUAL DATA
        # ====================================================
        if ($BytesRead -gt 0) {
            return $true
        }

        return $false
    }
    catch {
        return $false
    }
    finally {
        if ($null -ne $Response) {
            $Response.Dispose()
        }
        if ($null -ne $Client) {
            $Client.Dispose()
        }
        if ($null -ne $Handler) {
            $Handler.Dispose()
        }
    }
}

# ============================================================
# TEST STREAM WITH RETRY
# ============================================================
#
# First attempt + requested number of retries.
#
# With:
#
#   $StreamRetryCount = 2
#
# each stream gets a maximum of 3 attempts.
#
# ============================================================
function Test-StreamWithRetry {
    param (
        [string]$Url,
        [string]$Referrer,
        [string]$UserAgent,
        [int]$RetryCount = 1
    )

    $MaxAttempts = $RetryCount + 1

    for ($Attempt = 1; $Attempt -le $MaxAttempts; $Attempt++) {
        $Result = Test-StreamLive `
            -Url $Url `
            -Referrer $Referrer `
            -UserAgent $UserAgent

        if ($Result) {
            return $true
        }

        # ----------------------------------------------------
        # Failed, but another attempt is available.
        # ----------------------------------------------------
        if ($Attempt -lt $MaxAttempts) {
            if ($RetryDelaySeconds -gt 0) {
                Start-Sleep -Seconds $RetryDelaySeconds
            }
        }
    }

    return $false
}

# ============================================================
# DOWNLOAD STREAMS.JSON
# ============================================================
Write-Host ""
Write-Host "========================================"
Write-Host " IPTV Playlist Generator"
Write-Host "========================================"
Write-Host ""

Write-Host "Downloading streams.json..."

try {
    $Streams = Invoke-RestMethod `
        -Uri $StreamsUrl `
        -Method Get `
        -Headers @{ "User-Agent" = "Mozilla/5.0" } `
        -ErrorAction Stop
    Write-Host "Loaded $($Streams.Count) stream entries."
}
catch {
    Write-Host ""
    Write-Host "ERROR downloading streams.json:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    exit 1
}

# ============================================================
# DOWNLOAD LOGOS.JSON
# ============================================================
Write-Host "Downloading logos.json..."
try {
    $Logos = Invoke-RestMethod `
        -Uri $LogosUrl `
        -Method Get `
        -Headers @{ "User-Agent" = "Mozilla/5.0" } `
        -ErrorAction Stop

    Write-Host "Loaded $($Logos.Count) logo entries."
}
catch {
    Write-Host ""
    Write-Host "ERROR downloading logos.json:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# ============================================================
# CREATE LOGO LOOKUP
# ============================================================
#
# Maps:
#
#     channel ID -> logo URL
#
# If multiple logos exist, prefer one marked "in_use".
#
# ============================================================
$LogoLookup = @{}

foreach ($Logo in $Logos) {
    $ChannelId = $Logo.channel
    $LogoUrl   = $Logo.url

    if ([string]::IsNullOrWhiteSpace($ChannelId)) {
        continue
    }
    if ([string]::IsNullOrWhiteSpace($LogoUrl)) {
        continue
    }

    # First logo found.
    if (-not $LogoLookup.ContainsKey($ChannelId)) {
        $LogoLookup[$ChannelId] = $LogoUrl
    }
    # Prefer in-use logo.
    elseif ($Logo.in_use -eq $true) {
        $LogoLookup[$ChannelId] = $LogoUrl
    }
}

# ============================================================
# CREATE PLAYLIST
# ============================================================
$Playlist = [System.Collections.Generic.List[string]]::new()
$Playlist.Add($PlaylistHeader)

# ============================================================
# STATISTICS
# ============================================================
$TotalStreams = 0
$TestedStreams = 0
$LiveStreams = 0
$FailedStreams = 0

$NotFound = [System.Collections.Generic.List[string]]::new()
$NoLogo = [System.Collections.Generic.List[string]]::new()
$FallbackLogoUsed = [System.Collections.Generic.List[string]]::new()
$OfflineStreams = [System.Collections.Generic.List[string]]::new()

# ============================================================
# PROCESS CHANNEL LIST
# ============================================================
#
# The outer loop guarantees that channels appear in exactly
# the order specified in $ChannelList.
#
# Each channel's streams are then sorted by quality.
#
# ============================================================
foreach ($Channel in $ChannelList) {
    $RequestedTitle = $Channel.Title
    $FallbackLogo = $Channel.Logo

    Write-Host ""
    Write-Host "============================================================"
    Write-Host "Searching: $RequestedTitle"
    Write-Host "============================================================"

    # ========================================================
    # FIND MATCHING STREAMS
    # ========================================================
    $MatchedStreams = @(
        $Streams |
            Where-Object {
                $_.title -eq $RequestedTitle
            }
    )

    if ($MatchedStreams.Count -eq 0) {
        Write-Host "  NOT FOUND" -ForegroundColor Yellow
        $NotFound.Add($RequestedTitle)

        # Blank line separating channel groups.
        $Playlist.Add("")
        continue
    }

    Write-Host "  Found $($MatchedStreams.Count) stream(s)"

    # ========================================================
    # SORT BY QUALITY
    # ========================================================
    #
    # Highest quality first.
    #
    # The original channel order is preserved because this
    # sorting happens only inside the current channel group.
    #
    # ========================================================
    $MatchedStreams = @(
        $MatchedStreams |
            Sort-Object -Property @{
                Expression = {
                    Get-QualityValue $_.quality
                }
                Descending = $true
            }
    )

    # ========================================================
    # PROCESS MATCHING STREAMS
    # ========================================================
    foreach ($Stream in $MatchedStreams) {
        $StreamTitle = $Stream.title
        $ChannelId   = $Stream.channel
        $StreamUrl   = $Stream.url
        $Quality     = $Stream.quality
        $Referrer    = $Stream.referrer
        $UserAgent   = $Stream.user_agent

        # ----------------------------------------------------
        # Ignore streams with no URL.
        # ----------------------------------------------------
        if ([string]::IsNullOrWhiteSpace($StreamUrl)) {
            Write-Host "    WARNING: stream has no URL" `
                -ForegroundColor Yellow
            continue
        }

        # ====================================================
        # TEST STREAM
        # ====================================================
        $TestedStreams++
        Write-Host "    Testing: $StreamTitle" -NoNewline

        $IsLive = Test-StreamWithRetry `
            -Url $StreamUrl `
            -Referrer $Referrer `
            -UserAgent $UserAgent `
            -RetryCount $StreamRetryCount

        # ====================================================
        # STREAM FAILED
        # ====================================================
        if (-not $IsLive) {
            Write-Host " [OFFLINE]" -ForegroundColor DarkYellow
            $FailedStreams++

            $OfflineStreams.Add(
                "$StreamTitle [$Quality] - $StreamUrl"
            )

            # IMPORTANT:
            # Do NOT add anything to $Playlist.
            continue
        }

        # ====================================================
        # STREAM IS LIVE
        # ====================================================
        Write-Host " [LIVE]" -ForegroundColor Green
        $LiveStreams++

        # ====================================================
        # FIND LOGO
        # ====================================================
        #
        # Priority:
        #
        #   1. logos.json
        #   2. manually specified fallback
        #   3. no logo
        #
        # ====================================================
        $LogoUrl = $null
        $LogoSource = "none"

        if (-not [string]::IsNullOrWhiteSpace($ChannelId)) {
            if ($LogoLookup.ContainsKey($ChannelId)) {
                $LogoUrl = $LogoLookup[$ChannelId]
                $LogoSource = "logos.json"
            }
        }

        # ----------------------------------------------------
        # Fallback logo.
        # ----------------------------------------------------
        if (
            [string]::IsNullOrWhiteSpace($LogoUrl) -and
            -not [string]::IsNullOrWhiteSpace($FallbackLogo)
        ) {
            $LogoUrl = $FallbackLogo
            $LogoSource = "fallback"
        }

        # ----------------------------------------------------
        # No logo.
        # ----------------------------------------------------
        if ([string]::IsNullOrWhiteSpace($LogoUrl)) {
            $NoLogo.Add(
                "$StreamTitle ($ChannelId)"
            )
        }

        # ----------------------------------------------------
        # Record fallback-logo usage.
        # ----------------------------------------------------
        if ($LogoSource -eq "fallback") {
            $FallbackLogoUsed.Add(
                "$StreamTitle ($ChannelId)"
            )
        }

        # ====================================================
        # DISPLAY TITLE
        # ====================================================
        #
        # The predefined metadata controls the playlist label. The
        # stream title remains the lookup key in streams.json.
        #
        # ====================================================
        $DisplayTitle = $Channel.Title
        if ([string]::IsNullOrWhiteSpace($DisplayTitle)) {
            $DisplayTitle = $StreamTitle
        }
        if ([string]::IsNullOrWhiteSpace($Channel.TitleEng)) {
            $Channel.TitleEng = $DisplayTitle
        }

        # ====================================================
        # EXTINF ATTRIBUTES
        # ====================================================
        $Attributes = @()

        $OutputMetadata = @(
            @{ Name = "tvg-name";             Value = $Channel.TitleEng }
            @{ Name = "tvg-logo";             Value = $LogoUrl }
            @{ Name = "group-title";          Value = $Channel.GroupTitle }
            @{ Name = "tvg-provider";         Value = $Channel.EPGProvider }
            @{ Name = "tvg-id";               Value = $Channel.EPGStationId }
            @{ Name = "tvg-backup-provider";  Value = $Channel.EPGBackupProvider }
            @{ Name = "tvg-backup-id";        Value = $Channel.EPGBackupStationId }
        )

        foreach ($MetadataField in $OutputMetadata) {
            if (-not [string]::IsNullOrWhiteSpace($MetadataField.Value)) {
                $SafeValue = $MetadataField.Value -replace '"', "'"
                $Attributes += "$($MetadataField.Name)=`"$SafeValue`""
            }
        }

        # ====================================================
        # EXTINF
        # ====================================================
        $ExtInf =
            "#EXTINF:-1 " +
            ($Attributes -join " ") +
            ",$DisplayTitle"

        $Playlist.Add($ExtInf)

        # ====================================================
        # REFERRER
        # ====================================================
        if (-not [string]::IsNullOrWhiteSpace($Referrer)) {
            $Playlist.Add(
                "#EXTVLCOPT:http-referrer=$Referrer"
            )
        }

        # ====================================================
        # USER AGENT
        # ====================================================
        if (-not [string]::IsNullOrWhiteSpace($UserAgent)) {
            $Playlist.Add(
                "#EXTVLCOPT:http-user-agent=$UserAgent"
            )
        }

        # ====================================================
        # STREAM URL
        # ====================================================
        $Playlist.Add($StreamUrl)
        $TotalStreams++

        # ====================================================
        # DISPLAY INFORMATION
        # ====================================================
        Write-Host "      quality: $Quality"
        Write-Host "      tvg-id:  $($Channel.EPGStationId)"

        switch ($LogoSource) {
            "logos.json" {
                Write-Host "      logo:   logos.json"
            }

            "fallback" {
                Write-Host "      logo:   FALLBACK"
            }

            default {
                Write-Host "      logo:   NONE" `
                    -ForegroundColor Yellow
            }
        }
    }

    # ========================================================
    # END OF CHANNEL GROUP
    # ========================================================
    #
    # Always add an empty line after the channel group.
    #
    # ========================================================
    $Playlist.Add("")
}

# ============================================================
# WRITE PLAYLIST
# ============================================================
try {
    $Playlist |
        Set-Content `
            -Path $OutputFile `
            -Encoding UTF8 `
            -ErrorAction Stop
}
catch {
    Write-Host ""
    Write-Host "ERROR writing playlist:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# ============================================================
# SUMMARY
# ============================================================
Write-Host ""
Write-Host "============================================================"
Write-Host " Completed"
Write-Host "============================================================"
Write-Host ""

Write-Host "Output file       : $OutputFile"
Write-Host "Streams in list   : $TotalStreams"
Write-Host "Streams tested    : $TestedStreams"
Write-Host "Live streams      : $LiveStreams"
Write-Host "Offline streams   : $FailedStreams"
Write-Host "Channels not found: $($NotFound.Count)"
Write-Host "No logo           : $($NoLogo.Count)"
Write-Host "Fallback logos    : $($FallbackLogoUsed.Count)"
Write-Host ""

# ============================================================
# CHANNELS NOT FOUND
# ============================================================
if ($NotFound.Count -gt 0) {
    Write-Host "CHANNELS NOT FOUND:" -ForegroundColor Yellow

    foreach ($Title in $NotFound) {

        Write-Host "  - $Title"
    }

    Write-Host ""
}

# ============================================================
# OFFLINE STREAMS
# ============================================================
if ($OfflineStreams.Count -gt 0) {
    Write-Host "OFFLINE STREAMS:" -ForegroundColor DarkYellow

    foreach ($Item in $OfflineStreams) {

        Write-Host "  - $Item"
    }

    Write-Host ""
}

# ============================================================
# STREAMS WITHOUT LOGO
# ============================================================
if ($NoLogo.Count -gt 0) {
    Write-Host "STREAMS WITHOUT LOGO:" -ForegroundColor Yellow

    foreach ($Item in $NoLogo) {

        Write-Host "  - $Item"
    }

    Write-Host ""
}

# ============================================================
# FALLBACK LOGOS USED
# ============================================================
if ($FallbackLogoUsed.Count -gt 0) {
    Write-Host "FALLBACK LOGOS USED:" -ForegroundColor Cyan

    foreach ($Item in $FallbackLogoUsed) {

        Write-Host "  - $Item"
    }

    Write-Host ""
}

Write-Host "Done."
Write-Host ""
