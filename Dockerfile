# ---- Nginx ----
FROM nginx:1.21
LABEL maintainer="Lukas Korl <hello@lukaskorl.com>"

# Install dependencies
RUN apt-get update \
    && apt-get install -y wget apache2-utils figlet lolcat boxes wget \
    && apt-get clean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/games/lolcat /usr/bin/lolcat

# Install esh for nginx config templating
RUN cd /usr/local/bin \
    && wget https://raw.githubusercontent.com/jirutka/esh/v0.3.2/esh \
    && chmod ugo+x /usr/local/bin/esh \
    && echo '9084e3e8e70e4ea81c40cd1cf85559196c0fa2cc  esh' | sha1sum -c \
    || exit 1

# Remove preinstalled site configurations
RUN rm /etc/nginx/conf.d/* && \
    rm /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh && \
    mkdir -p /etc/nginx/esh

# Add custom configuration and startup scripts
COPY entrypoint/* /docker-entrypoint.d
COPY conf.d/* /etc/nginx/esh/
COPY nginx.conf /etc/nginx/nginx.conf
COPY html/* /usr/share/nginx/html/
