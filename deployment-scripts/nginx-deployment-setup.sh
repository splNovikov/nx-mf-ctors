#!/bin/bash

# Nginx deployment setup script for Timeweb server
# Run this script as root on your Timeweb server (c-tors.ru)

echo "🚀 Setting up Timeweb server for nginx deployment..."

# Update system packages
apt update && apt upgrade -y

# Install necessary packages
apt install -y nginx curl wget git

# Create web directories
mkdir -p /var/www/host
mkdir -p /var/www/vacationPay

# Set ownership
chown -R www-data:www-data /var/www/host
chown -R www-data:www-data /var/www/vacationPay

# Create nginx configuration for host application
tee /etc/nginx/sites-available/host > /dev/null <<EOF
server {
    listen 80;
    server_name c-tors.ru www.c-tors.ru;

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
tee /etc/nginx/sites-available/vacationPay > /dev/null <<EOF
server {
    listen 80;
    server_name vacation-pay.c-tors.ru;

    root /var/www/vacationPay;
    index index.html;


    location /vacationPay {
        alias /var/www/vacationPay;
        try_files \$uri \$uri/ /index.html;
    }

    location /vacationPay/ {
        alias /var/www/vacationPay/;
        try_files \$uri \$uri/ /vacationPay/index.html;
    }

    # Handle static assets for vacationPay app
    location ~* ^/vacationPay/.*\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
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
ln -sf /etc/nginx/sites-available/host /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/vacationPay /etc/nginx/sites-enabled/

# Remove default nginx site
rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx configuration test passed"
    # Restart nginx
    systemctl restart nginx
    systemctl enable nginx
    echo "✅ Nginx restarted and enabled"
else
    echo "❌ Nginx configuration test failed"
    exit 1
fi

# Setup firewall (if ufw is available)
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    echo "✅ Firewall configured"
fi

echo "✅ Server setup complete!"
echo "📋 Next steps:"
echo "1. Verify you can SSH without password: ssh root@c-tors.ru"
echo "2. Add GitHub secrets as described in the deployment guide"
echo "3. Test deployment by pushing to main branch"
echo ""
echo "🌐 Your applications will be available at:"
echo "   - Host app: http://c-tors.ru/"
echo "   - VacationPay app: http://vacation-pay.c-tors.ru/"
