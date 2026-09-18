#!/bin/bash

set -euo pipefail

# ============================================================
# Reverse Scroll Wheel Installer
# ============================================================

APP_NAME="Reverse Scroll Wheel"
BUNDLE_ID="de.raudzis.ReverseScrollWheel"
VERSION="1.0.0"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SOURCE="$SCRIPT_DIR/Sources/mouse-scroll-reverse.swift"
ICON_SOURCE="$SCRIPT_DIR/Assets/AppIcon.png"

INSTALL_DIR="$HOME/Applications"
APP="$INSTALL_DIR/$APP_NAME.app"

CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

BINARY="$MACOS/ReverseScrollWheel"
ICON="$RESOURCES/AppIcon.icns"

ICONSET="$SCRIPT_DIR/.AppIcon.iconset"


echo
echo "Reverse Scroll Wheel"
echo "===================="
echo
echo "Version $VERSION"
echo


# ============================================================
# Requirements
# ============================================================

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


if [[ ! -f "$ICON_SOURCE" ]]; then
    echo "Error: App icon not found:"
    echo
    echo "    $ICON_SOURCE"
    echo
    exit 1
fi


# ============================================================
# Clean up legacy installation
# ============================================================

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


# ============================================================
# Stop existing application
# ============================================================

if pgrep -x ReverseScrollWheel >/dev/null 2>&1; then

    echo "Stopping running version..."

    pkill -x ReverseScrollWheel || true

    sleep 1

fi


# ============================================================
# Create application bundle
# ============================================================

echo "Creating application bundle..."

rm -rf "$APP"

mkdir -p "$MACOS"
mkdir -p "$RESOURCES"


# ============================================================
# Compile Swift
# ============================================================

echo "Compiling Swift source..."

swiftc \
    "$SOURCE" \
    -o "$BINARY" \
    -framework Cocoa \
    -framework CoreGraphics

chmod 755 "$BINARY"


# ============================================================
# Create application icon
# ============================================================

echo "Creating application icon..."

rm -rf "$ICONSET"

mkdir -p "$ICONSET"


# 16 × 16

sips -z 16 16 \
    "$ICON_SOURCE" \
    --out "$ICONSET/icon_16x16.png" \
    >/dev/null


# 16 × 16 @2x = 32 × 32

sips -z 32 32 \
    "$ICON_SOURCE" \
    --out "$ICONSET/icon_16x16@2x.png" \
    >/dev/null


# 32 × 32

sips -z 32 32 \
    "$ICON_SOURCE" \
    --out "$ICONSET/icon_32x32.png" \
    >/dev/null


# 32 × 32 @2x = 64 × 64

sips -z 64 64 \
    "$ICON_SOURCE" \
    --out "$ICONSET/icon_32x32@2x.png" \
    >/dev/null


# 128 × 128

sips -z 128 128 \
    "$ICON_SOURCE" \
    --out "$ICONSET/icon_128x128.png" \
    >/dev/null


# 128 × 128 @2x = 256 × 256

sips -z 256 256 \
    "$ICON_SOURCE" \
    --out "$ICONSET/icon_128x128@2x.png" \
    >/dev/null


# 256 × 256

sips -z 256 256 \
    "$ICON_SOURCE" \
    --out "$ICONSET/icon_256x256.png" \
    >/dev/null


# 256 × 256 @2x = 512 × 512

sips -z 512 512 \
    "$ICON_SOURCE" \
    --out "$ICONSET/icon_256x256@2x.png" \
    >/dev/null


# 512 × 512

sips -z 512 512 \
    "$ICON_SOURCE" \
    --out "$ICONSET/icon_512x512.png" \
    >/dev/null


# 512 × 512 @2x = 1024 × 1024

sips -z 1024 1024 \
    "$ICON_SOURCE" \
    --out "$ICONSET/icon_512x512@2x.png" \
    >/dev/null


# Build .icns

iconutil \
    -c icns \
    "$ICONSET" \
    -o "$ICON"


# Remove temporary iconset

rm -rf "$ICONSET"


# ============================================================
# Create Info.plist
# ============================================================

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

    <key>CFBundleIconFile</key>
    <string>AppIcon</string>

    <!--
        Run as an agent application.

        This prevents the application from appearing
        in the Dock or application switcher.
    -->

    <key>LSUIElement</key>
    <true/>

</dict>

</plist>
EOF


# ============================================================
# Validate application
# ============================================================

echo "Validating Info.plist..."

plutil -lint "$CONTENTS/Info.plist"


# ============================================================
# Finished
# ============================================================

echo
echo "Installation complete."
echo
echo "Installed application:"
echo
echo "    $APP"
echo
echo
echo "Application icon:"
echo
echo "    $ICON"
echo
echo
echo "Next steps:"
echo
echo "1. Start Reverse Scroll Wheel:"
echo
echo "    open \"$APP\""
echo
echo
echo "2. Allow Reverse Scroll Wheel in:"
echo
echo "    System Settings"
echo "    → Privacy & Security"
echo "    → Accessibility"
echo
echo
echo "3. Add Reverse Scroll Wheel to:"
echo
echo "    System Settings"
echo "    → General"
echo "    → Login Items & Extensions"
echo "    → Open at Login"
echo