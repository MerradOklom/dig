FROM alpine:3.19

# Added privoxy to bridge Nginx (HTTP) to Tor (SOCKS5)
RUN apk add --no-cache tor privoxy nginx supervisor curl

COPY torrc /etc/tor/torrc
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf

# Tell privoxy to route all outgoing requests into Tor's SOCKS5 port (9050)
RUN echo 'forward-socks5t / 127.0.0.1:9050 .' >> /etc/privoxy/config && \
    sed -i 's/^listen-address.*/listen-address 127.0.0.1:8118/' /etc/privoxy/config

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
