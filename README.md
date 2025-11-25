# Discord Fishing Bot

An AutoHotkey v2 script for automating the `/fish` command in Discord, with features for buying items, workers, and adjusting the fishing interval. The script ensures commands are only sent in the specified Discord server and channel to avoid spamming elsewhere.

## Features
- Automated `/fish` sending at adjustable intervals.
- Pause/resume fishing.
- Automatic buying of fish, treasures, and workers.
- Channel-specific controls (e.g., interval adjustment only works in the correct channel).
- GUI for setting server and channel names on startup.
- Compiled executable for easy sharing and use without AutoHotkey installed.

## Installation
1. Go to [Releases](https://github.com/c9long/discord-fishing/releases) and download the latest executable (version 1.0.2 or higher) from the assets.
2. Run the downloaded `.exe` file.
3. On first run, a GUI will appear to set your Discord server name, channel name, and channel ID. These are saved in `config.ini`.
   - To get the Channel ID: Enable Developer Mode in Discord (Settings > Advanced), right-click the channel, and select 'Copy ID'.

## Usage
- Launch the exe.
- In the GUI, enter your server name, channel name, and channel ID, then click "Run Script".
- Switch to Discord and ensure you're in the specified channel.
- Use the hotkeys below to control the bot.
- Press `Esc` anytime to open the settings GUI and update configurations.

## Keyboard Shortcuts

| Shortcut | Function |
|----------|----------|
| `F2` | Toggle fishing pause/resume. When paused, stops sending `/fish` but keeps timers for buying. |
| `F6` | Buy a 10-minute worker (`/buy auto10m`). Sets a timer to buy another in 10 minutes. |
| `Ctrl+F6` | Buy normal items (`/buy fish5m` and `/buy treasure5m`). Sets a timer to repeat every 5 minutes. |
| `F7` | Buy a 30-minute worker (`/buy auto30m`). Sets a timer to buy another in 30 minutes. |
| `Ctrl+F7` | Buy expensive items (`/buy fish20m` and `/buy treasure20m`). Sets a timer to repeat every 20 minutes. |
| `F8` | Toggle auto `/fish` on/off. Starts/stops the fishing loop. |
| `=` | Increase fishing interval by 100ms (only works in the correct server/channel). Shows tooltip with new interval. |
| `-` | Decrease fishing interval by 100ms (minimum 100ms; only works in the correct server/channel). Shows tooltip with new interval. |
| `Esc` | Open the settings GUI to update server name, channel name, channel ID, and Discord executable. |

## Notes
- The script only sends commands when Discord is active and in the exact specified channel (based on window title).
- Buying functions include loops to ensure you're in the correct channel before sending commands.
- Tooltips provide feedback for actions.
- Default interval: 3300ms (3.3 seconds). Adjustable with `=` and `-`.
- Config is saved in `config.ini`; use the `Esc` key to open the settings GUI and update if needed, or exit and relaunch the script to trigger the initial GUI.

## Disclaimer
Use responsibly. Automating Discord commands may violate server rules—check with your community. This script is for educational purposes.

This script was written for the Virtual Fisher Discord application, which implements its own human verification Captcha. The script does not and will not attempt to automate the verification and it is the responsibility of the user to pause and verify accordingly.