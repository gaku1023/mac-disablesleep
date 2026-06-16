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
SUDOERS_FILE="/etc/sudoers.d/mac-disablesleep"
USER_NAME="$(whoami)"

if [[ "$USER_NAME" == "root" ]]; then
    echo "Please run install.sh as your normal user, not with sudo." >&2
    exit 1
fi

# 1. Build the app bundle.
"$ROOT/build.sh"

# 2. Install to /Applications.
echo "==> Installing to $DEST"
rm -rf "$DEST"
cp -R "$ROOT/$APP_NAME" "$DEST"

# 3. Add the NOPASSWD rule, scoped to exactly the two commands we run.
echo "==> Configuring sudoers (requires admin password)"
TMP="$(mktemp)"
cat > "$TMP" <<EOF
# Added by mac-disablesleep installer.
# Allows $USER_NAME to toggle pmset disablesleep without a password.
$USER_NAME ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1
EOF

# Validate syntax before installing — never write a broken sudoers file.
if ! sudo visudo -cf "$TMP" >/dev/null; then
    echo "sudoers validation failed; aborting." >&2
    rm -f "$TMP"
    exit 1
fi

sudo install -m 0440 -o root -g wheel "$TMP" "$SUDOERS_FILE"
rm -f "$TMP"

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
