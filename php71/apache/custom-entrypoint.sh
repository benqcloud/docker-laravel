#!/bin/bash
# /usr/local/bin/custom-entrypoint.sh
set -e

CONF_SOURCE="/etc/apache2/conf-available/security-headers-hardened.conf.disabled"
CONF_TARGET="/etc/apache2/conf-enabled/zz-security-headers-hardened.conf"

if [ "${ENABLE_SECURITY_HEADERS_HARDENED:-false}" = "true" ]; then
    cp -f "$CONF_SOURCE" "$CONF_TARGET"
    echo "[entrypoint] Hardened security headers ENABLED"
else
    rm -f "$CONF_TARGET"
    echo "[entrypoint] Hardened security headers DISABLED (default)"
fi

apache2ctl configtest

exec docker-php-entrypoint "$@"
