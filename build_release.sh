#!/bin/bash
# A5 macOS - Master Build Script
# Choose between Normal or Obfuscated builds

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "================================================"
echo "      A5 macOS - Release Build Tool"
echo "================================================"
echo ""
echo "Choose build type:"
echo ""
echo "  1) Normal Build (No obfuscation)"
echo "     - Faster compilation"
echo "     - Smaller binary size"
echo "     - Easy to debug"
echo "     - Source code visible in disassembly"
echo ""
echo "  2) Obfuscated Build (Hikari LLVM)"
echo "     - Slower compilation"
echo "     - Larger binary size"
echo "     - Protected source code"
echo "     - Difficult to reverse engineer"
echo ""
echo "  3) Build BOTH versions"
echo ""

read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "Building NORMAL version..."
        ./package_for_distribution.sh
        ;;
    2)
        echo ""
        echo "Building OBFUSCATED version..."
        ./build_obfuscated.sh
        ;;
    3)
        echo ""
        echo "Building BOTH versions..."
        echo ""
        echo "=== Building NORMAL version first ==="
        ./package_for_distribution.sh

        echo ""
        echo "=== Building OBFUSCATED version ==="
        ./build_obfuscated.sh

        echo ""
        echo "================================================"
        echo "SUCCESS: Both versions built successfully!"
        echo "================================================"
        echo ""
        ls -lh dist/*.zip
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "SUCCESS: Build complete!"
echo ""
