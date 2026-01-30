# Quick Start Guide

## For Users

1. Download and extract the latest release

2. Open the app (first time):
   - Right-click A5.app
   - Select "Open"
   - Click "Open" in the security dialog

3. Use the tool:
   - Connect your A5 device via USB
   - Trust the computer on your device
   - Wait for device detection
   - Ensure device is on Setup Assistant screen
   - Click "Activate Your Device"

## For Developers

### Quick Build

```bash
# Clone the repository
git clone <your-repo-url>
cd A5-macOS

# Build for testing
./build.sh
./copy_resources.sh

# Run the app
open build/Build/Products/Debug/A5.app
```

### Create Distribution Package

```bash
# Build release version
./package_for_distribution.sh

# Find the package
ls -lh dist/
```

The distribution package will be created in the `dist/` directory.

### Build Scripts

- `./build.sh` - Quick debug build
- `./package_for_distribution.sh` - Release build with all resources
- `./build_release.sh` - Interactive menu to choose build type
- `./copy_resources.sh` - Helper script (called by other scripts)

## Supported Devices

Only A5 chip devices:
- iPhone 4S (iPhone4,1)
- iPad 2 all models (iPad2,1 - iPad2,7)
- iPad 3 all models (iPad3,1 - iPad3,3)
- iPad Mini 1st Gen (iPad2,5 - iPad2,7)
- iPod touch 5th Gen (iPod5,1)

**Note**: iPhone 5, 5c, 5s are NOT supported (A6+ chips).

### Supported iOS Versions
- iOS 8.4.1 (WiFi models only)
- iOS 9.3.5
- iOS 9.3.6

## Requirements

- macOS 10.14 or later
- Xcode 12.0 or later (for building from source)
- PHP (pre-installed on macOS)
- Universal binary (works on Intel and Apple Silicon)

**Note**: libimobiledevice tools are bundled with the app, no separate installation required.

## Troubleshooting

If device is not detected:
```bash
# Restart the app and reconnect device
# Check USB cable connection
# Trust computer on device
```

If build fails:
```bash
rm -rf build
./build.sh
```

If backend server fails to start:
```bash
# Check PHP is available
which php

# Check port 8080 is available
lsof -i :8080
```

## License

Copyright 2026 RHCP011235. All rights reserved.
