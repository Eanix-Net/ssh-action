#!/bin/bash

# GitHub Action Release Helper Script
# This script helps create new releases for the SSH Remote Script Executor action

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <version>"
    echo ""
    echo "Examples:"
    echo "  $0 1.0.0    # Create release v1.0.0"
    echo "  $0 1.2.3    # Create release v1.2.3"
    echo "  $0 2.0.0    # Create release v2.0.0"
    echo ""
    echo "The script will:"
    echo "  1. Validate the version format"
    echo "  2. Check if the tag already exists"
    echo "  3. Create and push the version tag"
    echo "  4. Trigger the release workflow"
}

# Check if version argument is provided
if [ $# -eq 0 ]; then
    print_color $RED "Error: Version argument is required"
    show_usage
    exit 1
fi

VERSION=$1

# Validate version format (semantic versioning)
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_color $RED "Error: Invalid version format. Use semantic versioning (e.g., 1.0.0)"
    exit 1
fi

# Add 'v' prefix if not present
if [[ ! $VERSION =~ ^v ]]; then
    VERSION="v$VERSION"
fi

print_color $BLUE "🚀 Creating release for version: $VERSION"

# Check if we're in a git repository
if [ ! -d .git ]; then
    print_color $RED "Error: Not in a git repository"
    exit 1
fi

# Check if working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    print_color $YELLOW "Warning: Working directory is not clean"
    git status --short
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_color $RED "Aborted"
        exit 1
    fi
fi

# Check if tag already exists
if git rev-parse "$VERSION" >/dev/null 2>&1; then
    print_color $RED "Error: Tag $VERSION already exists"
    exit 1
fi

# Check if we're on the main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    print_color $YELLOW "Warning: Not on main/master branch (current: $CURRENT_BRANCH)"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_color $RED "Aborted"
        exit 1
    fi
fi

# Ensure we have the latest changes
print_color $BLUE "📥 Fetching latest changes..."
git fetch origin

# Check if local branch is up to date
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
if [ $LOCAL != $REMOTE ]; then
    print_color $YELLOW "Warning: Local branch is not up to date with remote"
    read -p "Pull latest changes? (Y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        git pull origin $CURRENT_BRANCH
    fi
fi

# Validate action files exist
print_color $BLUE "🔍 Validating action files..."
required_files=("action.yml" "Dockerfile" "entrypoint.sh" "README.md")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        print_color $RED "Error: Required file missing: $file"
        exit 1
    fi
done
print_color $GREEN "✅ All required files present"

# Create and push the tag
print_color $BLUE "🏷️  Creating tag $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"

print_color $BLUE "📤 Pushing tag to origin..."
git push origin "$VERSION"

print_color $GREEN "🎉 Release initiated successfully!"
print_color $GREEN "📦 Tag $VERSION has been created and pushed"
print_color $BLUE "⏳ GitHub Actions will now:"
print_color $BLUE "   1. Build and test the action"
print_color $BLUE "   2. Create a GitHub release"
print_color $BLUE "   3. Update the major version tag (e.g., v1, v2)"
print_color $BLUE "   4. Provide marketplace publication instructions"
print_color $YELLOW "🔗 Check the Actions tab for workflow progress"

# Get repository URL for convenience
REPO_URL=$(git config --get remote.origin.url | sed 's/\.git$//')
if [[ $REPO_URL =~ ^git@ ]]; then
    # Convert SSH URL to HTTPS
    REPO_URL=$(echo $REPO_URL | sed 's/git@github.com:/https:\/\/github.com\//')
fi

print_color $BLUE "📊 Monitor release: $REPO_URL/actions"
print_color $BLUE "🎁 View releases: $REPO_URL/releases" 