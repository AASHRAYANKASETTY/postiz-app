#!/bin/bash
set -o xtrace

# Wait for frontend/backend ports to be ready (if required)
while ! nc -z localhost 4200; do
  echo "Waiting for port 4200..."
  sleep 1
done

while ! nc -z localhost 3000; do
  echo "Waiting for port 3000..."
  sleep 1
done

# Start supervisord (manages caddy or other services)
exec supervisord -c /etc/supervisord.conf
