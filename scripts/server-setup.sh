#!/bin/bash

# Server setup script for Timeweb deployment
# Run this script on your Timeweb server (45.144.221.205)

echo "🚀 Setting up Timeweb server for deployment..."

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install necessary packages
sudo apt install -y nginx curl wget git

# Create web directories
sudo mkdir -p /var/www/host
sudo mkdir -p /var/www/vacationPay

# Set ownership
sudo chown -R www-data:www-data /var/www/host
sudo chown -R www-data:www-data /var/www/vacationPay

# Create nginx configuration for host application
sudo tee /etc/nginx/sites-available/host > /dev/null <<EOF
server {
    listen 80;
    server_name host.your-domain.com;  # Replace with your domain
    root /var/www/host;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Handle static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
EOF

# Create nginx configuration for vacationPay application
sudo tee /etc/nginx/sites-available/vacationPay > /dev/null <<EOF
server {
    listen 80;
    server_name vacation.your-domain.com;  # Replace with your domain
    root /var/www/vacationPay;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Handle static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
EOF

# Enable sites
sudo ln -sf /etc/nginx/sites-available/host /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/vacationPay /etc/nginx/sites-enabled/

# Remove default nginx site
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
sudo systemctl enable nginx

# Setup firewall (if ufw is available)
if command -v ufw &> /dev/null; then
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw --force enable
fi

echo "✅ Server setup complete!"
echo "📋 Next steps:"
echo "1. Add your GitHub Actions public key to ~/.ssh/authorized_keys"
echo "2. Configure your domain DNS to point to this server"
echo "3. Consider setting up SSL certificates (Let's Encrypt)" 