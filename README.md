# Reverse Scroll Wheel

A tiny native macOS utility that reverses the scrolling direction of a traditional mouse wheel while leaving trackpad scrolling untouched.

It is designed for users who prefer macOS **Natural Scrolling** on their trackpad but want a conventional mouse wheel to scroll in the opposite direction.

## Features

- Reverses traditional mouse wheel scrolling
- Leaves trackpad scrolling unchanged
- Supports vertical and horizontal mouse wheel scrolling
- Runs silently in the background
- No Dock icon
- No menu bar icon
- No third-party dependencies
- No daemon or LaunchAgent required
- Native Swift implementation

## How it works

macOS distinguishes between continuous and line-based scroll events.

Trackpads normally generate continuous, pixel-based scroll events, while traditional mouse wheels normally generate line-based scroll events.

Reverse Scroll Wheel listens for scroll events using CoreGraphics and reverses only line-based events.

| Input device | Behaviour |
| --- | --- |
| MacBook Trackpad | unchanged |
| Magic Trackpad | unchanged |
| Traditional mouse wheel | reversed |
| Horizontal mouse wheel | reversed |

## Requirements

- macOS
- Xcode Command Line Tools

Check whether the Swift compiler is available:

```bash
swiftc --version
```

If it is not installed:

```bash
xcode-select --install
```

## Installation

Clone the repository:

```bash
git clone <repository-url>
```

Enter the repository:

```bash
cd "reverse scroll wheel mac"
```

Make the installer executable:

```bash
chmod +x install.sh uninstall.sh
```

Install:

```bash
./install.sh
```

The application will be installed to:

```text
~/Applications/Reverse Scroll Wheel.app
```

No administrator privileges are required.

## First Launch

Start the application:

```bash
open "$HOME/Applications/Reverse Scroll Wheel.app"
```

macOS requires Accessibility permission because the application needs to intercept and modify scroll wheel events.

Open:

```text
System Settings
→ Privacy & Security
→ Accessibility
```

Add or enable:

```text
Reverse Scroll Wheel
```

Then start the application again if necessary.

## Start Automatically at Login

Open:

```text
System Settings
→ General
→ Login Items & Extensions
→ Open at Login
```

Add:

```text
Reverse Scroll Wheel.app
```

The application will then start automatically whenever you log in.

## Check Whether It Is Running

Run:

```bash
pgrep -fl ReverseScrollWheel
```

A running installation should show something similar to:

```text
1234 /Users/username/Applications/Reverse Scroll Wheel.app/Contents/MacOS/ReverseScrollWheel
```

## Stop

To stop Reverse Scroll Wheel:

```bash
pkill -x ReverseScrollWheel
```

Start it again with:

```bash
open "$HOME/Applications/Reverse Scroll Wheel.app"
```

## Uninstall

Run:

```bash
./uninstall.sh
```

The uninstaller removes the application and files from older versions of Reverse Scroll Wheel.

You may also remove the application manually from:

```text
System Settings
→ Privacy & Security
→ Accessibility
```

and:

```text
System Settings
→ General
→ Login Items & Extensions
```

## Project Structure

```text
.
├── README.md
├── LICENSE
├── Sources
│   └── mouse-scroll-reverse.swift
├── install.sh
└── uninstall.sh
```

## Privacy

Reverse Scroll Wheel runs entirely locally.

It does not:

- connect to the internet
- collect analytics
- store user data
- transmit input events
- require an account

The application only observes scroll wheel events required to determine whether they should be reversed.

## License

MIT