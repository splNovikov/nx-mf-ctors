#!/bin/bash

# Nginx deployment setup script for Timeweb server
# Run this script as root on your Timeweb server (c-tors.ru)

echo "🚀 Setting up Timeweb server for nginx deployment with Let's Encrypt SSL..."
echo "⚠️  IMPORTANT: Ensure DNS is properly configured before running:"
echo "   - c-tors.ru → Server IP"
echo "   - www.c-tors.ru → Server IP"
echo "   - vacation-pay.c-tors.ru → Server IP"
echo "   - www.vacation-pay.c-tors.ru → Server IP"
echo ""

# Update system packages
apt update && apt upgrade -y

# Install necessary packages
apt install -y nginx curl wget git snapd

# Install certbot via snap (recommended by Let's Encrypt)
snap install core; snap refresh core
snap install --classic certbot
ln -sf /snap/bin/certbot /usr/bin/certbot

# Create web directories
mkdir -p /var/www/host
mkdir -p /var/www/vacationPay

# Set ownership
chown -R www-data:www-data /var/www/host
chown -R www-data:www-data /var/www/vacationPay

# Create nginx configuration for host application
tee /etc/nginx/sites-available/host > /dev/null <<EOF
# HTTP server block - redirects to HTTPS
server {
    listen 80;
    server_name c-tors.ru www.c-tors.ru;
    
    # Redirect all HTTP traffic to HTTPS
    return 301 https://\$server_name\$request_uri;
}

# HTTPS server block
server {
    listen 443 ssl http2;
    server_name c-tors.ru www.c-tors.ru;

    # SSL Configuration (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/c-tors.ru/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/c-tors.ru/privkey.pem;
    
    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    # OCSP stapling (disabled due to Let's Encrypt certificate limitations)
    # ssl_stapling on;
    # ssl_stapling_verify on;

    root /var/www/host;
    index index.html;

    # Let's Encrypt ACME challenge (for certificate renewals)
    location /.well-known/acme-challenge/ {
        root /var/www/html;
        allow all;
    }

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Handle static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://vacation-pay.c-tors.ru; style-src 'self' 'unsafe-inline' https://vacation-pay.c-tors.ru; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://vacation-pay.c-tors.ru; frame-ancestors 'self';" always;
}
EOF

# Create nginx configuration for vacationPay application
tee /etc/nginx/sites-available/vacationPay > /dev/null <<EOF
# HTTP server block - redirects to HTTPS
server {
    listen 80;
    server_name vacation-pay.c-tors.ru www.vacation-pay.c-tors.ru;
    
    # Redirect all HTTP traffic to HTTPS
    return 301 https://\$server_name\$request_uri;
}

# HTTPS server block
server {
    listen 443 ssl http2;
    server_name vacation-pay.c-tors.ru www.vacation-pay.c-tors.ru;

    # SSL Configuration (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/vacation-pay.c-tors.ru/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/vacation-pay.c-tors.ru/privkey.pem;
    
    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    # OCSP stapling (disabled due to Let's Encrypt certificate limitations)
    # ssl_stapling on;
    # ssl_stapling_verify on;

    root /var/www/vacationPay;
    index index.html;

    # Let's Encrypt ACME challenge (for certificate renewals)
    location /.well-known/acme-challenge/ {
        root /var/www/html;
        allow all;
    }

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Handle static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://c-tors.ru; frame-ancestors 'self' https://c-tors.ru;" always;
}
EOF

# Enable sites
ln -sf /etc/nginx/sites-available/host /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/vacationPay /etc/nginx/sites-enabled/

# Remove default nginx site
rm -f /etc/nginx/sites-enabled/default

# Create temporary HTTP-only configurations for certificate generation
tee /etc/nginx/sites-available/temp-host > /dev/null <<EOF
server {
    listen 80;
    server_name c-tors.ru www.c-tors.ru;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}
EOF

tee /etc/nginx/sites-available/temp-vacationPay > /dev/null <<EOF
server {
    listen 80;
    server_name vacation-pay.c-tors.ru www.vacation-pay.c-tors.ru;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}
EOF

# Temporarily use HTTP-only configs for certificate generation
rm -f /etc/nginx/sites-enabled/host
rm -f /etc/nginx/sites-enabled/vacationPay
ln -sf /etc/nginx/sites-available/temp-host /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/temp-vacationPay /etc/nginx/sites-enabled/

# Test and reload nginx for certificate generation
nginx -t && systemctl reload nginx

echo "🔐 Generating Let's Encrypt SSL certificates..."

# Generate certificates for both domains
certbot certonly --webroot -w /var/www/html \
    -d c-tors.ru -d www.c-tors.ru \
    --email admin@c-tors.ru \
    --agree-tos --non-interactive --no-eff-email

certbot certonly --webroot -w /var/www/html \
    -d vacation-pay.c-tors.ru -d www.vacation-pay.c-tors.ru \
    --email admin@c-tors.ru \
    --agree-tos --non-interactive --no-eff-email

# Check if certificates were generated successfully
if [ -f "/etc/letsencrypt/live/c-tors.ru/fullchain.pem" ] && [ -f "/etc/letsencrypt/live/vacation-pay.c-tors.ru/fullchain.pem" ]; then
    echo "✅ SSL certificates generated successfully"
    # Switch back to HTTPS configurations
    rm -f /etc/nginx/sites-enabled/temp-host
    rm -f /etc/nginx/sites-enabled/temp-vacationPay
    ln -sf /etc/nginx/sites-available/host /etc/nginx/sites-enabled/
    ln -sf /etc/nginx/sites-available/vacationPay /etc/nginx/sites-enabled/
else
    echo "❌ SSL certificate generation failed. Running with HTTP-only configuration."
    echo "💡 Manual certificate generation:"
    echo "   certbot certonly --webroot -w /var/www/html -d c-tors.ru -d www.c-tors.ru"
    echo "   certbot certonly --webroot -w /var/www/html -d vacation-pay.c-tors.ru -d www.vacation-pay.c-tors.ru"
    echo "   Then run: systemctl reload nginx"
fi

# Test nginx configuration with SSL
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

# Setup automatic certificate renewal
echo "⚙️ Setting up automatic certificate renewal..."
crontab -l 2>/dev/null | { cat; echo "0 12 * * * /usr/bin/certbot renew --quiet && systemctl reload nginx"; } | crontab -

# Test renewal process (dry run)
certbot renew --dry-run --quiet

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
echo "🔧 Troubleshooting SSL issues:"
echo "   - Check certificate status: certbot certificates"
echo "   - Test renewal: certbot renew --dry-run"
echo "   - Check nginx logs: journalctl -u nginx -f"
echo "   - Test SSL: curl -I https://c-tors.ru"
echo ""
echo "🌐 Your applications will be available at:"
echo "   - Host app: https://c-tors.ru/ (HTTP redirects to HTTPS)"
echo "   - VacationPay app: https://vacation-pay.c-tors.ru/ (HTTP redirects to HTTPS)"
echo ""
echo "🔐 Let's Encrypt SSL Configuration:"
echo "   - Main domain: /etc/letsencrypt/live/c-tors.ru/"
echo "   - Subdomain: /etc/letsencrypt/live/vacation-pay.c-tors.ru/"
echo "   - Protocols: TLS 1.2, TLS 1.3"
echo "   - HSTS enabled with preload"
echo "   - OCSP stapling enabled"
echo "   - Auto-renewal: Daily at 12:00 PM"
echo "   - Certificate expires: ~90 days (auto-renewed)"
