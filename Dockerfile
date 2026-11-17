# NOFX on Railway: one container with the official backend binary and the
# official web UI, behind nginx on $PORT. Both images are pinned by tag and digest.
# Update: bump both pins to the same upstream commit and add a CHANGELOG.md entry.
FROM ghcr.io/nofxaios/nofx/nofx-backend:sha-65e9037-amd64@sha256:0f4759d6dc2e7b35c1c2419a83ef4ee255cc32eae336ae61304acfc17a0e02f9 AS backend

FROM ghcr.io/nofxaios/nofx/nofx-frontend:sha-65e9037-amd64@sha256:7356685d8fc1c2ffb07c4a4f2c33c67fcabfb8226bc217274cc7e0ff88d910e4

# openssl: generates the RSA transport key once and the setup password hash.
RUN apk add --no-cache openssl \
 && rm -f /etc/nginx/conf.d/default.conf

COPY --from=backend /usr/local/lib/libta_lib* /usr/local/lib/
COPY --from=backend /app/nofx /app/nofx
COPY nginx.conf.template proxy.conf /etc/nofx/
COPY start.sh /usr/local/bin/nofx-start
RUN chmod +x /usr/local/bin/nofx-start /app/nofx && mkdir -p /app/data

WORKDIR /app
ENV PORT=8080
EXPOSE 8080
VOLUME ["/app/data"]

ENTRYPOINT ["/usr/local/bin/nofx-start"]
