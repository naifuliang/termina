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

echo "▸ building DMG"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")"
DMG="$ROOT/dist/Termina-v$VERSION-arm64.dmg"
STAGING="$ROOT/dist/dmg-staging"
rm -rf "$STAGING" "$DMG"
mkdir -p "$STAGING"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
hdiutil create -volname "Termina" -srcfolder "$STAGING" -ov -format UDZO "$DMG" >/dev/null
rm -rf "$STAGING"

echo "✓ $APP"
echo "✓ $DMG"
