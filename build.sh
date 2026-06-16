#!/usr/bin/env bash
# Build DisableSleep.app from the Swift package.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$ROOT/DisableSleep.app"
CONTENTS="$APP/Contents"

echo "==> swift build -c release"
swift build -c release --package-path "$ROOT"

BIN="$(swift build -c release --package-path "$ROOT" --show-bin-path)/DisableSleep"

# Generate the app icon if it is missing.
if [[ ! -f "$ROOT/Resources/AppIcon.icns" ]]; then
    echo "==> Generating AppIcon.icns"
    ( cd "$ROOT" && swift scripts/make-icon.swift >/dev/null )
    ICONSET="$ROOT/AppIcon.iconset"
    rm -rf "$ICONSET"; mkdir "$ICONSET"
    for s in 16 32 128 256 512; do
        sips -z "$s" "$s" "$ROOT/icon_master.png" --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
        d=$((s * 2))
        sips -z "$d" "$d" "$ROOT/icon_master.png" --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
    done
    iconutil -c icns "$ICONSET" -o "$ROOT/Resources/AppIcon.icns"
    rm -rf "$ICONSET" "$ROOT/icon_master.png"
fi

echo "==> Assembling app bundle"
rm -rf "$APP"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources"
cp "$BIN" "$CONTENTS/MacOS/DisableSleep"
cp "$ROOT/Resources/Info.plist" "$CONTENTS/Info.plist"
cp "$ROOT/Resources/AppIcon.icns" "$CONTENTS/Resources/AppIcon.icns"

# Ad-hoc sign so Gatekeeper treats it as a stable identity locally.
codesign --force --deep --sign - "$APP" 2>/dev/null || true

echo "==> Built $APP"
