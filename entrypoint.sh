#!/bin/bash
set -e

echo "=== SLiMS 9 Bulian - Entrypoint ==="

# =============================================
# Generate config/env.php dari APP_ENV
# =============================================
APP_ENV="${APP_ENV:-production}"

echo "Setting environment: $APP_ENV"

cat > /var/www/html/config/env.php << EOF
<?php
\$env = "${APP_ENV}";
\$conditional_environment = "${APP_ENV}";
\$based_on_ip = false;
\$range_ip = [''];
if (\$based_on_ip) {
    if (array_key_exists('HTTP_X_FORWARDED_FOR', \$_SERVER) && in_array(\$_SERVER['HTTP_X_FORWARDED_FOR'], \$range_ip)) {
        \$env = \$conditional_environment;
    } else if (in_array(\$_SERVER['REMOTE_ADDR'], \$range_ip)) {
        \$env = \$conditional_environment;
    }   
}
EOF

# =============================================
# Generate config/database.php dari env vars
# =============================================
echo "Setting database config..."

cat > /var/www/html/config/database.php << EOF
<?php
return [
    'default_profile' => 'SLiMS',
    'proxy' => false,
    'nodes' => [
        'SLiMS' => [
            'host' => '${DB_HOST:-localhost}',
            'database' => '${DB_NAME:-senayan}',
            'port' => '${DB_PORT:-3306}',
            'username' => '${DB_USER:-root}',
            'password' => '${DB_PASSWORD:-}',
            'options' => [
                'storage_engine' => 'MyISAM'
            ]
        ]
    ]
];
EOF

# =============================================
# Set permissions
# =============================================
echo "Setting permissions..."
chown -R www-data:www-data /var/www/html/files \
    /var/www/html/repository \
    /var/www/html/images \
    /var/www/html/config \
    /var/www/html/cache 2>/dev/null || true

chmod -R 775 /var/www/html/files \
    /var/www/html/repository \
    /var/www/html/images \
    /var/www/html/config 2>/dev/null || true

echo "=== Starting Apache ==="
exec apache2-foreground