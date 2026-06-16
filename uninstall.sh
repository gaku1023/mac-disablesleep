#!/usr/bin/env bash
# Remove DisableSleep: restore normal sleep, deregister the login item,
# delete the app, and remove the sudoers rule.
set -euo pipefail

DEST="/Applications/DisableSleep.app"
BIN="$DEST/Contents/MacOS/DisableSleep"
SUDOERS_FILE="/etc/sudoers.d/mac-disablesleep"
BUNDLE_ID="co.alphatique.disablesleep"

# Confirm before doing anything destructive (interactive only).
if [[ -t 0 ]]; then
    read -r -p "DisableSleep をアンインストールします。よろしいですか? [y/N] " answer
    case "$answer" in
        [yY]*) ;;
        *) echo "中止しました。"; exit 0 ;;
    esac
fi

echo "==> Restoring normal sleep (disablesleep 0)"
sudo /usr/bin/pmset -a disablesleep 0 || true

# Deregister the login item BEFORE deleting the bundle, otherwise a stale
# entry can linger in System Settings → Login Items.
if [[ -x "$BIN" ]]; then
    echo "==> Removing login item"
    "$BIN" --unregister || true
fi

echo "==> Quitting DisableSleep if running"
osascript -e 'tell application "DisableSleep" to quit' 2>/dev/null || true
pkill -x DisableSleep 2>/dev/null || true

echo "==> Removing app"
rm -rf "$DEST"

echo "==> Clearing preferences"
defaults delete "$BUNDLE_ID" 2>/dev/null || true

echo "==> Removing sudoers rule (requires admin password)"
sudo rm -f "$SUDOERS_FILE"

echo "Done."
