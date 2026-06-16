#!/usr/bin/env bash
# Install DisableSleep: build the app, copy to /Applications, and add a
# minimal NOPASSWD sudoers rule so the menu bar toggle works without a
# password prompt.
#
# Run as your normal user (NOT with sudo). It will ask for your password
# once when it needs root.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="DisableSleep.app"
DEST="/Applications/$APP_NAME"

if [[ "$(whoami)" == "root" ]]; then
    echo "Please run install.sh as your normal user, not with sudo." >&2
    exit 1
fi

# 1. Build the app bundle.
"$ROOT/build.sh"

# 2. Install to /Applications.
echo "==> Installing to $DEST"
rm -rf "$DEST"
cp -R "$ROOT/$APP_NAME" "$DEST"

# 3. Add the NOPASSWD sudoers rule (shared with the prebuilt path).
"$ROOT/setup-permissions.sh"

echo ""
echo "Done. DisableSleep is installed."
echo "A sun/moon icon appears in the menu bar — click it to toggle."
echo "(It will also launch automatically at login by default; toggle that"
echo " from the menu's \"Launch at login\" item.)"

# Offer to launch now. Default Yes; skip silently if not interactive.
if [[ -t 0 ]]; then
    read -r -p "Launch DisableSleep now? [Y/n] " answer
    case "$answer" in
        [nN]*) echo "You can launch it later from /Applications or Spotlight." ;;
        *)     open -a DisableSleep && echo "Launched." ;;
    esac
fi
