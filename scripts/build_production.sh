#!/bin/bash

# Production Build Script for Hisaab
# This script builds a production-ready app bundle for Google Play Store

set -e  # Exit on error

echo "🚀 Starting Hisaab Production Build..."
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
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
    echo -e "ℹ $1"
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

# Step 4: Check for key.properties
echo ""
print_info "Step 4: Checking signing configuration..."
if [ ! -f "android/key.properties" ]; then
    print_error "android/key.properties not found!"
    print_error "Please create the file with your keystore details."
    print_error "See deployment/docs/APP_SIGNING.md for instructions."
    exit 1
fi
print_success "Signing configuration found"

# Step 5: Run tests
echo ""
print_info "Step 5: Running tests..."
if flutter test; then
    print_success "All tests passed"
else
    print_error "Tests failed! Please fix before building."
    exit 1
fi

# Step 6: Analyze code
echo ""
print_info "Step 6: Analyzing code..."
if flutter analyze; then
    print_success "Code analysis passed"
else
    print_warning "Code analysis found issues. Continue? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
        exit 1
    fi
fi

# Step 7: Build app bundle
echo ""
print_info "Step 7: Building release app bundle..."
flutter build appbundle --release

if [ $? -eq 0 ]; then
    print_success "App bundle built successfully!"
else
    print_error "Build failed!"
    exit 1
fi

# Step 8: Verify output
echo ""
print_info "Step 8: Verifying build output..."

AAB_PATH="build/app/outputs/bundle/release/app-release.aab"

if [ -f "$AAB_PATH" ]; then
    AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
    print_success "App bundle found: $AAB_PATH"
    print_info "Bundle size: $AAB_SIZE"

    # Check if bundle is too large (warning if > 100MB)
    AAB_SIZE_MB=$(du -m "$AAB_PATH" | cut -f1)
    if [ "$AAB_SIZE_MB" -gt 100 ]; then
        print_warning "App bundle is larger than 100MB. Consider optimization."
    fi
else
    print_error "App bundle not found at expected location!"
    exit 1
fi

# Step 9: Verify signature (if jarsigner is available)
echo ""
print_info "Step 9: Verifying signature..."
if command -v jarsigner &> /dev/null; then
    if jarsigner -verify -verbose -certs "$AAB_PATH" 2>&1 | grep -q "jar verified"; then
        print_success "Signature verified"
    else
        print_error "Signature verification failed!"
        exit 1
    fi
else
    print_warning "jarsigner not found, skipping signature verification"
fi

# Step 10: Generate build info
echo ""
print_info "Step 10: Generating build information..."

BUILD_INFO_FILE="build/build_info.txt"
mkdir -p build

{
    echo "Hisaab Production Build Information"
    echo "===================================="
    echo ""
    echo "Build Date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Flutter Version: $(flutter --version | head -n 1)"
    echo "Build Path: $AAB_PATH"
    echo "Bundle Size: $AAB_SIZE"
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
echo "🎉 Production Build Complete!"
echo "======================================"
echo ""
print_info "Next steps:"
echo "  1. Test the app bundle on a device"
echo "  2. Upload to Google Play Console"
echo "  3. Create a release in Production track"
echo ""
print_info "App bundle location:"
echo "  $AAB_PATH"
echo ""
print_info "For deployment instructions, see:"
echo "  deployment/DEPLOYMENT_CHECKLIST.md"
echo ""
