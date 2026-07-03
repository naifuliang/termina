#!/bin/zsh
# Builds Termina.app into dist/
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/Termina.app"
CONFIG="${1:-release}"

echo "▸ swift build -c $CONFIG"
cd "$ROOT"
swift build -c "$CONFIG"

BIN="$(swift build -c "$CONFIG" --show-bin-path)/Termina"

echo "▸ assembling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/Termina"
cp "$ROOT/scripts/Info.plist" "$APP/Contents/Info.plist"

if ! [ -f "$ROOT/dist/AppIcon.icns" ]; then
  echo "▸ generating icon"
  ICONSET="$ROOT/dist/AppIcon.iconset"
  swift "$ROOT/scripts/gen_icon.swift" "$ICONSET"
  iconutil -c icns "$ICONSET" -o "$ROOT/dist/AppIcon.icns"
  rm -rf "$ICONSET"
fi
cp "$ROOT/dist/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"

echo "▸ codesign (ad-hoc)"
codesign --force --sign - "$APP"

echo "✓ $APP"
