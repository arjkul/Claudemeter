# UpdateUsage.ps1 - Fetch Claude usage via OAuth token and save usage data
# Run this every 60 seconds via Windows Task Scheduler

$credPath = "$env:USERPROFILE\.claude\.credentials.json"

try {
    # Read OAuth token
    $creds = Get-Content $credPath -Raw | ConvertFrom-Json
    $token = $creds.claudeAiOauth.accessToken

    if (-not $token) {
        throw "No OAuth token found"
    }

    # Make minimal API call to get rate-limit headers
    $headers = @{
        "Authorization" = "Bearer $token"
        "anthropic-version" = "2023-06-01"
        "anthropic-beta" = "claude-code-20250219"
        "Content-Type" = "application/json"
    }

    $body = '{"model":"claude-haiku-4-5-20251001","max_tokens":1,"system":[{"type":"text","text":"You are Claude Code."}],"messages":[{"role":"user","content":"hi"}]}'

    $response = Invoke-WebRequest `
        -Uri "https://api.anthropic.com/v1/messages" `
        -Headers $headers `
        -Method Post `
        -Body $body `
        -UseBasicParsing

    # Extract percentages - handle array values
    $session5hHeader = $response.Headers["anthropic-ratelimit-unified-5h-utilization"]
    $weekly7dHeader = $response.Headers["anthropic-ratelimit-unified-7d-utilization"]
    $session5h = if ($session5hHeader) {
        [math]::Round([float]($session5hHeader -is [array] ? $session5hHeader[0] : $session5hHeader) * 100, 1)
    } else { 0 }
    $weekly7d = if ($weekly7dHeader) {
        [math]::Round([float]($weekly7dHeader -is [array] ? $weekly7dHeader[0] : $weekly7dHeader) * 100, 1)
    } else { 0 }

    # Extract reset timestamps (Unix epoch) - handle array values
    $session5hResetHeader = $response.Headers["anthropic-ratelimit-unified-5h-reset"]
    $weekly7dResetHeader = $response.Headers["anthropic-ratelimit-unified-7d-reset"]
    $session5hResetUnix = [int]($session5hResetHeader -is [array] ? $session5hResetHeader[0] : $session5hResetHeader)
    $weekly7dResetUnix = [int]($weekly7dResetHeader -is [array] ? $weekly7dResetHeader[0] : $weekly7dResetHeader)

    # Calculate time remaining
    $now = [int][double]::Parse((Get-Date -UFormat %s))
    $session5hRemaining = $session5hResetUnix - $now
    $weekly7dRemaining = $weekly7dResetUnix - $now

    # Format "resets in" text (compact format)
    $session5hResetsIn = if ($session5hRemaining -gt 0) {
        $hours = [math]::Floor($session5hRemaining / 3600)
        $minutes = [math]::Floor(($session5hRemaining % 3600) / 60)
        if ($hours -gt 0) { "$($hours)h$($minutes)m" } else { "$($minutes)m" }
    } else { "0m" }

    $weekly7dResetsIn = if ($weekly7dRemaining -gt 0) {
        $days = [math]::Floor($weekly7dRemaining / 86400)
        $hours = [math]::Floor(($weekly7dRemaining % 86400) / 3600)
        if ($days -gt 0) { "$($days)d$($hours)h" } else { "$($hours)h" }
    } else { "0h" }

    # Format reset time (as wall-clock and calendar)
    $session5hResetTime = ([datetime]::UnixEpoch.AddSeconds($session5hResetUnix).ToLocalTime()).ToString("h:mm tt")
    $weekly7dResetTime = ([datetime]::UnixEpoch.AddSeconds($weekly7dResetUnix).ToLocalTime()).ToString("ddd MMM d")

    # Write data files
    $baseDir = "$PSScriptRoot"
    "$session5h" | Out-File -FilePath "$baseDir\Session5h.txt" -Encoding UTF8 -NoNewline
    "$weekly7d" | Out-File -FilePath "$baseDir\Weekly7d.txt" -Encoding UTF8 -NoNewline
    "$session5hResetsIn" | Out-File -FilePath "$baseDir\Session5hResetsIn.txt" -Encoding UTF8 -NoNewline
    "$weekly7dResetsIn" | Out-File -FilePath "$baseDir\Weekly7dResetsIn.txt" -Encoding UTF8 -NoNewline
    "$session5hResetTime" | Out-File -FilePath "$baseDir\Session5hResetTime.txt" -Encoding UTF8 -NoNewline
    "$weekly7dResetTime" | Out-File -FilePath "$baseDir\Weekly7dResetTime.txt" -Encoding UTF8 -NoNewline

    # Refresh the Rainmeter skin
    $rainmeterPath = "C:\Program Files\Rainmeter\Rainmeter.exe"
    if (Test-Path $rainmeterPath) {
        & $rainmeterPath '!Refresh' '"ClaudeMeter"'
    }

    exit 0
}
catch {
    exit 1
}
