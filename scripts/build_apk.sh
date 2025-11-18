#!/bin/bash

# APK Build Script for Hisaab
# This script builds a release APK for testing on Android devices

set -e  # Exit on error

echo "🔨 Starting Hisaab APK Build..."
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_success "Flutter found: $(flutter --version | head -n 1)"

# Step 1: Clean previous builds
echo ""
print_info "Step 1: Cleaning previous builds..."
flutter clean
print_success "Clean completed"

# Step 2: Get dependencies
echo ""
print_info "Step 2: Getting dependencies..."
flutter pub get
print_success "Dependencies fetched"

# Step 3: Run code generation (if needed)
echo ""
print_info "Step 3: Running code generation..."
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    flutter pub run build_runner build --delete-conflicting-outputs
    print_success "Code generation completed"
else
    print_warning "No build_runner found, skipping code generation"
fi

# Step 4: Build APK
echo ""
print_info "Step 4: Building release APK..."
print_warning "Note: This APK is for testing only. Use app bundle (.aab) for Play Store."

# Build APK with split per ABI for smaller file sizes
flutter build apk --release --split-per-abi

if [ $? -eq 0 ]; then
    print_success "APK built successfully!"
else
    print_error "Build failed!"
    exit 1
fi

# Step 5: Verify output
echo ""
print_info "Step 5: Verifying build output..."

APK_DIR="build/app/outputs/flutter-apk"

if [ -d "$APK_DIR" ]; then
    print_success "APK directory found: $APK_DIR"

    echo ""
    print_info "APK files created:"

    # List all APK files with sizes
    for apk in "$APK_DIR"/*.apk; do
        if [ -f "$apk" ]; then
            size=$(du -h "$apk" | cut -f1)
            filename=$(basename "$apk")
            echo "  • $filename ($size)"
        fi
    done
else
    print_error "APK directory not found!"
    exit 1
fi

# Step 6: Generate build info
echo ""
print_info "Step 6: Generating build information..."

BUILD_INFO_FILE="build/apk_build_info.txt"
mkdir -p build

{
    echo "Hisaab APK Build Information"
    echo "===================================="
    echo ""
    echo "Build Date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Flutter Version: $(flutter --version | head -n 1)"
    echo "Build Type: Release APK (Split per ABI)"
    echo "Output Directory: $APK_DIR"
    echo ""
    echo "APK Files:"
    for apk in "$APK_DIR"/*.apk; do
        if [ -f "$apk" ]; then
            size=$(du -h "$apk" | cut -f1)
            filename=$(basename "$apk")
            echo "  - $filename ($size)"
        fi
    done
    echo ""
    echo "Git Information:"
    echo "  Branch: $(git branch --show-current 2>/dev/null || echo 'N/A')"
    echo "  Commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
    echo "  Commit Message: $(git log -1 --pretty=%B 2>/dev/null || echo 'N/A')"
    echo ""
} > "$BUILD_INFO_FILE"

print_success "Build information saved to $BUILD_INFO_FILE"

# Final summary
echo ""
echo "======================================"
echo "🎉 APK Build Complete!"
echo "======================================"
echo ""
print_info "APK files created:"
echo ""

for apk in "$APK_DIR"/*.apk; do
    if [ -f "$apk" ]; then
        size=$(du -h "$apk" | cut -f1)
        filename=$(basename "$apk")
        echo "  📦 $filename"
        echo "     Size: $size"
        echo "     Path: $apk"
        echo ""
    fi
done

print_info "Installation Instructions:"
echo ""
echo "  Method 1: ADB Install"
echo "    1. Connect Android device via USB"
echo "    2. Enable USB debugging on device"
echo "    3. Run: adb install $APK_DIR/app-armeabi-v7a-release.apk"
echo ""
echo "  Method 2: File Transfer"
echo "    1. Copy APK to your phone"
echo "    2. Open APK file on phone"
echo "    3. Allow installation from unknown sources if prompted"
echo "    4. Install the app"
echo ""

print_warning "Important Notes:"
echo "  • APKs are split by CPU architecture (armeabi-v7a, arm64-v8a, x86_64)"
echo "  • Install the correct APK for your device (arm64-v8a works on most modern phones)"
echo "  • For Play Store, use app bundle: ./scripts/build_production.sh"
echo "  • This is a release build - not signed for production"
echo ""
