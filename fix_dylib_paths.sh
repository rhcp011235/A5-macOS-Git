#!/bin/bash
# Fix dylib paths to use bundled libraries instead of homebrew

APP_PATH="$1"

if [ -z "$APP_PATH" ]; then
    echo "Usage: $0 <path-to-A5.app>"
    exit 1
fi

EXECUTABLE="$APP_PATH/Contents/MacOS/A5"
TOOLS_PATH="@executable_path/../Resources/Tools"

echo "Fixing dylib paths in $EXECUTABLE..."

# Fix main executable to use bundled dylibs
install_name_tool -change /usr/local/lib/libimobiledevice-1.0.6.dylib \
    "$TOOLS_PATH/libimobiledevice-1.0.6.dylib" "$EXECUTABLE"

install_name_tool -change /usr/local/lib/libplist-2.0.4.dylib \
    "$TOOLS_PATH/libplist-2.0.4.dylib" "$EXECUTABLE"

install_name_tool -change /usr/local/lib/libusbmuxd-2.0.7.dylib \
    "$TOOLS_PATH/libusbmuxd-2.0.7.dylib" "$EXECUTABLE"

echo "✓ Dylib paths fixed - app is now portable!"

# Verify
echo ""
echo "Verification:"
otool -L "$EXECUTABLE" | grep -E "(libimobiledevice|libplist|libusbmuxd)"
