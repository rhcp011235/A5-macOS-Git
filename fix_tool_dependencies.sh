#!/bin/bash
set -e

TOOLS_DIR="A5/Resources/Tools"

echo "Copying required libraries..."

# Find and copy all dylibs needed by idevice tools
for tool in idevice_id ideviceinfo idevicediagnostics; do
    if [ -f "$TOOLS_DIR/$tool" ]; then
        echo "Processing $tool..."

        # Get all library dependencies
        otool -L "$TOOLS_DIR/$tool" | grep -E "(libimobiledevice|libusbmuxd|libplist|libssl|libcrypto|libimobiledevice-glue)" | awk '{print $1}' | while read lib; do
            # Get just the library filename
            libname=$(basename "$lib")

            # Skip if already copied
            if [ -f "$TOOLS_DIR/$libname" ]; then
                continue
            fi

            # Try to find the library
            if [ -f "$lib" ]; then
                cp "$lib" "$TOOLS_DIR/"
                chmod +x "$TOOLS_DIR/$libname"
                echo "  Copied $libname"
            elif [ -f "/opt/homebrew/lib/$libname" ]; then
                cp "/opt/homebrew/lib/$libname" "$TOOLS_DIR/"
                chmod +x "$TOOLS_DIR/$libname"
                echo "  Copied $libname from /opt/homebrew/lib"
            elif [ -f "/usr/local/lib/$libname" ]; then
                cp "/usr/local/lib/$libname" "$TOOLS_DIR/"
                chmod +x "$TOOLS_DIR/$libname"
                echo "  Copied $libname from /usr/local/lib"
            fi
        done
    fi
done

echo ""
echo "Fixing library paths..."

# Fix all tools to use @loader_path
for tool in idevice_id ideviceinfo idevicediagnostics afcclient iproxy; do
    if [ -f "$TOOLS_DIR/$tool" ]; then
        echo "Fixing $tool..."
        otool -L "$TOOLS_DIR/$tool" | grep -E "(libimobiledevice|libusbmuxd|libplist|libssl|libcrypto|libimobiledevice-glue)" | awk '{print $1}' | while read lib; do
            libname=$(basename "$lib")
            if [ -f "$TOOLS_DIR/$libname" ]; then
                install_name_tool -change "$lib" "@loader_path/$libname" "$TOOLS_DIR/$tool"
                echo "  Changed $libname to @loader_path"
            fi
        done
    fi
done

# Fix dylib dependencies on each other
for dylib in "$TOOLS_DIR"/*.dylib; do
    if [ -f "$dylib" ]; then
        echo "Fixing $(basename "$dylib")..."
        otool -L "$dylib" | grep -E "(libimobiledevice|libusbmuxd|libplist|libssl|libcrypto|libimobiledevice-glue)" | awk '{print $1}' | while read lib; do
            libname=$(basename "$lib")
            if [ -f "$TOOLS_DIR/$libname" ]; then
                install_name_tool -change "$lib" "@loader_path/$libname" "$dylib"
                echo "  Changed $libname to @loader_path"
            fi
        done
        # Fix the dylib's own install name
        install_name_tool -id "@loader_path/$(basename "$dylib")" "$dylib" 2>/dev/null || true
    fi
done

echo ""
echo "Done! All tools are now self-contained."
