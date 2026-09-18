#!/bin/bash

set -euo pipefail

APP_NAME="Reverse Scroll Wheel"
BUNDLE_ID="de.raudzis.ReverseScrollWheel"
VERSION="1.0.0"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/Sources/mouse-scroll-reverse.swift"

INSTALL_DIR="$HOME/Applications"
APP="$INSTALL_DIR/$APP_NAME.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
BINARY="$MACOS/ReverseScrollWheel"

echo
echo "Reverse Scroll Wheel"
echo "===================="
echo
echo "Version $VERSION"
echo

# ------------------------------------------------------------
# Requirements
# ------------------------------------------------------------

if ! command -v swiftc >/dev/null 2>&1; then
    echo "Error: Swift compiler not found."
    echo
    echo "Install the Xcode Command Line Tools first:"
    echo
    echo "    xcode-select --install"
    echo
    exit 1
fi

if [[ ! -f "$SOURCE" ]]; then
    echo "Error: Source file not found:"
    echo
    echo "    $SOURCE"
    echo
    exit 1
fi

# ------------------------------------------------------------
# Clean up legacy installation
# ------------------------------------------------------------

echo "Checking for legacy installation..."

LEGACY_PLISTS=(
    "$HOME/Library/LaunchAgents/de.raudzis.reverse-scroll-wheel.plist"
    "$HOME/Library/LaunchAgents/de.raudzis.mouse-scroll-reverse.plist"
)

for PLIST in "${LEGACY_PLISTS[@]}"; do

    if [[ -f "$PLIST" ]]; then

        echo "Removing legacy LaunchAgent:"
        echo "    $PLIST"

        launchctl bootout \
            "gui/$(id -u)" \
            "$PLIST" \
            >/dev/null 2>&1 || true

        rm -f "$PLIST"
    fi

done

rm -rf "$HOME/Library/Application Support/ReverseScrollWheel"
rm -rf "$HOME/Library/Logs/ReverseScrollWheel"

# ------------------------------------------------------------
# Stop existing version
# ------------------------------------------------------------

if pgrep -x ReverseScrollWheel >/dev/null 2>&1; then
    echo "Stopping running version..."
    pkill -x ReverseScrollWheel || true
    sleep 1
fi

# ------------------------------------------------------------
# Build application
# ------------------------------------------------------------

echo "Creating application bundle..."

rm -rf "$APP"

mkdir -p "$MACOS"

echo "Compiling Swift source..."

swiftc \
    "$SOURCE" \
    -o "$BINARY" \
    -framework Cocoa \
    -framework CoreGraphics

chmod 755 "$BINARY"

# ------------------------------------------------------------
# Info.plist
# ------------------------------------------------------------

echo "Creating Info.plist..."

cat > "$CONTENTS/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">

<plist version="1.0">
<dict>

    <key>CFBundleName</key>
    <string>$APP_NAME</string>

    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>

    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>

    <key>CFBundleExecutable</key>
    <string>ReverseScrollWheel</string>

    <key>CFBundlePackageType</key>
    <string>APPL</string>

    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>

    <key>CFBundleVersion</key>
    <string>1</string>

    <key>LSUIElement</key>
    <true/>

</dict>
</plist>
EOF

plutil -lint "$CONTENTS/Info.plist"

# ------------------------------------------------------------
# Done
# ------------------------------------------------------------

echo
echo "Installation complete."
echo
echo "Installed:"
echo
echo "    $APP"
echo
echo "Next steps:"
echo
echo "1. Open the application:"
echo
echo "    open \"$APP\""
echo
echo "2. Allow 'Reverse Scroll Wheel' in:"
echo
echo "    System Settings"
echo "    → Privacy & Security"
echo "    → Accessibility"
echo
echo "3. Add 'Reverse Scroll Wheel' to:"
echo
echo "    System Settings"
echo "    → General"
echo "    → Login Items & Extensions"
echo
echo "    → Open at Login"
echo