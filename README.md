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

## Security Considerations

1. **Never hardcode passwords** in your workflow files. Always use GitHub Secrets to store sensitive information.

2. **Store credentials as secrets**:
   - Go to your repository Settings → Secrets and variables → Actions
   - Add secrets for `SSH_PASSWORD`, `SERVER_HOST`, `SERVER_USER`, etc.

3. **Use the principle of least privilege** - create dedicated deployment users with minimal required permissions.

4. **Consider using SSH keys** instead of passwords for enhanced security (this action currently supports password authentication).

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

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License. 