# 🔐 Nginx Basic Auth Gateway

This Docker container acts as a thin reverse proxy layer for adding common HTTP headers and optionally basic auth so that your application does not need to implement it.

## Configuration

The configuration for this container is provided with environment variables:

  - `PROXY_TARGET` Target address and possibly port of upstream
  - (optional) `PROXY_PROTOCOL` Protocol to use when proxying to upstream (default to http)
  - (optional) `PROXY_HOSTNAME` Hostname to present to upstream
  - (optional) `PORT` Specify port on which nginx will listen (defaults to 80)
  - (optional) `SERVER_NAME` For nginx to listen to
  - (optional) `NAMESERVER` **Important:** If not specified nameserver will fallback to `127.0.0.11` for Docker usage
  - (optional) `ENABLED_HTTPS_REDIRECT` Force 301 redirects to HTTPS
  - (optional) `CLIENT_MAX_BODY_SIZE` Defaults to `25M` if not specified
  - (optional) `CONTENT_SECURITY_POLICY` Adds a CSP header
  - (optional) `CONTENT_SECURITY_POLICY_REPORT_ONLY` Adds a CSP reporting header
  - (optional) `NGINX_AUTH` If you need basic auth protection add "<USER> <PASSWORD>" combinations for every user separated by semicolon