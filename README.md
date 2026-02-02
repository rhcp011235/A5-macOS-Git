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
- Device must be connected to WiFi for remote backend activation
- No internet required for local backend activation

## Features

- Native macOS Cocoa application with programmatic UI
- Universal binary support (ARM64 + x86_64)
- Automatic device detection via USB
- Real-time device information display
- Activation bypass for A5 devices
- Clean logging interface with verbose mode toggle
- Device model identification
- iOS version detection
- **Three backend server options:**
  - **Remote (nothingtool.com)** - Default, proven to work 100%
  - **Remote (mrcellphoneunlocker.com)** - User-controlled backup server
  - **Local (USB Network)** - Fully offline, no internet required
- Native HTTP backend server (no PHP required)
- Automatic log file saving to Desktop
- Complete offline operation with local backend

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
3. **Ensure device is connected to WiFi** (required for activation)
4. Trust the computer on your device if prompted
5. Wait for device detection (automatic, takes ~3 seconds)
6. Ensure device is on the Setup Assistant screen (not yet activated)
7. **Select backend server** (dropdown menu):
   - **nothingtool.com** - Default, requires device internet access
   - **mrcellphoneunlocker.com** - Backup server, requires device internet access
   - **Local (Experimental)** - Offline mode, uses USB network (Mac.local)
8. **(Optional)** Toggle "Verbose Logging" for detailed debug output
9. Click "Activate Your Device"
10. Wait for the activation process to complete (3-5 minutes)

The application will:
- Detect the connected device
- Verify it's an A5 chip device with supported iOS version
- Display device model and iOS version
- Start backend server (if using local backend)
- Transfer activation payload to device
- Restart device twice
- Verify activation via MobileGestalt
- Save complete log to Desktop
- Show real-time progress

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

- `A5MainWindowController` - Main application window and UI with backend selector
- `A5DeviceManager` - USB device detection and monitoring
- `A5ActivationService` - Activation bypass implementation with backend management
- `A5BackendServer` - Native HTTP server for local backend (no PHP)
- `A5AFCClient` - Native AFC protocol implementation for file transfers
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
- Native AFC protocol - File transfers to device (implemented in Objective-C)

### Activation Process

1. **Payload Preparation**: SQLite payload URL is dynamically configured based on selected backend
2. **Payload Transfer**: Native AFC protocol transfers payload to `/Downloads/downloads.28.sqlitedb`
3. **First Restart**: Device reboots and executes payload via itunesstored/bookassetd exploit
4. **Payload Execution**: Device fetches activation plist from selected backend server
5. **MobileGestalt Modification**: Payload writes patched data to MobileGestalt cache
6. **Second Restart**: Device reboots to apply changes
7. **Verification**: App checks MobileGestalt keys (hactivation, ShouldHactivate)
8. **Final Restart**: Device reboots activated
9. **Log Saved**: Complete activation log saved to Desktop

### Backend Server Options

**Three backend modes available:**

#### 1. Remote Backend (nothingtool.com) - Default
- URL: `https://nothingtool.com/invoice.php`
- Requires device WiFi + internet access
- Proven to work 100%
- No Mac configuration needed

#### 2. Remote Backend (mrcellphoneunlocker.com) - Backup
- URL: `http://mrcellphoneunlocker.com/A5/invoice.php`
- User-controlled server (backup option)
- Requires device WiFi + internet access
- No SSL certificate required (uses HTTP)

#### 3. Local Backend (USB Network) - Offline
- URL: `http://Mac.local:8080/server.php`
- **Fully offline** - no internet required!
- Native HTTP server (Objective-C, not PHP)
- Binds to all network interfaces (0.0.0.0:8080)
- Device connects via USB network interface
- Uses mDNS/Bonjour for Mac.local resolution
- Same technology as SSH over USB
- **No iproxy needed** - uses built-in macOS USB networking
- 31 device/iOS-specific patched PLIST files
- Serves correct PLIST based on device User-Agent
- Automatic start/stop during activation process

**How Local Backend Works:**
- macOS creates USB network interface when iOS device connects
- Backend server listens on all interfaces (not just 127.0.0.1)
- Device resolves Mac.local via mDNS over USB
- Device makes HTTP GET request to fetch activation plist
- No port conflicts, no iproxy complexity
- True peer-to-peer networking over USB

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

- **Ensure device is connected to WiFi** (most common issue!)
- Ensure device is on Setup Assistant screen (not yet activated)
- Check device is unlocked
- Verify iOS version is supported
- Try different backend server (nothingtool.com is most reliable)
- Check Desktop for log file with detailed error information
- Enable "Verbose Logging" to see backend request details
- For local backend: verify Mac.local resolves on device

### Build Issues

- Ensure Xcode is installed
- Run `xcode-select --install` to install command line tools
- Clean build folder: `rm -rf build`
- Ensure PHP is available: `which php`

### Backend Server Issues

**For Local Backend:**
- Port 8080 must be available: `lsof -i :8080`
- Backend server binds to 0.0.0.0:8080 (all interfaces)
- Check app logs for "Backend server listening on port 8080"
- Check for `[Backend] Received HTTP request` in logs
- If no backend logs appear: device can't reach Mac.local
- Verify USB connection is stable
- Try unplugging/replugging device

**For Remote Backends:**
- Device must have WiFi + internet access
- Check if backend URL is accessible in browser
- nothingtool.com requires HTTPS
- mrcellphoneunlocker.com uses HTTP (no SSL needed)

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

- **[@xxxsapnasxxx](https://x.com/xxxsapnasxxx)** - Extensive testing and invaluable feedback. This project would not have been possible without their dedication and persistence in testing every build and providing detailed bug reports. Thank you!
- [libimobiledevice project](https://github.com/libimobiledevice/libimobiledevice) - iOS device communication libraries
- [A5_Bypass_OSS](https://github.com/overcast302/A5_Bypass_OSS/) - Original Python implementation and backend server reference
- [tcurdt's iproxy investigations](https://github.com/tcurdt/iProxy) - USB networking research
- A5 community for research and testing

## Special Thanks

A massive thank you to [@xxxsapnasxxx](https://x.com/xxxsapnasxxx) who tested countless builds on real hardware, discovered critical bugs, and helped troubleshoot every issue from AFC transfers to SSL certificates. Their patience and detailed testing reports were instrumental in making this tool work reliably. Could not have done it without you! 🙏

## Author

Created by RHCP011235

## Support

For issues, questions, or feature requests, please open an issue on GitHub.
