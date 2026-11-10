FROM alpine:3.19

RUN apk add --no-cache tor privoxy nginx supervisor curl

# Create Tor data directory with strict permissions required by tor
RUN mkdir -p /var/lib/tor && \
    chown -R tor:tor /var/lib/tor && \
    chmod 700 /var/lib/tor

COPY torrc /etc/tor/torrc
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf

# Configure Privoxy:
# 1. Initialize /etc/privoxy/config from config.new (Alpine standard)
# 2. Enable reverse-proxy intercept mode (accept-intercepted-requests 1)
# 3. Set listen address to 127.0.0.1:8118
# 4. Route traffic through Tor SOCKS5 (127.0.0.1:9050)
RUN [ -f /etc/privoxy/config.new ] && cp /etc/privoxy/config.new /etc/privoxy/config || true && \
    touch /etc/privoxy/config && \
    sed -i 's/^listen-address.*/listen-address 127.0.0.1:8118/' /etc/privoxy/config && \
    sed -i 's/^#*accept-intercepted-requests.*/accept-intercepted-requests 1/' /etc/privoxy/config && \
    grep -q 'accept-intercepted-requests 1' /etc/privoxy/config || echo 'accept-intercepted-requests 1' >> /etc/privoxy/config && \
    echo 'forward-socks5t / 127.0.0.1:9050 .' >> /etc/privoxy/config

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
