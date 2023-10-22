# 🚦 Passway
## Opinionated Nginx-based gateway container 

This Docker container acts as a thin reverse proxy layer for adding common HTTP headers, SSL endpoint termination and optionally basic auth so that your application does not need to implement common functionality.

## Configuration

The configuration for this container is provided via environment variables at start-time:

  - `PROXY_TARGET` Target address and possibly port of upstream
  - (optional) `PROXY_PROTOCOL` Protocol to use when proxying to upstream (default to http)
  - (optional) `PROXY_HOSTNAME` Hostname to present to upstream
  - (optional) `PORT` Specify port on which nginx will listen (defaults to 80 or 443 when SSL is enabled)
  - (optional) `SERVER_NAME` For nginx to listen to
  - (optional) `NAMESERVER` **Important:** If not specified nameserver will fallback to `127.0.0.11` for Docker usage
  - (optional) `ENABLED_HTTPS_REDIRECT` Force 301 redirects to HTTPS. For use where this gateway is used behind another SSL termination endpoint.
  - (optional) `CLIENT_MAX_BODY_SIZE` Defaults to `25M` if not specified
  - (optional) `CONTENT_SECURITY_POLICY` Adds a CSP header
  - (optional) `CONTENT_SECURITY_POLICY_REPORT_ONLY` Adds a CSP reporting header
  - (optional) `CORS_POLICY_ORIGIN` Adds origin CORS header and other configured CORS headers to response
  - (optional) `CORS_POLICY_METHODS` Defaults to safe methods `GET` and `HEAD` - only applicable when `CORS_POLICY_ORIGIN` is set
  - (optional) `CORS_POLICY_ALLOW_CREDENTIALS` - Only valid value is `yes`. Otherwise header will be omitted. Only applicable when `CORS_POLICY_ORIGIN` is set
  - (optional) `CORS_POLICY_ALLOW_HEADERS` - only applicable when `CORS_POLICY_ORIGIN` is set
  - (optional) `CORS_POLICY_EXPOSE_HEADERS` - only applicable when `CORS_POLICY_ORIGIN` is set
  - (optional) `BASIC_AUTH` If you need basic auth protection add "<USER> <PASSWORD>" combinations for every user separated by semicolon

## SSL Support

This reverse proxy can also handle SSL endpoint termination.

  - (optional) `SSL_CERTIFICATE` Specify the path to the SSL certificate within the container.
  - (optional) `SSL_CERTIFICATE_KEY`

### Generate a certificate for local testing

If you have OpenSSL installed run the following command to generate your private key and certificate for development purposes:

```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/CN=localhost" -addext "subjectAltName = IP:127.0.0.1" -keyout selfsigned.key -out selfsigned.crt
```

**⚠️ Attention:** Do not use this certificate in a production configuration.

## Client-certificate based authentication

If you have OpenSSL installed run the following commands to generate a certificate for development purposes:

```
# Generate your own CA
openssl genrsa -out local-ca.key 4096
openssl req -new -x509 -days 3650 -key local-ca.key -out local-ca.crt -subj "/CN=localhost" -addext "subjectAltName = IP:127.0.0.1"

# Create a client keypair. Performed this once for each user.
openssl genrsa -out client-user.key 2048
openssl req -new -key client-user.key -out client-user.csr -subj "/CN=localhost" -addext "subjectAltName = IP:127.0.0.1"

# Sign CSR with CA key
## Increment the serial to reissue the certificate
openssl x509 -req -days 365 -in client-user.csr -CA local-ca.crt -CAkey local-ca.key -set_serial 01 -out client-user.crt
```