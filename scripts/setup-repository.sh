#!/bin/bash

# Repository Setup Helper Script
# This script helps configure the repository for GitHub Marketplace publication

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

print_color $BLUE "🔧 SSH Remote Script Executor - Repository Setup"
print_color $BLUE "================================================="

# Check if we're in a git repository
if [ ! -d .git ]; then
    print_color $RED "❌ Error: Not in a git repository"
    exit 1
fi

# Get repository information
REMOTE_URL=$(git config --get remote.origin.url)
if [[ $REMOTE_URL =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
    REPO_OWNER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]}"
    REPO_FULL="${REPO_OWNER}/${REPO_NAME}"
else
    print_color $RED "❌ Error: Could not extract repository information"
    exit 1
fi

print_color $BLUE "📦 Repository: $REPO_FULL"
echo ""

# Check current repository status
print_color $BLUE "🔍 Checking repository status..."

# Check if repository is public
if command -v gh &> /dev/null; then
    REPO_VISIBILITY=$(gh repo view "$REPO_FULL" --json visibility --jq '.visibility' 2>/dev/null || echo "unknown")
    
    if [ "$REPO_VISIBILITY" = "public" ]; then
        print_color $GREEN "✅ Repository is public"
        REPO_IS_PUBLIC=true
    elif [ "$REPO_VISIBILITY" = "private" ]; then
        print_color $YELLOW "⚠️  Repository is private"
        REPO_IS_PUBLIC=false
    else
        print_color $YELLOW "⚠️  Could not determine repository visibility"
        REPO_IS_PUBLIC=false
    fi
else
    print_color $YELLOW "⚠️  GitHub CLI not available - cannot check repository visibility"
    REPO_IS_PUBLIC=false
fi

# Check action.yml branding
if grep -q "branding:" action.yml && grep -q "icon:" action.yml && grep -q "color:" action.yml; then
    print_color $GREEN "✅ action.yml has proper branding"
    HAS_BRANDING=true
else
    print_color $YELLOW "⚠️  action.yml missing branding"
    HAS_BRANDING=false
fi

# Check README
if [ -f README.md ] && [ -s README.md ]; then
    print_color $GREEN "✅ README.md exists"
    HAS_README=true
else
    print_color $YELLOW "⚠️  README.md missing or empty"
    HAS_README=false
fi

echo ""
print_color $BLUE "📋 Current Status:"
if [ "$REPO_IS_PUBLIC" = true ] && [ "$HAS_BRANDING" = true ] && [ "$HAS_README" = true ]; then
    print_color $GREEN "🎉 Repository is ready for GitHub Marketplace publication!"
    MARKETPLACE_READY=true
else
    print_color $YELLOW "⚠️  Repository needs configuration for marketplace publication"
    MARKETPLACE_READY=false
fi

echo ""
print_color $BLUE "🎯 What would you like to do?"
echo ""
echo "1. 🌐 Make repository public (required for marketplace)"
echo "2. 📊 Check marketplace requirements only"
echo "3. 🚀 Create a release (works for both public and private repos)"
echo "4. 📖 Show setup instructions"
echo "5. ❌ Exit"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        print_color $BLUE "🌐 Making repository public..."
        echo ""
        
        if [ "$REPO_IS_PUBLIC" = true ]; then
            print_color $GREEN "✅ Repository is already public!"
        else
            print_color $YELLOW "⚠️  This will make your repository visible to everyone"
            read -p "Are you sure you want to make the repository public? (y/N): " -n 1 -r
            echo ""
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if command -v gh &> /dev/null; then
                    print_color $BLUE "🔄 Making repository public..."
                    gh repo edit "$REPO_FULL" --visibility public
                    print_color $GREEN "✅ Repository is now public!"
                    print_color $BLUE "🎉 You can now publish to GitHub Marketplace!"
                else
                    print_color $YELLOW "⚠️  GitHub CLI not available"
                    print_color $BLUE "📝 Manual steps:"
                    print_color $BLUE "   1. Go to: https://github.com/$REPO_FULL/settings"
                    print_color $BLUE "   2. Scroll down to 'Danger Zone'"
                    print_color $BLUE "   3. Click 'Change repository visibility'"
                    print_color $BLUE "   4. Select 'Make public'"
                fi
            else
                print_color $BLUE "🔄 Repository remains private"
            fi
        fi
        ;;
    2)
        print_color $BLUE "📊 Marketplace Requirements Check:"
        echo ""
        
        if [ "$REPO_IS_PUBLIC" = true ]; then
            print_color $GREEN "✅ Repository is public"
        else
            print_color $RED "❌ Repository must be public"
            print_color $BLUE "   Fix: Settings → Change repository visibility → Make public"
        fi
        
        if [ "$HAS_BRANDING" = true ]; then
            print_color $GREEN "✅ action.yml has branding"
        else
            print_color $RED "❌ action.yml missing branding"
            print_color $BLUE "   Fix: Add branding section to action.yml"
        fi
        
        if [ "$HAS_README" = true ]; then
            print_color $GREEN "✅ README.md exists"
        else
            print_color $RED "❌ README.md missing"
            print_color $BLUE "   Fix: Create comprehensive README with usage examples"
        fi
        
        echo ""
        if [ "$MARKETPLACE_READY" = true ]; then
            print_color $GREEN "🎉 Ready for marketplace publication!"
        else
            print_color $YELLOW "⚠️  Marketplace requirements not met"
        fi
        ;;
    3)
        print_color $BLUE "🚀 Creating a release..."
        echo ""
        
        if [ -f scripts/release.sh ]; then
            print_color $BLUE "📋 Available release script:"
            print_color $BLUE "   ./scripts/release.sh <version>"
            echo ""
            read -p "Enter version to release (e.g., 1.0.0): " version
            
            if [ -n "$version" ]; then
                print_color $BLUE "🔄 Creating release $version..."
                ./scripts/release.sh "$version"
            else
                print_color $YELLOW "⚠️  No version specified"
            fi
        else
            print_color $YELLOW "⚠️  Release script not found"
            print_color $BLUE "💡 Manual release:"
            print_color $BLUE "   git tag -a v1.0.0 -m 'Release v1.0.0'"
            print_color $BLUE "   git push origin v1.0.0"
        fi
        ;;
    4)
        print_color $BLUE "📖 Setup Instructions:"
        echo ""
        print_color $BLUE "🎯 For GitHub Marketplace Publication:"
        print_color $BLUE "   1. Make repository public"
        print_color $BLUE "   2. Ensure action.yml has branding"
        print_color $BLUE "   3. Create comprehensive README"
        print_color $BLUE "   4. Create a release"
        print_color $BLUE "   5. Publish to marketplace from GitHub UI"
        echo ""
        print_color $BLUE "🎯 For Private Repository Use:"
        print_color $BLUE "   1. Create a release (works with private repos)"
        print_color $BLUE "   2. Use the action in your own workflows"
        print_color $BLUE "   3. Share with collaborators"
        echo ""
        print_color $BLUE "🔗 Useful Links:"
        print_color $BLUE "   Repository: https://github.com/$REPO_FULL"
        print_color $BLUE "   Settings: https://github.com/$REPO_FULL/settings"
        print_color $BLUE "   Releases: https://github.com/$REPO_FULL/releases"
        ;;
    5)
        print_color $BLUE "👋 Goodbye!"
        exit 0
        ;;
    *)
        print_color $RED "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
print_color $GREEN "�� Setup complete!" 