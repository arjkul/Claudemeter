# ClaudeMeter

A minimal Rainmeter skin that displays your Claude API usage in real-time.

## Features

- **5-hour usage limit** - Track your rolling 5-hour API usage
- **7-day usage limit** - Monitor your weekly usage across all models
- **Auto-updating** - Refreshes every 60 seconds via Windows Task Scheduler
- **Click to open Claude** - Click the widget to open claude.ai
- **Minimal design** - Clean, modern aesthetic that matches Claude's UI

## Installation

1. Clone this repository to your Rainmeter skins folder:
   ```
   C:\Users\{YourUsername}\Documents\Rainmeter\Skins\ClaudeMeter
   ```

2. Open Rainmeter and load the "Claude Usage" skin

3. The skin automatically reads your OAuth token from `~/.claude/.credentials.json`

## How It Works

- **UpdateUsage.ps1** - Fetches API usage via Claude API rate-limit headers
- **ReadSession5h.lua** & **ReadWeekly7d.lua** - Parse usage data
- **Windows Task Scheduler** - Runs updates every 60 seconds
- **ClaudeMeter.ini** - Skin configuration

## Requirements

- Windows with Rainmeter
- Claude Code installed and authenticated
- PowerShell 5.0+

## License

Creative Commons Attribution-Non-Commercial-Share Alike 3.0
