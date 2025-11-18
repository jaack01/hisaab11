#!/bin/bash

# Version Bump Script for Hisaab
# This script helps increment app version numbers

set -e

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

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if pubspec.yaml exists
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found!"
    exit 1
fi

# Extract current version
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
CURRENT_VERSION_NAME=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
CURRENT_BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

echo ""
echo "Current version: $CURRENT_VERSION"
echo "  Version name: $CURRENT_VERSION_NAME"
echo "  Build number: $CURRENT_BUILD_NUMBER"
echo ""

# Ask user what to bump
echo "What would you like to bump?"
echo "  1) Major version (x.0.0)"
echo "  2) Minor version (1.x.0)"
echo "  3) Patch version (1.0.x)"
echo "  4) Build number only (1.0.0+x)"
echo "  5) Custom version"
echo ""
read -p "Enter choice (1-5): " choice

# Parse version components
IFS='.' read -r -a version_parts <<< "$CURRENT_VERSION_NAME"
MAJOR="${version_parts[0]}"
MINOR="${version_parts[1]}"
PATCH="${version_parts[2]}"

case $choice in
    1)
        # Bump major
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        CURRENT_BUILD_NUMBER=$((CURRENT_BUILD_NUMBER + 1))
        ;;
    2)
        # Bump minor
        MINOR=$((MINOR + 1))
        PATCH=0
        CURRENT_BUILD_NUMBER=$((CURRENT_BUILD_NUMBER + 1))
        ;;
    3)
        # Bump patch
        PATCH=$((PATCH + 1))
        CURRENT_BUILD_NUMBER=$((CURRENT_BUILD_NUMBER + 1))
        ;;
    4)
        # Bump build number only
        CURRENT_BUILD_NUMBER=$((CURRENT_BUILD_NUMBER + 1))
        ;;
    5)
        # Custom version
        echo ""
        read -p "Enter new version name (e.g., 1.2.0): " NEW_VERSION_NAME
        read -p "Enter new build number (e.g., 5): " NEW_BUILD_NUMBER

        NEW_VERSION="$NEW_VERSION_NAME+$NEW_BUILD_NUMBER"

        # Update pubspec.yaml
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
        else
            # Linux
            sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
        fi

        print_success "Version updated to: $NEW_VERSION"
        exit 0
        ;;
    *)
        print_error "Invalid choice!"
        exit 1
        ;;
esac

# Construct new version
NEW_VERSION="$MAJOR.$MINOR.$PATCH+$CURRENT_BUILD_NUMBER"

# Show changes
echo ""
print_info "Version changes:"
echo "  Old: $CURRENT_VERSION"
echo "  New: $NEW_VERSION"
echo ""

# Confirm
read -p "Continue? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    print_warning "Version bump cancelled"
    exit 0
fi

# Update pubspec.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
else
    # Linux
    sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
fi

# Verify update
UPDATED_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')

if [ "$UPDATED_VERSION" = "$NEW_VERSION" ]; then
    print_success "Version successfully updated to: $NEW_VERSION"

    # Ask if user wants to commit
    echo ""
    read -p "Create git commit for version bump? (y/n): " git_commit

    if [ "$git_commit" = "y" ]; then
        git add pubspec.yaml
        git commit -m "chore: Bump version to $NEW_VERSION"
        print_success "Git commit created"

        # Ask if user wants to tag
        read -p "Create git tag? (y/n): " git_tag
        if [ "$git_tag" = "y" ]; then
            TAG_NAME="v$MAJOR.$MINOR.$PATCH"
            git tag -a "$TAG_NAME" -m "Release $TAG_NAME"
            print_success "Git tag created: $TAG_NAME"

            read -p "Push tag to remote? (y/n): " push_tag
            if [ "$push_tag" = "y" ]; then
                git push origin "$TAG_NAME"
                print_success "Tag pushed to remote"
            fi
        fi
    fi
else
    print_error "Failed to update version!"
    exit 1
fi

echo ""
print_success "Version bump complete!"
echo ""
