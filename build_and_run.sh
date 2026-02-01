#!/bin/bash
# Build script that automatically copies resources after building

set -e

echo "Building A5 Activation Tool..."
echo ""

# Clean build
rm -rf build/

# Build the project
xcodebuild -project A5.xcodeproj \
    -scheme A5 \
    -configuration Debug \
    clean build \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

echo ""
echo "Build complete. Copying resources..."
echo ""

# Copy resources
./copy_resources.sh

echo ""
echo "SUCCESS: Build complete and resources copied!"
echo ""
echo "To run the app:"
echo "  open build/Build/Products/Debug/A5.app"
echo ""
