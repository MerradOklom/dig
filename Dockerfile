FROM alpine:3.19

RUN apk add --no-cache tor privoxy nginx supervisor curl

# Set correct permissions for the Tor data directory
RUN mkdir -p /var/lib/tor && \
    chown -R tor:tor /var/lib/tor && \
    chmod 700 /var/lib/tor

COPY torrc /etc/tor/torrc
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf

RUN sed -i 's/^listen-address.*/listen-address 127.0.0.1:8118/' /etc/privoxy/config && \
    sed -i 's/^#*accept-intercepted-requests.*/accept-intercepted-requests 1/' /etc/privoxy/config && \
    echo 'forward-socks5t / 127.0.0.1:9050 .' >> /etc/privoxy/config
    
EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
