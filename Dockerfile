FROM alpine:3.19

# Install Tor, Nginx, and supervisor
RUN apk add --no-cache tor nginx supervisor curl

# Copy configurations
COPY torrc /etc/tor/torrc
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
