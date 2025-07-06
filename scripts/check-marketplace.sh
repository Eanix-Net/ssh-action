#!/bin/bash

# GitHub Marketplace Status Checker
# This script checks if the action is published to GitHub Marketplace

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

print_color $BLUE "🔍 Checking GitHub Marketplace publication status..."

# Get repository information
if [ ! -d .git ]; then
    print_color $RED "Error: Not in a git repository"
    exit 1
fi

# Get remote URL and extract repository name
REMOTE_URL=$(git config --get remote.origin.url)
if [[ $REMOTE_URL =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
    REPO_OWNER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]}"
    REPO_FULL="${REPO_OWNER}/${REPO_NAME}"
else
    print_color $RED "Error: Could not extract repository information from remote URL"
    exit 1
fi

print_color $BLUE "📦 Repository: $REPO_FULL"

# Check marketplace URL
MARKETPLACE_URL="https://github.com/marketplace/actions/$REPO_NAME"
print_color $BLUE "🔗 Checking: $MARKETPLACE_URL"

# Check if action exists on marketplace
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$MARKETPLACE_URL" 2>/dev/null || echo "000")

if [ "$HTTP_STATUS" = "200" ]; then
    print_color $GREEN "✅ Action is published on GitHub Marketplace!"
    print_color $GREEN "🔗 Marketplace URL: $MARKETPLACE_URL"
    echo ""
    print_color $BLUE "📦 Users can install with:"
    echo "   uses: $REPO_FULL@v1"
    echo ""
    
    # Try to get some basic info about the action
    if command -v curl &> /dev/null; then
        print_color $BLUE "📋 Marketplace Information:"
        curl -s "$MARKETPLACE_URL" | grep -o '<title>[^<]*' | sed 's/<title>/   Title: /' || echo "   Could not extract title"
    fi
    
    # Check if there are open marketplace issues to close
    if command -v gh &> /dev/null; then
        print_color $BLUE "🔍 Checking for open marketplace publication issues..."
        OPEN_ISSUES=$(gh issue list --repo "$REPO_FULL" --state open --label "marketplace" --json number,title 2>/dev/null || echo "[]")
        
        if [ "$OPEN_ISSUES" != "[]" ] && [ -n "$OPEN_ISSUES" ]; then
            print_color $YELLOW "📝 Found open marketplace issues:"
            echo "$OPEN_ISSUES" | jq -r '.[] | "   #\(.number): \(.title)"' 2>/dev/null || echo "   Could not parse issues"
            echo ""
            print_color $BLUE "💡 You can close these issues by running:"
            print_color $BLUE "   gh workflow run marketplace-check.yml --repo $REPO_FULL"
        else
            print_color $GREEN "✅ No open marketplace issues found"
        fi
    fi
    
elif [ "$HTTP_STATUS" = "404" ]; then
    print_color $YELLOW "⏳ Action not yet published to GitHub Marketplace"
    echo ""
    print_color $BLUE "📝 To publish to marketplace:"
    print_color $BLUE "   1. Go to: https://github.com/$REPO_FULL"
    print_color $BLUE "   2. Look for 'Publish this Action to the GitHub Marketplace' banner"
    print_color $BLUE "   3. Fill in the marketplace form and submit"
    echo ""
    print_color $BLUE "🔗 Expected marketplace URL: $MARKETPLACE_URL"
    
elif [ "$HTTP_STATUS" = "000" ]; then
    print_color $RED "❌ Could not check marketplace status (network error)"
    exit 1
else
    print_color $YELLOW "⚠️  Unexpected response (HTTP $HTTP_STATUS)"
    print_color $YELLOW "🔗 Check manually: $MARKETPLACE_URL"
fi

# Check if action.yml is properly configured for marketplace
echo ""
print_color $BLUE "🔍 Validating action.yml for marketplace requirements..."

if [ ! -f action.yml ]; then
    print_color $RED "❌ action.yml not found"
    exit 1
fi

# Check branding
if grep -q "branding:" action.yml && grep -q "icon:" action.yml && grep -q "color:" action.yml; then
    print_color $GREEN "✅ action.yml has proper branding"
else
    print_color $RED "❌ action.yml missing branding configuration"
    echo "   Add branding section to action.yml:"
    echo "   branding:"
    echo "     icon: 'terminal'"
    echo "     color: 'gray-dark'"
fi

# Check if README exists
if [ -f README.md ] && [ -s README.md ]; then
    print_color $GREEN "✅ README.md exists"
    
    # Check for usage examples
    if grep -q "```yaml" README.md; then
        print_color $GREEN "✅ README contains usage examples"
    else
        print_color $YELLOW "⚠️  README should include usage examples"
    fi
else
    print_color $RED "❌ README.md missing or empty"
fi

# Check repository visibility (if gh CLI is available)
if command -v gh &> /dev/null; then
    REPO_VISIBILITY=$(gh repo view "$REPO_FULL" --json visibility --jq '.visibility' 2>/dev/null || echo "unknown")
    if [ "$REPO_VISIBILITY" = "public" ]; then
        print_color $GREEN "✅ Repository is public"
    elif [ "$REPO_VISIBILITY" = "private" ]; then
        print_color $RED "❌ Repository must be public for marketplace publication"
    else
        print_color $YELLOW "⚠️  Could not determine repository visibility"
    fi
fi

echo ""
print_color $BLUE "🎯 Marketplace check complete!" 