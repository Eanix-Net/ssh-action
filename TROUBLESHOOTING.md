# Troubleshooting GitHub Actions

This guide helps resolve common issues when setting up and running the SSH Remote Script Executor action.

## GitHub Actions Permission Issues

### Error: "Resource not accessible by integration"

**Problem**: The GitHub Actions workflow fails with permission errors.

**Solution**: This has been fixed in the latest version by:
1. Adding explicit permissions to the workflow
2. Using GitHub CLI instead of deprecated actions
3. Proper token configuration

**What was changed**:
```yaml
permissions:
  contents: write
  packages: write
  issues: write
  pull-requests: write
```

### Error: "actions/create-release@v1 is deprecated"

**Problem**: The old `actions/create-release@v1` action is deprecated and has permission issues.

**Solution**: Updated to use GitHub CLI (`gh`) which is more reliable:
```yaml
- name: Create GitHub Release
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    gh release create ${{ steps.version.outputs.version }} \
      --title "SSH Remote Script Executor ${{ steps.version.outputs.version }}" \
      --notes-file release_notes.md \
      --latest
```

## Repository Setup Issues

### Repository Must Be Public

**Problem**: GitHub Marketplace requires public repositories.

**Solution**: 
1. Go to your repository Settings
2. Scroll down to "Danger Zone"
3. Click "Change repository visibility"
4. Select "Make public"

### Missing Required Files

**Problem**: Release workflow fails because required files are missing.

**Solution**: Ensure these files exist:
- `action.yml` (action metadata)
- `Dockerfile` (container definition)
- `entrypoint.sh` (executable script)
- `README.md` (documentation)

Check with:
```bash
ls -la action.yml Dockerfile entrypoint.sh README.md
```

## Token Permission Issues

### GITHUB_TOKEN Permissions

**Problem**: The default `GITHUB_TOKEN` doesn't have enough permissions.

**Solution**: The workflow now includes explicit permissions:
```yaml
permissions:
  contents: write    # Create releases and tags
  packages: write    # Docker registry access
  issues: write      # Create issues if needed
  pull-requests: write # PR management
```

### Repository Settings

**Problem**: Repository settings prevent Actions from creating releases.

**Solution**: 
1. Go to Settings → Actions → General
2. Under "Workflow permissions" select:
   - "Read and write permissions"
   - ✅ "Allow GitHub Actions to create and approve pull requests"

## Docker Build Issues

### Docker Build Failures

**Problem**: The action fails to build the Docker image.

**Solution**: Test locally first:
```bash
docker build -t ssh-action-test .
```

Common issues:
- Missing `Dockerfile`
- Incorrect file permissions on `entrypoint.sh`
- Package installation failures

Fix permissions:
```bash
chmod +x entrypoint.sh
```

### Alpine Package Issues

**Problem**: Packages fail to install in Alpine Linux.

**Solution**: Update package names in `Dockerfile`:
```dockerfile
RUN apk add --no-cache \
    openssh-client \
    sshpass \
    bash
```

## Release Process Issues

### Tag Already Exists

**Problem**: Trying to create a release with an existing tag.

**Solution**: Delete the tag first:
```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag  
git push origin --delete v1.0.0

# Create new tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### Release Script Permission Denied

**Problem**: `./scripts/release.sh` fails with permission denied.

**Solution**: Make the script executable:
```bash
chmod +x scripts/release.sh
```

### Git Configuration Issues

**Problem**: Git operations fail during release.

**Solution**: The workflow automatically configures Git:
```bash
git config user.name "GitHub Actions"
git config user.email "actions@github.com"
```

## SSH Action Usage Issues

### SSH Connection Failures

**Problem**: The action fails to connect to remote hosts.

**Common causes**:
- Incorrect host/IP address
- Wrong SSH port
- Firewall blocking connections
- Invalid credentials

**Solution**: Test SSH connection manually:
```bash
ssh -p 22 username@hostname
```

### Authentication Issues

**Problem**: SSH authentication fails.

**Solution**: 
1. Verify credentials are correct
2. Check if password authentication is enabled on the server
3. Consider using SSH key authentication (future enhancement)

### Script Execution Failures

**Problem**: Scripts fail to execute on remote host.

**Solution**:
1. Test the script locally first
2. Check file permissions on remote host
3. Use absolute paths in scripts
4. Add proper error handling

## GitHub Marketplace Issues

### Action Not Appearing in Marketplace

**Problem**: Action doesn't show up in GitHub Marketplace.

**Solution**:
1. Ensure repository is public
2. Verify `action.yml` has proper branding
3. Check that a release has been created
4. Manually publish through repository page

### Marketplace Publication Fails

**Problem**: GitHub rejects marketplace submission.

**Solution**: 
1. Ensure action actually works
2. Add comprehensive documentation
3. Include usage examples
4. Follow GitHub's marketplace guidelines

## Getting Help

If you encounter issues not covered here:

1. **Check workflow logs** in the Actions tab
2. **Review the error messages** carefully
3. **Test components individually** (Docker build, SSH connection, etc.)
4. **Create an issue** in the repository with:
   - Error message
   - Workflow logs
   - Steps to reproduce

## Quick Fixes Checklist

- [ ] Repository is public
- [ ] All required files exist
- [ ] Scripts are executable (`chmod +x`)
- [ ] Workflow permissions are set
- [ ] Repository Actions settings allow write access
- [ ] Docker image builds successfully
- [ ] SSH credentials are valid
- [ ] Release follows semantic versioning

Following this checklist should resolve most common issues! 