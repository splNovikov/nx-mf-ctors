# Deployment Guide - Timeweb Server

This guide explains how to set up automated deployment to your Timeweb server (45.144.221.205) for both the `host` and `vacationPay` applications.

## 📋 Prerequisites

- Access to your Timeweb server (45.144.221.205)
- GitHub repository with admin access
- SSH access to the server

## 🔧 Setup Steps

### 1. Server Configuration

Connect to your Timeweb server and run the setup script:

```bash
# Connect to your server
ssh root@45.144.221.205

# Download and run the setup script
wget https://raw.githubusercontent.com/your-repo/nx-mf-ctors/main/scripts/server-setup.sh
chmod +x server-setup.sh
./server-setup.sh
```

### 2. SSH Key Configuration

#### On your local machine:

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "github-actions@your-domain.com" -f ~/.ssh/github_actions

# Copy public key to server
ssh-copy-id -i ~/.ssh/github_actions.pub root@45.144.221.205

# Get the private key content (for GitHub secrets)
cat ~/.ssh/github_actions

# Get known hosts entry
ssh-keyscan -H 45.144.221.205
```

### 3. GitHub Repository Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions**

Add these secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `SSH_PRIVATE_KEY` | Content of `~/.ssh/github_actions` | Private SSH key for server access |
| `SSH_USER` | `root` (or your username) | SSH username for the server |
| `KNOWN_HOSTS` | Output from `ssh-keyscan` command | Server's SSH fingerprint |

### 4. Domain Configuration (Optional)

If you have domains, update the nginx configuration:

```bash
# On your server, edit the nginx configs
sudo nano /etc/nginx/sites-available/host
sudo nano /etc/nginx/sites-available/vacationPay

# Replace the server_name values with your actual domains
# Then restart nginx
sudo systemctl reload nginx
```

## 🚀 Deployment Process

### Automatic Deployment

The deployment happens automatically when you push to the `main` branch:

1. **Build Phase**: Both applications are built using Nx
2. **Deploy Phase**: Files are transferred to the server via SCP
3. **Server Update**: Nginx is reloaded to serve the new files

### Manual Deployment

You can also trigger deployment manually:

```bash
# Build both applications locally
yarn nx build host --configuration=production
yarn nx build vacationPay --configuration=production

# Deploy to server
scp -r ./dist/apps/host/* root@45.144.221.205:/var/www/host/
scp -r ./dist/apps/vacationPay/* root@45.144.221.205:/var/www/vacationPay/
```

## 📁 Server Directory Structure

```
/var/www/
├── host/                 # Host application files
│   ├── index.html
│   ├── main.js
│   └── assets/
└── vacationPay/          # VacationPay application files
    ├── index.html
    ├── main.js
    └── assets/
```

## 🔍 Monitoring & Troubleshooting

### Check deployment logs:
```bash
# View nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Check nginx status
sudo systemctl status nginx

# Test nginx configuration
sudo nginx -t
```

### Common Issues:

1. **SSH connection failed**: Check if SSH key is properly added to `~/.ssh/authorized_keys`
2. **Permission denied**: Ensure `/var/www/` directories have correct permissions
3. **Nginx not serving files**: Check nginx configuration and restart service

## 🔒 Security Considerations

1. **SSH Key Security**: Keep your private key secure and never commit it to the repository
2. **Firewall**: The setup script configures basic firewall rules
3. **HTTPS**: Consider setting up SSL certificates using Let's Encrypt:

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificates (replace with your domains)
sudo certbot --nginx -d host.your-domain.com -d vacation.your-domain.com
```

## 🎯 Application URLs

After deployment, your applications will be available at:

- **Host Application**: `http://45.144.221.205` (or your host domain)
- **VacationPay Application**: `http://45.144.221.205:8080` (or your vacation domain)

## 📝 Alternative Deployment Methods

### Using Docker (Advanced)

If you prefer containerized deployment, you can modify the CI/CD to use Docker:

1. Add Dockerfile to each application
2. Build Docker images in CI/CD
3. Deploy using Docker Compose

### Using PM2 (For Node.js apps)

If your applications need a process manager:

1. Install PM2 on server
2. Create ecosystem.config.js
3. Deploy using PM2 commands

## 🆘 Support

If you encounter issues:

1. Check the GitHub Actions logs for deployment errors
2. Verify server logs for runtime issues
3. Ensure all secrets are properly configured
4. Test SSH connection manually 