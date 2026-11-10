FROM alpine:3.19

RUN apk add --no-cache tor privoxy nginx supervisor curl

# Create Tor data directory with strict permissions required by tor
RUN mkdir -p /var/lib/tor && \
    chown -R tor:tor /var/lib/tor && \
    chmod 700 /var/lib/tor

COPY torrc /etc/tor/torrc
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf

# Clean minimal Privoxy config:
# Bypasses missing filter files and forwards cleanly to Tor
RUN printf "listen-address 127.0.0.1:8118\naccept-intercepted-requests 1\nforward-socks5t / 127.0.0.1:9050 .\n" > /etc/privoxy/config

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
