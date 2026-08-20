#!/bin/zsh
# Termina installer / updater.
#
#   curl -fsSL https://raw.githubusercontent.com/naifuliang/termina/main/install.sh | zsh
#
# Downloads the newest release (previews included) with curl — which,
# unlike a browser, does not set the quarantine attribute — verifies its
# SHA-256 checksum, and installs it. Re-run the same command to update.
#
# Overrides:
#   TERMINA_INSTALL_DIR      target directory (default /Applications)
#   TERMINA_OPEN_APP         set 0 to skip launching after install
#   TERMINA_INSTALL_CONFIRM  set 1 to skip the confirmation prompt
#   TERMINA_RELEASE_TAG      install a specific tag instead of the newest
set -euo pipefail

APP_NAME="Termina"
REPO="naifuliang/termina"
INSTALL_DIR="${TERMINA_INSTALL_DIR:-/Applications}"
OPEN_APP="${TERMINA_OPEN_APP:-1}"
CONFIRM="${TERMINA_INSTALL_CONFIRM:-0}"
TAG="${TERMINA_RELEASE_TAG:-}"

WORK_DIR="$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/termina-install.XXXXXX")"
cleanup() { /bin/rm -rf "$WORK_DIR"; }
trap cleanup EXIT INT TERM

if [[ "$(/usr/bin/uname -s)" != "Darwin" ]]; then
    echo "error: $APP_NAME is a macOS app" >&2
    exit 1
fi
if [[ "$(/usr/bin/uname -m)" != "arm64" ]]; then
    echo "error: prebuilt binaries are Apple Silicon only — build from source:" >&2
    echo "       git clone https://github.com/$REPO && cd termina && ./scripts/make-app.sh" >&2
    exit 1
fi

echo "$APP_NAME installer"
echo ""
echo "This installer downloads the latest $APP_NAME release from GitHub,"
echo "verifies its SHA-256 checksum, and installs it into $INSTALL_DIR."
echo ""
if [[ "$CONFIRM" != "1" ]]; then
    read "REPLY?Continue? [y/N] " </dev/tty
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

if [[ -z "$TAG" ]]; then
    echo "Resolving the newest release…"
    TAG="$(/usr/bin/curl --fail --silent --show-error --location \
        "https://api.github.com/repos/$REPO/releases?per_page=1" |
        /usr/bin/grep -m1 '"tag_name"' | /usr/bin/cut -d'"' -f4)"
fi
if [[ -z "$TAG" ]]; then
    echo "error: could not determine the release to install" >&2
    exit 1
fi
echo "Installing $APP_NAME $TAG"

ASSET="$APP_NAME-$TAG-arm64.zip"
BASE="https://github.com/$REPO/releases/download/$TAG"
ARCHIVE_PATH="$WORK_DIR/$ASSET"
CHECKSUM_PATH="$ARCHIVE_PATH.sha256"

echo "Downloading…"
/usr/bin/curl --fail --silent --show-error --location "$BASE/$ASSET" --output "$ARCHIVE_PATH"
/usr/bin/curl --fail --silent --show-error --location "$BASE/$ASSET.sha256" --output "$CHECKSUM_PATH"

EXPECTED_HASH="$(/usr/bin/awk 'NF { print $1; exit }' "$CHECKSUM_PATH")"
if ! /usr/bin/printf '%s\n' "$EXPECTED_HASH" | /usr/bin/grep -Eq '^[[:xdigit:]]{64}$'; then
    echo "The release checksum file is invalid. Installation stopped." >&2
    exit 1
fi
ACTUAL_HASH="$(/usr/bin/shasum -a 256 "$ARCHIVE_PATH" | /usr/bin/awk '{ print $1 }')"
if [[ "${ACTUAL_HASH:l}" != "${EXPECTED_HASH:l}" ]]; then
    echo "The downloaded archive failed its SHA-256 check. Installation stopped." >&2
    exit 1
fi

/usr/bin/ditto -x -k "$ARCHIVE_PATH" "$WORK_DIR/unpacked"
if [[ ! -d "$WORK_DIR/unpacked/$APP_NAME.app" ]]; then
    echo "error: archive did not contain $APP_NAME.app" >&2
    exit 1
fi

if [[ ! -w "$INSTALL_DIR" ]]; then
    INSTALL_DIR="$HOME/Applications"
    /bin/mkdir -p "$INSTALL_DIR"
    echo "note: /Applications is not writable — installing to $INSTALL_DIR"
fi

echo "Installing to $INSTALL_DIR/$APP_NAME.app…"
/bin/rm -rf "$INSTALL_DIR/$APP_NAME.app"
/usr/bin/ditto "$WORK_DIR/unpacked/$APP_NAME.app" "$INSTALL_DIR/$APP_NAME.app"
# belt and braces: clear quarantine in case the archive came via a browser
/usr/bin/xattr -dr com.apple.quarantine "$INSTALL_DIR/$APP_NAME.app" 2>/dev/null || true

echo "✓ $APP_NAME $TAG installed"
if [[ "$OPEN_APP" == "1" ]]; then
    /usr/bin/open "$INSTALL_DIR/$APP_NAME.app"
fi
