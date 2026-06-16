#!/usr/bin/env bash
# Build DisableSleep.app from the Swift package.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$ROOT/DisableSleep.app"
CONTENTS="$APP/Contents"

echo "==> swift build -c release"
swift build -c release --package-path "$ROOT"

BIN="$(swift build -c release --package-path "$ROOT" --show-bin-path)/DisableSleep"

echo "==> Assembling app bundle"
rm -rf "$APP"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources"
cp "$BIN" "$CONTENTS/MacOS/DisableSleep"
cp "$ROOT/Resources/Info.plist" "$CONTENTS/Info.plist"

# Ad-hoc sign so Gatekeeper treats it as a stable identity locally.
codesign --force --deep --sign - "$APP" 2>/dev/null || true

echo "==> Built $APP"
