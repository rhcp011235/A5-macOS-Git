#!/bin/bash
# Simple build script for A5 macOS

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building A5 for macOS...${NC}"

# Check if project exists
if [ ! -d "A5.xcodeproj" ]; then
    echo -e "${RED}Error: A5.xcodeproj not found${NC}"
    echo -e "${YELLOW}Run ./setup_project.sh first${NC}"
    exit 1
fi

# Parse arguments
CONFIGURATION="Debug"
CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --release)
            CONFIGURATION="Release"
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --release    Build in Release configuration (default: Debug)"
            echo "  --clean      Clean before building"
            echo "  --help       Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Clean if requested
if [ "$CLEAN" = true ]; then
    echo -e "${YELLOW}Cleaning...${NC}"
    xcodebuild clean -project A5.xcodeproj -scheme A5 -configuration "$CONFIGURATION"
fi

# Build
echo -e "${GREEN}Building $CONFIGURATION configuration...${NC}"
xcodebuild -project A5.xcodeproj \
           -scheme A5 \
           -configuration "$CONFIGURATION" \
           -derivedDataPath ./build \
           CODE_SIGN_IDENTITY="-" \
           CODE_SIGNING_REQUIRED=NO

if [ $? -eq 0 ]; then
    # Copy resources to app bundle
    echo ""
    echo -e "${YELLOW}Copying resources to app bundle...${NC}"
    ./copy_resources.sh

    echo ""
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}Build Successful!${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""

    if [ "$CONFIGURATION" = "Debug" ]; then
        APP_PATH="build/Build/Products/Debug/A5.app"
    else
        APP_PATH="build/Build/Products/Release/A5.app"
    fi

    if [ -d "$APP_PATH" ]; then
        echo -e "Application built at: ${GREEN}$APP_PATH${NC}"
        echo ""
        echo "To run the app:"
        echo -e "  ${YELLOW}open \"$APP_PATH\"${NC}"
        echo ""
        echo "To create a distributable package:"
        echo -e "  ${YELLOW}./package.sh${NC}"
    fi
else
    echo ""
    echo -e "${RED}=========================================${NC}"
    echo -e "${RED}Build Failed!${NC}"
    echo -e "${RED}=========================================${NC}"
    exit 1
fi
