# ---- Nginx ----
FROM nginx:1-alpine-slim
LABEL maintainer="Lukas Korl <hello@lukaskorl.com>"

# Install dependencies for nginx config templating
RUN apk add esh apache2-utils figlet lolcat boxes --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/

# Remove preinstalled site configurations
RUN rm /etc/nginx/conf.d/* && \
    rm /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh && \
    mkdir -p /etc/nginx/esh

# Add custom configuration and startup scripts
COPY entrypoint/* /docker-entrypoint.d
COPY conf.d/* /etc/nginx/esh/
COPY nginx.conf /etc/nginx/nginx.conf
COPY html/* /usr/share/nginx/html/
