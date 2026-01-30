#!/bin/bash
# Post-build script to copy resources to the app bundle

set -e

if [ -z "$BUILT_PRODUCTS_DIR" ]; then
    # Running outside of Xcode, use defaults
    if [ -d "build/Build/Products/Debug/A5.app" ]; then
        BUILT_PRODUCTS_DIR="build/Build/Products/Debug"
        PRODUCT_NAME="A5"
    elif [ -d "build/Build/Products/Release/A5.app" ]; then
        BUILT_PRODUCTS_DIR="build/Build/Products/Release"
        PRODUCT_NAME="A5"
    else
        echo "Error: Could not find built app"
        exit 1
    fi
fi

APP_BUNDLE="$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.app"
RESOURCES_DIR="$APP_BUNDLE/Contents/Resources"

echo "Copying resources to $RESOURCES_DIR"

# Create directories
mkdir -p "$RESOURCES_DIR/Tools"
mkdir -p "$RESOURCES_DIR/Payloads"
mkdir -p "$RESOURCES_DIR/backend"

# Copy tools (excluding backup files)
if [ -d "A5/Resources/Tools" ]; then
    for tool in A5/Resources/Tools/*; do
        # Skip backup files
        if [[ "$tool" != *.bak ]]; then
            cp -f "$tool" "$RESOURCES_DIR/Tools/" 2>/dev/null || true
        fi
    done
    chmod +x "$RESOURCES_DIR/Tools/"* 2>/dev/null || true
    echo "OK Copied tools"
fi

# Copy payloads
if [ -d "A5/Resources/Payloads" ]; then
    cp -f A5/Resources/Payloads/* "$RESOURCES_DIR/Payloads/" 2>/dev/null || true
    echo "OK Copied payloads"
fi

# Copy backend (server.php + plist files)
if [ -d "A5/Resources/backend" ]; then
    cp -f A5/Resources/backend/server.php "$RESOURCES_DIR/backend/" 2>/dev/null || true
    cp -rf A5/Resources/backend/plists "$RESOURCES_DIR/backend/" 2>/dev/null || true
    echo "OK Copied backend server"
fi

# Copy assets if they exist
if [ -d "A5/Resources/Assets.xcassets" ]; then
    # Assets are handled by Xcode automatically
    :
fi

echo "OK Resources copied successfully"
