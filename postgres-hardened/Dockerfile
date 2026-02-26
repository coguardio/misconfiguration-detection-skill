FROM postgres:17.4

# Copy SSL certificates
COPY certs/server.crt /var/lib/postgresql/server.crt
COPY certs/server.key /var/lib/postgresql/server.key
RUN chown postgres:postgres /var/lib/postgresql/server.crt /var/lib/postgresql/server.key \
    && chmod 600 /var/lib/postgresql/server.key

# Copy hardened configuration
COPY postgresql.conf /etc/postgresql/postgresql.conf

# Expose log directory to host
VOLUME /var/log

# Health check for container monitoring
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD pg_isready -U postgres || exit 1

# Run as non-root user
USER postgres

CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
