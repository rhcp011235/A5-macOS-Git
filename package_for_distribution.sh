#!/bin/bash
# Package A5 app for distribution

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "================================================"
echo "A5 macOS - Distribution Package Builder"
echo "================================================"

# Check current tool architecture
echo ""
echo "Checking tool architecture..."
TOOL_ARCH=$(file A5/Resources/Tools/idevice_id | grep -o 'arm64\|x86_64' | head -1)
if [ -z "$TOOL_ARCH" ]; then
    TOOL_ARCH=$(lipo -info A5/Resources/Tools/idevice_id 2>&1 | grep -o 'arm64\|x86_64' || echo "unknown")
fi

# Check if universal (check for both possible orders)
LIPO_OUTPUT=$(lipo -info A5/Resources/Tools/idevice_id 2>&1)
if echo "$LIPO_OUTPUT" | grep -q "x86_64" && echo "$LIPO_OUTPUT" | grep -q "arm64"; then
    IS_UNIVERSAL="1"
else
    IS_UNIVERSAL="0"
fi

if [ "$IS_UNIVERSAL" = "1" ]; then
    echo "✅ Tools are UNIVERSAL (ARM64 + x86_64) - will work on all Macs"
    ARCH_SUFFIX="-Universal"
else
    echo "⚠️  Tools are $TOOL_ARCH ONLY"
    if [ "$TOOL_ARCH" = "arm64" ]; then
        echo "   App will ONLY work on Apple Silicon Macs (M1/M2/M3/M4)"
        ARCH_SUFFIX="-ARM64"
    else
        echo "   App will ONLY work on Intel Macs"
        ARCH_SUFFIX="-Intel"
    fi
fi

# Clean previous builds
echo ""
echo "Cleaning previous builds..."
rm -rf build/Build
mkdir -p dist

# Build Release version
echo ""
echo "Building Release configuration..."
xcodebuild -project A5.xcodeproj \
           -scheme A5 \
           -configuration Release \
           -derivedDataPath ./build \
           CODE_SIGN_IDENTITY="-" \
           CODE_SIGNING_REQUIRED=NO \
           | grep -E "BUILD|succeed|fail|error|warning" || true

if [ ! -d "build/Build/Products/Release/A5.app" ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "✅ Build succeeded!"

# Copy resources
echo ""
echo "Copying resources..."
./copy_resources.sh build/Build/Products/Release/A5.app/Contents/Resources

# Create version info
VERSION="1.0"
BUILD_DATE=$(date "+%Y-%m-%d")

# Create README for distribution
cat > dist/README.txt << EOF
A5 iOS Device Activation Bypass Tool By RHCP011235 - macOS
Version: $VERSION
Build Date: $BUILD_DATE
Architecture: $TOOL_ARCH$ARCH_SUFFIX

SYSTEM REQUIREMENTS:
EOF

if [ "$IS_UNIVERSAL" = "1" ]; then
cat >> dist/README.txt << EOF
- macOS 10.14 (Mojave) or later
- Works on both Intel and Apple Silicon Macs
EOF
elif [ "$TOOL_ARCH" = "arm64" ]; then
cat >> dist/README.txt << EOF
- macOS 11.0 (Big Sur) or later
- Apple Silicon Mac ONLY (M1/M2/M3/M4)
- Will NOT work on Intel Macs
EOF
else
cat >> dist/README.txt << EOF
- macOS 10.14 (Mojave) or later
- Intel Mac ONLY
- Will NOT work on Apple Silicon Macs
EOF
fi

cat >> dist/README.txt << EOF

DEPENDENCIES:
- libimobiledevice (install via: brew install libimobiledevice)

SUPPORTED DEVICES:
This tool ONLY works with A5 chip devices:
- iPhone 4S (iPhone4,1)
- iPhone 5 (iPhone5,1, iPhone5,2)
- iPhone 5c (iPhone5,3, iPhone5,4)
- iPad 2 (iPad2,1, iPad2,2, iPad2,3, iPad2,4)
- iPad Mini 1st Gen (iPad2,5, iPad2,6, iPad2,7)

INSTALLATION:
1. Install libimobiledevice:
   brew install libimobiledevice

2. Drag A5.app to your Applications folder

3. First time opening:
   - Right-click A5.app and select "Open"
   - Click "Open" in the security dialog
   - (This is needed because the app is not signed)

USAGE:
1. Launch A5.app
2. Connect your A5 device via USB
3. Trust the computer on your device
4. Wait for device detection (3 seconds)
5. Ensure device is connected to WiFi
6. Click "Activate Your Device"
7. Wait for the process to complete (3-5 minutes)

TROUBLESHOOTING:
- If device not detected: brew install libimobiledevice
- If "not supported": Only A5 chip devices work (iPhone 4S, 5, 5c, iPad 2)
- If activation fails: Ensure device is on WiFi

WARNING:
This is an activation bypass tool for old A5 devices only.
Use at your own risk.

For more information, see the full documentation.
EOF

# Copy app to dist
echo ""
echo "Packaging application..."
cp -R build/Build/Products/Release/A5.app dist/

# Create ZIP
echo ""
echo "Creating distribution archive..."
cd dist
ZIP_NAME="A5-Activation-macOS-v${VERSION}${ARCH_SUFFIX}.zip"
zip -r -q "$ZIP_NAME" A5.app README.txt

cd ..

echo ""
echo "================================================"
echo "✅ Distribution package created!"
echo "================================================"
echo ""
echo "Location: dist/$ZIP_NAME"
echo "Size: $(du -h "dist/$ZIP_NAME" | cut -f1)"
echo ""
echo "Architecture: $TOOL_ARCH$ARCH_SUFFIX"
if [ "$IS_UNIVERSAL" != "1" ]; then
    echo ""
    echo "⚠️  IMPORTANT: This build will ONLY work on $TOOL_ARCH Macs!"
    echo ""
    echo "To create a universal build:"
    echo "  ./create_universal_tools.sh"
    echo "  ./package_for_distribution.sh"
fi
echo ""
echo "You can now send dist/$ZIP_NAME to your friend!"
echo ""
