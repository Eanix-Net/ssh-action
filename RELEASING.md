# Release Guide

This guide explains how to release new versions of the SSH Remote Script Executor action and publish them to GitHub Marketplace.

## Quick Release

Use the provided release script for easy version management:

```bash
./scripts/release.sh 1.0.0
```

This will:
- ✅ Validate version format and repository state
- ✅ Create and push the version tag
- ✅ Trigger the automated release workflow
- ✅ Update major version tags (v1, v2, etc.)

## Manual Release Process

### 1. Prepare for Release

Ensure your repository is ready:

```bash
# Check that all files are present
ls -la action.yml Dockerfile entrypoint.sh README.md

# Ensure working directory is clean
git status

# Make sure you're on main branch
git checkout main
git pull origin main
```

### 2. Create Release Tag

```bash
# Create and push a semantic version tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 3. Automated Release Workflow

The workflow (`.github/workflows/release.yml`) will automatically:

1. **Validate** - Check that all required files exist
2. **Test** - Build Docker image to ensure it works
3. **Release** - Create GitHub release with generated notes
4. **Tag Management** - Update major version tags (v1, v2, etc.)

### 4. Publish to GitHub Marketplace

After the release is created:

1. **Navigate to your repository** on GitHub
2. **Go to the main page** and look for the marketplace banner
3. **Click "Publish this Action to the GitHub Marketplace"**
4. **Fill in the marketplace details**:
   - Action name: `SSH Remote Script Executor`
   - Description: `Execute scripts on remote hosts via SSH`
   - Categories: `Deployment`, `Utilities`
   - Tags: `ssh`, `remote`, `deployment`, `scripts`
5. **Submit for publication**

## Version Management

### Semantic Versioning

Follow [Semantic Versioning](https://semver.org/) (MAJOR.MINOR.PATCH):

- **MAJOR** version when you make incompatible API changes
- **MINOR** version when you add functionality in a backwards compatible manner
- **PATCH** version when you make backwards compatible bug fixes

### Examples:
- `v1.0.0` - Initial release
- `v1.0.1` - Bug fix
- `v1.1.0` - New feature (backwards compatible)
- `v2.0.0` - Breaking change

### Major Version Tags

The release workflow automatically maintains major version tags:
- `v1.0.0` → creates/updates `v1` tag
- `v1.0.1` → updates `v1` tag
- `v2.0.0` → creates/updates `v2` tag

This allows users to reference stable major versions:
```yaml
uses: your-username/ssh-action@v1  # Always latest v1.x.x
uses: your-username/ssh-action@v1.0.0  # Specific version
```

## Pre-release Checklist

Before creating a release:

- [ ] All tests pass
- [ ] README is updated with new features
- [ ] Breaking changes are documented
- [ ] Version follows semantic versioning
- [ ] Changelog is updated (if you maintain one)
- [ ] All required files are present
- [ ] Docker image builds successfully

## Release Notes Template

The workflow generates release notes automatically, but you can customize them:

```markdown
## SSH Remote Script Executor v1.0.0

### What's New
- New feature descriptions
- Improvements and enhancements
- Bug fixes

### Breaking Changes
- List any breaking changes

### Usage
```yaml
- uses: your-username/ssh-action@v1.0.0
  with:
    host: ${{ secrets.SERVER_HOST }}
    # ... other parameters
```

### Migration Guide
- Instructions for upgrading from previous versions
```

## Troubleshooting

### Release Workflow Fails

1. **Check workflow logs** in the Actions tab
2. **Common issues**:
   - Missing required files
   - Docker build failures
   - Permission issues with `GITHUB_TOKEN`

### Marketplace Publication Issues

1. **Repository must be public** for marketplace publication
2. **action.yml must have proper branding** (✅ already configured)
3. **Check GitHub's marketplace requirements**

### Tag Already Exists

```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0

# Create new tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

## GitHub Marketplace Requirements

To publish to GitHub Marketplace, ensure:

1. ✅ Repository is public
2. ✅ Valid `action.yml` in repository root
3. ✅ Proper branding in `action.yml`
4. ✅ Comprehensive README with usage examples
5. ✅ Valid semantic version tags
6. ✅ Action actually works (tested)

## Support

For issues with the release process:
1. Check the workflow logs in the Actions tab
2. Review this guide
3. Create an issue in the repository

Happy releasing! 🚀 