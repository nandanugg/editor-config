#!/bin/bash

set -euo pipefail

# Extract actions from Windows Terminal settings.json and save to local file
# This script should be run from WSL

echo "📋 Extracting Windows Terminal actions..."

# Get the Windows username and construct the path to Windows Terminal settings.json
WINDOWS_SETTINGS_PATH="/mnt/c/Users/$(powershell.exe -NoProfile -Command 'echo "$env:USERNAME"' 2>/dev/null | tr -d '\r' | sed 's/$//')/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"

if [ -f "$WINDOWS_SETTINGS_PATH" ]; then
  if command -v jq &> /dev/null; then
    jq '{actions: .actions}' "$WINDOWS_SETTINGS_PATH" > "$(pwd)/configs/windows-terminal-settings.json"
    echo "✅ Saved actions to configs/windows-terminal-settings.json"
  else
    echo "⚠️ jq is not installed. Skipping actions extraction."
    echo "   Install jq to extract Windows Terminal settings."
    echo ""
    echo "   On Debian/Ubuntu:"
    echo "     sudo apt install jq"
    echo "   On Arch:"
    echo "     sudo pacman -S jq"
    echo "   On macOS:"
    echo "     brew install jq"
  fi
else
  echo "⚠️ Windows Terminal settings.json not found at:"
  echo "   $WINDOWS_SETTINGS_PATH"
  echo ""
  echo "   Make sure Windows Terminal is installed and has been opened at least once."
fi