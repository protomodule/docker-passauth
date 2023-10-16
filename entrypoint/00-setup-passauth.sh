#!/bin/sh
set -e

echo ""
echo "p o w e r e d   b y   . . ." | lolcat
figlet "Protomodule" | lolcat
nginx -v
echo ""

if [ -z "$PROXY_TARGET" ]; then
  echo "🔊  Environment variable \$PROXY_TARGET not configured."
  echo ""

  echo "🛑 Missing \$PROXY_TARGET might point to a faulty configuration. Stopping now!" | boxes -d stone -p a2v1 | lolcat -g ff0000:ff9999
  exit 1
fi

# Check $PORT or set fallback -> to be substituted in nginx config
if [ -z "$PORT" ]; then
  echo "🚨  Environment variable \$PORT not configured. Falling back to port 80"
  export PORT=80
fi

# Setup basic auth when required
## To enable basic auth the environment variable BASIC_AUTH must be set
echo "───> 👋  Hello"
if [ -z "$BASIC_AUTH" ]; then
  echo " └─> 🔓  Starting publicly - no password protection"
else
  echo " └─> 🔐  Activating password protection"
  echo ""

  export NGINX_HTPASSWD=/etc/nginx/htpasswd
  export IFS=";"
  touch $NGINX_HTPASSWD
  for CREDENTIALS in $BASIC_AUTH; do
    sh -c "htpasswd -bB $NGINX_HTPASSWD $CREDENTIALS"
  done
  echo ""
fi

NGINX_CONFD=/etc/nginx/conf.d

echo "───> 🛠️   Compiling templates"
for template in /etc/nginx/esh/*
do
  echo " └───>   $template"
  TEMPLATE_FILE=`basename $template`
  esh "$template" \
    PORT=${PORT:-80} \
    NAMESERVER=${NAMESERVER:-127.0.0.11} \
    PROXY_PROTOCOL="${PROXY_PROTOCOL:-http}" \
    PROXY_TARGET="$PROXY_TARGET" \
    PROXY_HOSTNAME="$PROXY_HOSTNAME" \
    ENABLED_HTTPS_REDIRECT="$ENABLED_HTTPS_REDIRECT" \
    NGINX_HTPASSWD="$NGINX_HTPASSWD" \
    CLIENT_MAX_BODY_SIZE="$CLIENT_MAX_BODY_SIZE" \
    CONTENT_SECURITY_POLICY="$CONTENT_SECURITY_POLICY" \
    CONTENT_SECURITY_POLICY_REPORT_ONLY="$CONTENT_SECURITY_POLICY_REPORT_ONLY" \
    SERVER_NAME="$SERVER_NAME" \
    SSL_CERTIFICATE="$SSL_CERTIFICATE" \
    SSL_CERTIFICATE_KEY="$SSL_CERTIFICATE_KEY" \
      > $NGINX_CONFD/${TEMPLATE_FILE%.template}
done

echo ""
echo "───> ✅  Nginx sites written to $NGINX_CONFD"
echo ""
