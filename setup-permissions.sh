#!/usr/bin/env bash
# Adds the minimal NOPASSWD sudoers rule so the DisableSleep menu bar toggle
# works without a password prompt. Safe to run on its own — use this if you
# installed a prebuilt DisableSleep.app from the Releases page.
#
# Run as your normal user (NOT with sudo). It asks for your password once.
set -euo pipefail

SUDOERS_FILE="/etc/sudoers.d/mac-disablesleep"
USER_NAME="$(whoami)"

if [[ "$USER_NAME" == "root" ]]; then
    echo "Please run this as your normal user, not with sudo." >&2
    exit 1
fi

echo "==> Configuring sudoers (requires admin password)"
TMP="$(mktemp)"
cat > "$TMP" <<EOF
# Added by mac-disablesleep.
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
echo "==> Permissions configured."
