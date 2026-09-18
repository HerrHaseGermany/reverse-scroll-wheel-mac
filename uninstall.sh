#!/bin/bash

set -euo pipefail

APP_NAME="Reverse Scroll Wheel"

APP="$HOME/Applications/$APP_NAME.app"

echo
echo "Reverse Scroll Wheel Uninstaller"
echo "================================"
echo

if pgrep -x ReverseScrollWheel >/dev/null 2>&1; then
    echo "Stopping Reverse Scroll Wheel..."
    pkill -x ReverseScrollWheel || true
fi

if [[ -d "$APP" ]]; then
    echo "Removing:"
    echo "    $APP"

    rm -rf "$APP"
else
    echo "Application is not installed."
fi

# Remove files from older versions of the project.

LEGACY_PLISTS=(
    "$HOME/Library/LaunchAgents/de.raudzis.reverse-scroll-wheel.plist"
    "$HOME/Library/LaunchAgents/de.raudzis.mouse-scroll-reverse.plist"
)

for PLIST in "${LEGACY_PLISTS[@]}"; do

    if [[ -f "$PLIST" ]]; then

        launchctl bootout \
            "gui/$(id -u)" \
            "$PLIST" \
            >/dev/null 2>&1 || true

        rm -f "$PLIST"
    fi

done

rm -rf "$HOME/Library/Application Support/ReverseScrollWheel"
rm -rf "$HOME/Library/Logs/ReverseScrollWheel"

echo
echo "Uninstallation complete."
echo
echo "You can also remove Reverse Scroll Wheel from:"
echo
echo "    System Settings"
echo "    → Privacy & Security"
echo "    → Accessibility"
echo
echo "and:"
echo
echo "    System Settings"
echo "    → General"
echo "    → Login Items & Extensions"
echo