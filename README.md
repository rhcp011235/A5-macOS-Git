# A5 iOS Device Activation Bypass Tool

A macOS application for bypassing iCloud activation on A5 chip iOS devices.

## Overview

This tool provides activation bypass functionality for legacy A5 chip devices, allowing them to be used without iCloud activation. The application features a native macOS interface with real-time device detection and status monitoring.

## Supported Devices

This tool ONLY works with A5 chip devices running specific iOS versions:

### Devices
- iPhone 4S (iPhone4,1)
- iPad 2 WiFi (iPad2,1)
- iPad 2 GSM (iPad2,2)
- iPad 2 CDMA (iPad2,3)
- iPad 2 Mid 2012 (iPad2,4)
- iPad Mini WiFi (iPad2,5)
- iPad Mini GSM (iPad2,6)
- iPad Mini CDMA (iPad2,7)
- iPad 3 WiFi (iPad3,1)
- iPad 3 GSM (iPad3,2)
- iPad 3 CDMA (iPad3,3)
- iPod touch 5th generation (iPod5,1)

### iOS Versions
- iOS 8.4.1 (WiFi models only, cellular models have limited support)
- iOS 9.3.5
- iOS 9.3.6

**Note**: iPhone 5, 5c, 5s and newer devices use A6+ chips and are NOT supported by this tool.

## System Requirements

- macOS 10.14 (Mojave) or later
- Works on both Intel and Apple Silicon Macs
- Xcode 12.0 or later (for building from source)
- PHP (pre-installed on macOS)

## Features

- Native macOS Cocoa application with programmatic UI
- Universal binary support (ARM64 + x86_64)
- Automatic device detection via USB
- Real-time device information display
- Activation bypass for A5 devices
- Clean logging interface
- Device model identification
- iOS version detection
- Local backend server (no internet required for activation)
- Offline operation

## Installation

### For Users

1. Download the latest release
2. Extract the ZIP file
3. Right-click A5.app and select "Open"
4. Click "Open" in the security dialog (required for unsigned apps)

### For Developers

1. Clone this repository:
   ```bash
   git clone https://github.com/rhcp011235/A5-macOS.git
   cd A5-macOS
   ```

2. Build the project:
   ```bash
   ./build.sh
   ```

## Building from Source

### Quick Debug Build

```bash
./build.sh
./copy_resources.sh
open build/Build/Products/Debug/A5.app
```

### Release Build for Distribution

```bash
./package_for_distribution.sh
```

This creates a distribution-ready package in `dist/` directory.

### Build Scripts

- `build.sh` - Quick debug build for development
- `package_for_distribution.sh` - Release build with resources
- `copy_resources.sh` - Copies tools, payloads, and backend to app bundle
- `make_universal_tools.sh` - Creates universal binaries from separate architectures
- `build_release.sh` - Interactive build menu

## Usage

1. Launch A5.app
2. Connect your A5 device via USB
3. Trust the computer on your device if prompted
4. Wait for device detection (automatic, takes ~3 seconds)
5. Ensure device is on the Setup Assistant screen (not yet activated)
6. Click "Activate Your Device"
7. Wait for the activation process to complete (3-5 minutes)

The application will:
- Start a local backend server automatically
- Detect the connected device
- Verify it's an A5 chip device with supported iOS version
- Display device model and iOS version
- Perform activation bypass
- Show real-time progress
- Stop the backend server when complete

## Project Structure

```
A5-macOS/
├── A5/
│   ├── Controllers/          # View controllers
│   ├── Views/                # Custom UI components
│   ├── Services/             # Business logic services
│   ├── Models/               # Data models
│   ├── Utilities/            # Helper classes
│   ├── Resources/
│   │   ├── Tools/           # libimobiledevice binaries (universal)
│   │   ├── Payloads/        # Activation payload (SQLite database)
│   │   ├── backend/         # PHP server and device PLISTs
│   │   └── Assets.xcassets/ # App icons and assets
│   └── Supporting Files/     # Info.plist, etc.
├── A5.xcodeproj/            # Xcode project
└── *.sh                     # Build scripts
```

## Architecture

The application uses a programmatic UI approach without XIB/Storyboard files:

- **Controllers**: Manage application logic and UI updates
- **Services**: Handle device communication and activation
- **Models**: Data structures for device information
- **Views**: Custom UI components (buttons, progress bars, text views)

### Key Components

- `A5MainWindowController` - Main application window and UI
- `A5DeviceManager` - USB device detection and monitoring
- `A5ActivationService` - Activation bypass implementation with PHP server management
- `A5CommandExecutor` - Executes libimobiledevice commands
- `A5DeviceModelMapper` - Maps device identifiers to models

## Technical Details

### Universal Binaries

All binaries are built as universal (ARM64 + x86_64):
- App binary supports both architectures
- libimobiledevice tools are universal
- Works natively on Intel and Apple Silicon

### Device Detection

The application uses libimobiledevice tools:
- `idevice_id` - Lists connected devices
- `ideviceinfo` - Retrieves device information
- `idevicediagnostics` - Device diagnostics and MobileGestalt queries
- `afcclient` - File transfer to device

### Activation Process

The activation process uses a local backend server for complete offline operation:

1. Application starts local PHP server on localhost:8080
2. Uploads SQLite payload to device (/Downloads/downloads.28.sqlitedb)
3. Device restarts and reads the payload
4. Device contacts the local backend server
5. PHP server serves device-specific patched PLIST based on model and iOS version
6. Device updates MobileGestalt cache with patched data
7. Second device restart
8. Verification of MobileGestalt keys (hactivation, ShouldHactivate)
9. Final restart
10. Application stops the backend server
11. Device boots activated

### Backend Server

The application includes a built-in backend server system:
- PHP server runs locally during activation (no internet required)
- 31 device/iOS-specific patched PLIST files
- Serves correct PLIST based on device User-Agent
- Automatic start/stop during activation process

## Troubleshooting

### Device Not Detected

- Check USB connection
- Trust the computer on your device
- Try unplugging and reconnecting
- Restart the application

### Device Not Supported

- Only A5 chip devices are supported
- Verify your device model in the supported list above
- Check iOS version is 8.4.1, 9.3.5, or 9.3.6
- Newer devices (A6+) will not work

### Activation Fails

- Ensure device is on Setup Assistant screen (not yet activated)
- Check device is unlocked
- Verify iOS version is supported
- Try restarting the application
- Check logs for backend server errors

### Build Issues

- Ensure Xcode is installed
- Run `xcode-select --install` to install command line tools
- Clean build folder: `rm -rf build`
- Ensure PHP is available: `which php`

### Backend Server Issues

- Port 8080 must be available: `lsof -i :8080`
- PHP must be installed (default on macOS)
- Check app logs for "Backend server started" message

## Security & Privacy

- No data is collected or transmitted to external servers
- All processing happens locally on your Mac
- Device information stays on your machine
- Backend server runs locally (no internet connection required)
- Completely offline activation process

## License

Copyright 2026 RHCP011235. All rights reserved.

This tool is provided as-is for educational and legitimate device unlocking purposes only. Use at your own risk. The author is not responsible for any misuse or damage.

## Disclaimer

This software is intended for use on devices you own or have explicit permission to modify. Bypassing activation locks on devices you do not own may be illegal in your jurisdiction. Always ensure you have the right to modify any device before using this tool.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## Acknowledgments

- libimobiledevice project for iOS device communication
- A5_Bypass_OSS project for backend server implementation reference
- A5 community for research and testing

## Author

Created by RHCP011235

## Support

For issues, questions, or feature requests, please open an issue on GitHub.
