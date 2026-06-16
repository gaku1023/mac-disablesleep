#!/usr/bin/env bash
# Remove DisableSleep and its sudoers rule. Also restores normal sleep.
set -euo pipefail

DEST="/Applications/DisableSleep.app"
SUDOERS_FILE="/etc/sudoers.d/mac-disablesleep"

echo "==> Restoring normal sleep (disablesleep 0)"
sudo /usr/bin/pmset -a disablesleep 0 || true

echo "==> Quitting DisableSleep if running"
osascript -e 'tell application "DisableSleep" to quit' 2>/dev/null || true
pkill -x DisableSleep 2>/dev/null || true

echo "==> Removing app"
rm -rf "$DEST"

echo "==> Removing sudoers rule (requires admin password)"
sudo rm -f "$SUDOERS_FILE"

echo "Done."
