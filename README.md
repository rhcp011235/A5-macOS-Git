# A5 iOS Device Activation Bypass Tool By RHCP011235

A macOS application for bypassing iCloud activation on A5 chip iOS devices.

## Overview

This tool provides activation bypass functionality for legacy A5 chip devices, allowing them to be used without iCloud activation. The application features a native macOS interface with real-time device detection and status monitoring.

## Supported Devices

This tool ONLY works with A5 chip devices:

- iPhone 4S (iPhone4,1)
- iPhone 5 (iPhone5,1, iPhone5,2)
- iPhone 5c (iPhone5,3, iPhone5,4)
- iPad 2 (iPad2,1, iPad2,2, iPad2,3, iPad2,4)
- iPad Mini 1st Generation (iPad2,5, iPad2,6, iPad2,7)

## System Requirements

- macOS 10.14 (Mojave) or later
- Works on both Intel and Apple Silicon Macs
- Xcode 12.0 or later (for building from source)
- libimobiledevice (brew install libimobiledevice)

## Features

- Native macOS Cocoa application with programmatic UI
- Universal binary support (ARM64 + x86_64)
- Automatic device detection via USB
- Real-time device information display
- Activation bypass for A5 devices
- Clean logging interface
- Device model identification
- iOS version detection

## Installation

### For Users

1. Install libimobiledevice:
   ```bash
   brew install libimobiledevice
   ```

2. Download the latest release
3. Extract the ZIP file
4. Right-click A5.app and select "Open"
5. Click "Open" in the security dialog (required for unsigned apps)

### For Developers

1. Clone this repository:
   ```bash
   git clone https://github.com/rhcp011235/A5-macOS.git
   cd A5-macOS
   ```

2. Install dependencies:
   ```bash
   brew install libimobiledevice
   ```

3. Build the project:
   ```bash
   ./build.sh
   ```

## Building from Source

### Quick Debug Build

```bash
./build.sh
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
- `copy_resources.sh` - Copies tools and payloads to app bundle
- `make_universal_tools.sh` - Creates universal binaries from separate architectures
- `build_release.sh` - Interactive build menu

## Usage

1. Launch A5.app
2. Connect your A5 device via USB
3. Trust the computer on your device if prompted
4. Wait for device detection (automatic, takes ~3 seconds)
5. Ensure device is connected to WiFi
6. Click "Activate Your Device"
7. Wait for the activation process to complete (3-5 minutes)

The application will:
- Detect the connected device
- Verify it's an A5 chip device
- Display device model and iOS version
- Perform activation bypass
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
│   │   ├── Payloads/        # Activation payloads
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
- `A5ActivationService` - Activation bypass implementation
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
- `idevicediagnostics` - Device diagnostics

### Activation Process

1. Verifies device is A5 chip
2. Checks iOS version compatibility
3. Executes activation bypass sequence
4. Monitors process status
5. Verifies successful activation

## Troubleshooting

### Device Not Detected

- Ensure libimobiledevice is installed: `brew install libimobiledevice`
- Check USB connection
- Trust the computer on your device
- Try unplugging and reconnecting

### Device Not Supported

- Only A5 chip devices are supported
- Verify your device model in the supported list
- Newer devices (A6+) will not work

### Activation Fails

- Ensure device is connected to WiFi
- Check device is unlocked
- Verify iOS version is compatible
- Try restarting the application

### Build Issues

- Ensure Xcode is installed
- Run `xcode-select --install` to install command line tools
- Clean build folder: `rm -rf build`

## Security & Privacy

- No data is collected or transmitted
- All processing happens locally on your Mac
- Device information stays on your machine
- No internet connection required (except for device WiFi)

## License

Copyright 2026 RHCP011235. All rights reserved.

This tool is provided as-is for educational and legitimate device unlocking purposes only. Use at your own risk. The author is not responsible for any misuse or damage.

## Disclaimer

This software is intended for use on devices you own or have explicit permission to modify. Bypassing activation locks on devices you do not own may be illegal in your jurisdiction. Always ensure you have the right to modify any device before using this tool.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## Acknowledgments

- libimobiledevice project for iOS device communication
- Hikari LLVM for obfuscation support (optional)
- A5 community for research and testing

## Author

Created by RHCP011235

## Support

For issues, questions, or feature requests, please open an issue on GitHub.
