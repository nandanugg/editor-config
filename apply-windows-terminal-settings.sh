#!/bin/bash

set -euo pipefail

# Apply actions from local file to Windows Terminal settings.json
# This script should be run from WSL

echo "📋 Applying Windows Terminal actions and keybindings..."

LOCAL_SETTINGS_FILE="$(pwd)/configs/windows-terminal-settings.json"

# Check if local settings file exists
if [ ! -f "$LOCAL_SETTINGS_FILE" ]; then
  echo "⚠️ windows-terminal-settings.json not found at:"
  echo "   $LOCAL_SETTINGS_FILE"
  echo ""
  echo "   Run extract-windows-terminal-settings.sh first to extract the settings."
  exit 1
fi

if command -v jq &> /dev/null; then
  # Backup the original settings.json
  WINDOWS_SETTINGS_PATH="/mnt/c/Users/$(powershell.exe -NoProfile -Command 'echo "$env:USERNAME"' 2>/dev/null | tr -d '\r' | sed 's/$//')/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"

  if [ ! -f "$WINDOWS_SETTINGS_PATH" ]; then
    echo "⚠️ Windows Terminal settings.json not found at:"
    echo "   $WINDOWS_SETTINGS_PATH"
    exit 1
  fi

  # Create backup
  BACKUP_PATH="${WINDOWS_SETTINGS_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$WINDOWS_SETTINGS_PATH" "$BACKUP_PATH"
  echo "✅ Backed up settings.json to $BACKUP_PATH"

  # Apply the actions from local file to Windows settings.json
  # Keep everything except actions, then merge with local actions
  jq --slurpfile local "$LOCAL_SETTINGS_FILE" '. + $local[0]' "$WINDOWS_SETTINGS_PATH" > "${WINDOWS_SETTINGS_PATH}.tmp"

  # Move the temporary file to the actual settings path
  mv "${WINDOWS_SETTINGS_PATH}.tmp" "$WINDOWS_SETTINGS_PATH"

  echo "✅ Applied actions and keybindings from windows-terminal-settings.json to Windows Terminal"
  echo ""
  echo "ℹ️  Restart Windows Terminal for changes to take effect"
else
  echo "⚠️ jq is not installed. Skipping actions extraction."
  echo "   Install jq to apply Windows Terminal settings."
  echo ""
  echo "   On Debian/Ubuntu:"
  echo "     sudo apt install jq"
  echo "   On Arch:"
  echo "     sudo pacman -S jq"
  echo "   On macOS:"
  echo "     brew install jq"
fi