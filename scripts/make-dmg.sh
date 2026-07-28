#!/bin/zsh
# Builds a styled drag-to-install DMG from dist/Termina.app using dmgbuild
# (writes the Finder layout directly — no Finder scripting involved).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/Termina.app"
[ -d "$APP" ] || { echo "error: $APP not found — run make-app.sh first" >&2; exit 1; }

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")"
DMG="$ROOT/dist/Termina-v$VERSION-arm64.dmg"
WORK="$ROOT/dist/dmg-work"

echo "▸ rendering DMG background"
rm -rf "$WORK"
mkdir -p "$WORK"
swift "$ROOT/scripts/gen_dmg_background.swift" "$WORK" >/dev/null
tiffutil -cathidpicheck "$WORK/dmg-background.png" "$WORK/dmg-background@2x.png" \
  -out "$WORK/dmg-background.tiff" 2>/dev/null

echo "▸ locating dmgbuild"
DMGBUILD="$(command -v dmgbuild || true)"
if [ -z "$DMGBUILD" ]; then
  VENV="$ROOT/.build/dmg-venv"
  if [ ! -x "$VENV/bin/dmgbuild" ]; then
    python3 -m venv "$VENV"
    "$VENV/bin/pip" -q install dmgbuild
  fi
  DMGBUILD="$VENV/bin/dmgbuild"
fi

echo "▸ building $DMG"
rm -f "$DMG"
"$DMGBUILD" -s "$ROOT/scripts/dmg_settings.py" \
  -D app="$APP" \
  -D background="$WORK/dmg-background.tiff" \
  -D icns="$ROOT/dist/AppIcon.icns" \
  "Termina" "$DMG"
rm -rf "$WORK"

echo "✓ $DMG"
