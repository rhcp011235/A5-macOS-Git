#!/bin/bash
# Create universal (ARM64 + x86_64) binaries for libimobiledevice tools

set -e

echo "================================================"
echo "Creating Universal Binaries"
echo "================================================"

ARM64_DIR="A5/Resources/Tools"
X86_64_DIR="Tools/resources/3m104dU/libimobiledevice"
OUTPUT_DIR="A5/Resources/Tools"

TOOLS=(
    "idevice_id"
    "ideviceinfo"
    "idevicediagnostics"
)

echo ""
echo "Checking source binaries..."
echo "ARM64 source: $ARM64_DIR"
echo "x86_64 source: $X86_64_DIR"
echo ""

for tool in "${TOOLS[@]}"; do
    echo "Processing $tool..."
    
    ARM64_FILE="$ARM64_DIR/$tool"
    X86_64_FILE="$X86_64_DIR/$tool"
    
    if [ ! -f "$ARM64_FILE" ]; then
        echo "  ERROR: ARM64 version not found: $ARM64_FILE"
        continue
    fi
    
    if [ ! -f "$X86_64_FILE" ]; then
        echo "  ERROR: x86_64 version not found: $X86_64_FILE"
        continue
    fi
    
    # Verify architectures
    ARM_ARCH=$(lipo -info "$ARM64_FILE" | grep -o "arm64" || echo "")
    X86_ARCH=$(lipo -info "$X86_64_FILE" | grep -o "x86_64" || echo "")
    
    if [ -z "$ARM_ARCH" ]; then
        echo "  WARNING:  $ARM64_FILE is not ARM64!"
        continue
    fi
    
    if [ -z "$X86_ARCH" ]; then
        echo "  WARNING:  $X86_64_FILE is not x86_64!"
        continue
    fi
    
    # Create universal binary
    echo "  Combining ARM64 + x86_64..."
    lipo -create \
        "$ARM64_FILE" \
        "$X86_64_FILE" \
        -output "${OUTPUT_DIR}/${tool}.universal"
    
    # Backup original
    mv "$ARM64_FILE" "${ARM64_FILE}.arm64.bak"
    
    # Move universal to final location
    mv "${OUTPUT_DIR}/${tool}.universal" "$ARM64_FILE"
    
    chmod +x "$ARM64_FILE"
    
    echo "  SUCCESS: Created universal binary"
    lipo -info "$ARM64_FILE"
    echo ""
done

# Handle afcclient separately (might not be in x86_64 dir)
echo "Checking for afcclient..."
if [ -f "$ARM64_DIR/afcclient" ]; then
    echo "  Found ARM64 afcclient (keeping as-is, add x86_64 version if available)"
fi

echo ""
echo "================================================"
echo "SUCCESS: Universal binaries created!"
echo "================================================"
echo ""
echo "Your tools now support both ARM64 and x86_64 Macs!"
echo "Backups saved as: *.arm64.bak"
echo ""
