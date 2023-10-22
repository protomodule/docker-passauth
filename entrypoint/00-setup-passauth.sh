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
  if [ -z "$SSL_CERTIFICATE" ]; then
    export PORT=80
  else
    export PORT=443
  fi
  echo "🚨  Environment variable \$PORT not configured. Falling back to port $PORT"
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
    CORS_POLICY_ORIGIN="$CORS_POLICY_ORIGIN" \
    CORS_POLICY_METHODS="${CORS_POLICY_METHODS:-GET, HEAD}" \
    CORS_POLICY_ALLOW_CREDENTIALS="${CORS_POLICY_ALLOW_CREDENTIALS}" \
    CORS_POLICY_ALLOW_HEADERS="${CORS_POLICY_ALLOW_HEADERS:-Accept, Accept-Language, Content-Language, Content-Type, Origin, X-Requested-With}" \
    CORS_POLICY_EXPOSE_HEADERS="${CORS_POLICY_EXPOSE_HEADERS}" \
    SERVER_NAME="$SERVER_NAME" \
    SSL_CERTIFICATE="$SSL_CERTIFICATE" \
    SSL_CERTIFICATE_KEY="$SSL_CERTIFICATE_KEY" \
      > $NGINX_CONFD/${TEMPLATE_FILE%.template}
done

echo ""
echo "───> ✅  Nginx sites written to $NGINX_CONFD"
echo ""
