# Quick Start Guide

## For Users

1. Install dependencies:
   ```bash
   brew install libimobiledevice
   ```

2. Download and extract the latest release

3. Open the app (first time):
   - Right-click A5.app
   - Select "Open"
   - Click "Open" in the security dialog

4. Use the tool:
   - Connect your A5 device via USB
   - Trust the computer on your device
   - Wait for device detection
   - Ensure device is on WiFi
   - Click "Activate Your Device"

## For Developers

### Quick Build

```bash
# Clone the repository
git clone <your-repo-url>
cd A5-macOS

# Install dependencies
brew install libimobiledevice

# Build for testing
./build.sh

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
- iPhone 4S
- iPhone 5, 5c
- iPad 2
- iPad Mini 1st Gen

## Requirements

- macOS 10.14+
- Xcode 12.0+ (for building)
- libimobiledevice
- Universal binary (works on Intel and Apple Silicon)

## Troubleshooting

If device is not detected:
```bash
brew reinstall libimobiledevice
```

If build fails:
```bash
rm -rf build
./build.sh
```

## License

MIT License - See LICENSE file for details
