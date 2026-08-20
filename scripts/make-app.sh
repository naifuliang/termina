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

BUNDLE_DIR="$(swift build -c "$CONFIG" --show-bin-path)/Termina_Termina.bundle"
if [ -d "$BUNDLE_DIR" ]; then
  cp -R "$BUNDLE_DIR" "$APP/Contents/Resources/"
fi

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

"$ROOT/scripts/make-dmg.sh"

echo "▸ zipping"
VERSION="${TERMINA_VERSION_LABEL:-$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")}"
ZIP="$ROOT/dist/Termina-v$VERSION-arm64.zip"
rm -f "$ZIP" "$ZIP.sha256"
ditto -c -k --keepParent "$APP" "$ZIP"
( cd "$ROOT/dist" && /usr/bin/shasum -a 256 "$(basename "$ZIP")" > "$(basename "$ZIP").sha256" )

echo "✓ $APP"
echo "✓ $ZIP"
