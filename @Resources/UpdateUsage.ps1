# UpdateUsage.ps1 - Fetch Claude usage via OAuth token and save to file
# Run this every 60 seconds via Windows Task Scheduler

$credPath = "$env:USERPROFILE\.claude\.credentials.json"
$outputFile = "$PSScriptRoot\UsageData.txt"

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

    # Extract rate-limit headers
    $session5h = if ($response.Headers["anthropic-ratelimit-unified-5h-utilization"]) {
        [math]::Round([float]$response.Headers["anthropic-ratelimit-unified-5h-utilization"] * 100, 1)
    } else { 0 }

    $weekly7d = if ($response.Headers["anthropic-ratelimit-unified-7d-utilization"]) {
        [math]::Round([float]$response.Headers["anthropic-ratelimit-unified-7d-utilization"] * 100, 1)
    } else { 0 }

    # Write to separate files for each value
    $baseDir = "$PSScriptRoot"
    "$session5h" | Out-File -FilePath "$baseDir\Session5h.txt" -Encoding UTF8 -NoNewline
    "$weekly7d" | Out-File -FilePath "$baseDir\Weekly7d.txt" -Encoding UTF8 -NoNewline

    # Also write to .inc file that Rainmeter can include directly
    $incContent = "[Variables]`nSession5hValue=$session5h`nWeekly7dValue=$weekly7d"
    $incContent | Out-File -FilePath "$baseDir\UsageVars.inc" -Encoding UTF8 -NoNewline

    # Refresh the Rainmeter skin to reload variables
    $rainmeterPath = "C:\Program Files\Rainmeter\Rainmeter.exe"
    if (Test-Path $rainmeterPath) {
        & $rainmeterPath '!Refresh' '"ClaudeMeter"'
    }

    exit 0
}
catch {
    "0|0" | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
    exit 1
}
