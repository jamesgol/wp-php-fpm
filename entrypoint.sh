#!/bin/bash

cat > /etc/msmtprc <<EOF
account default
host ${MAILER_HOST:-mailcatcher}
port ${MAILER_PORT:-1025}
auto_from on
EOF

cat >> /etc/php-fpm.d/www.conf <<EOF
php_value[session.save_handler] = ${SESSION_HANDLER:-files}
php_value[session.save_path]    = '${SESSION_PATH:-/var/lib/php/sessions}'
EOF


if [ ! -z "${NR_LICENSE_KEY}" ]; then
cat > /etc/php/*/mods-available/newrelic.ini <<EOF
extension = "newrelic.so"

[newrelic]
newrelic.enabled = true
newrelic.framework.wordpress.hooks = true
newrelic.daemon.address = ${NR_HOST}
newrelic.license = ${NR_LICENSE_KEY}
newrelic.appname = ${NR_APP_NAME:-wordpress}
EOF
else
cat > /etc/php/*/mods-available/newrelic.ini <<EOF
extension = "newrelic.so"

[newrelic]
newrelic.enabled = false
EOF
fi

# changing this will break dependent images
exec /usr/sbin/php-fpm -F
