# SSH Remote Script Executor

A GitHub Action that allows you to execute scripts on remote hosts via SSH.

## Features

- Execute any script on a remote host via SSH
- Configurable SSH port
- Password-based authentication
- Secure handling of credentials
- Detailed logging and error handling

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `host` | Remote host to connect to | Yes | - |
| `username` | SSH username | Yes | - |
| `password` | SSH password | Yes | - |
| `port` | SSH port | No | `22` |
| `script` | Script to execute on the remote host | Yes | - |
| `envs` | Environment variables (comma-separated: "VAR1=value1,VAR2=value2") | No | - |

## Usage

### Basic Example

```yaml
name: Deploy to Server
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Execute deployment script
      uses: ./
      with:
        host: 'your-server.com'
        username: 'deploy'
        password: ${{ secrets.SSH_PASSWORD }}
        script: |
          cd /var/www/html
          git pull origin main
          sudo systemctl restart nginx
```

### Custom Port Example

```yaml
- name: Execute script on custom port
  uses: ./
  with:
    host: 'your-server.com'
    username: 'admin'
    password: ${{ secrets.SSH_PASSWORD }}
    port: '2222'
    script: |
      echo "Hello from remote server!"
      uptime
      df -h
```

### Multi-line Script Example

```yaml
- name: Server maintenance
  uses: ./
  with:
    host: ${{ secrets.SERVER_HOST }}
    username: ${{ secrets.SERVER_USER }}
    password: ${{ secrets.SERVER_PASSWORD }}
    script: |
      #!/bin/bash
      echo "Starting maintenance..."
      
      # Update system packages
      sudo apt update && sudo apt upgrade -y
      
      # Clean up logs
      sudo find /var/log -name "*.log" -type f -mtime +30 -delete
      
      # Restart services
      sudo systemctl restart nginx
      sudo systemctl restart mysql
      
      echo "Maintenance completed!"
```

### Environment Variables Example

```yaml
- name: Deploy application with environment variables
  uses: ./
  with:
    host: ${{ secrets.SERVER_HOST }}
    username: ${{ secrets.SERVER_USER }}
    password: ${{ secrets.SERVER_PASSWORD }}
    envs: 'DEPLOY_ENV=production,APP_VERSION=1.2.3,DATABASE_URL=${{ secrets.DATABASE_URL }}'
    script: |
      #!/bin/bash
      echo "Deploying application..."
      echo "Environment: $DEPLOY_ENV"
      echo "Version: $APP_VERSION"
      
      # Use environment variables in deployment
      cd /var/www/app
      export DATABASE_URL="$DATABASE_URL"
      
      # Deploy with environment-specific settings
      if [ "$DEPLOY_ENV" = "production" ]; then
        npm run build:production
      else
        npm run build:staging
      fi
      
      echo "Deployment completed for version $APP_VERSION"
```

### Complex Environment Variables

```yaml
- name: Deploy with complex environment variables
  uses: ./
  with:
    host: ${{ secrets.SERVER_HOST }}
    username: ${{ secrets.SERVER_USER }}
    password: ${{ secrets.SERVER_PASSWORD }}
    envs: |
      NODE_ENV=production,
      API_KEY=${{ secrets.API_KEY }},
      DB_HOST=localhost,
      DB_PORT=5432,
      REDIS_URL=redis://localhost:6379,
      LOG_LEVEL=info
    script: |
      #!/bin/bash
      echo "=== Deployment Configuration ==="
      echo "Environment: $NODE_ENV"
      echo "Database: $DB_HOST:$DB_PORT"
      echo "Redis: $REDIS_URL"
      echo "Log Level: $LOG_LEVEL"
      
      # Your deployment script here
      pm2 restart app --env production
      echo "Application restarted with new environment"
```

## Security Considerations

1. **Never hardcode passwords** in your workflow files. Always use GitHub Secrets to store sensitive information.

2. **Store credentials as secrets**:
   - Go to your repository Settings → Secrets and variables → Actions
   - Add secrets for `SSH_PASSWORD`, `SERVER_HOST`, `SERVER_USER`, etc.

3. **Use the principle of least privilege** - create dedicated deployment users with minimal required permissions.

4. **Consider using SSH keys** instead of passwords for enhanced security (this action currently supports password authentication).

5. **Environment Variables Security**:
   - Always use GitHub Secrets for sensitive environment variables
   - Never expose secrets in plain text in the `envs` parameter
   - Use the format: `envs: 'PUBLIC_VAR=value,SECRET_VAR=${{ secrets.SECRET_VAR }}'`
   - Environment variable names are validated to prevent injection attacks
   - Values are properly escaped to handle special characters safely

## Error Handling

The action will fail if:
- SSH connection cannot be established
- Authentication fails
- The script execution returns a non-zero exit code
- Required inputs are missing

## Troubleshooting

### Connection Issues
- Verify the host, username, and password are correct
- Check if the SSH port is accessible
- Ensure the remote host allows SSH connections

### Script Execution Issues
- Test your script locally first
- Use absolute paths in your scripts
- Check file permissions on the remote host
- Add error handling to your scripts

### Permission Issues
- Ensure the SSH user has necessary permissions
- Use `sudo` in your script if elevated privileges are required
- Verify file and directory permissions

## Repository Setup

### Quick Setup Script

Use the interactive setup script to configure your repository:

```bash
./scripts/setup-repository.sh
```

This script helps you:
- ✅ Check repository status
- ✅ Make repository public (for marketplace)
- ✅ Validate marketplace requirements
- ✅ Create releases
- ✅ Get setup instructions

### Repository Visibility Options

#### **Public Repository (Marketplace)**
- ✅ Can be published to GitHub Marketplace
- ✅ Discoverable by the community
- ✅ Available for public use
- ⚠️  Code is visible to everyone

#### **Private Repository (Internal Use)**
- ✅ Works perfectly for private use
- ✅ Share with collaborators
- ✅ All action features available
- ❌ Cannot publish to marketplace

Choose the option that best fits your needs!

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License. 