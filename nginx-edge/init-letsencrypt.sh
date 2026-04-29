#!/usr/bin/env bash
set -euo pipefail

# Usage: ./init-letsencrypt.sh your@email.com
# Run from nginx-edge/. Traefik must NOT use ports 80/443.

EMAIL="${1:?usage: $0 your@email.com}"
DOMAIN="dovicovic.com"

cd "$(dirname "$0")"

echo "==> Starting nginx (HTTP only, conf.d/00-dovicovic-http.conf)"
docker compose up -d nginx
sleep 2

echo "==> Requesting Let's Encrypt certificate"
docker compose run --rm --entrypoint certbot certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email "$EMAIL" \
  --agree-tos \
  --no-eff-email \
  -d "$DOMAIN" \
  -d "www.$DOMAIN"

echo "==> Enabling HTTPS nginx config"
rm -f nginx/conf.d/00-dovicovic-http.conf
cp nginx/templates/dovicovic-https.conf nginx/conf.d/dovicovic.conf

docker compose exec nginx nginx -t
docker compose exec nginx nginx -s reload

echo "==> Done. Test: curl -sI https://$DOMAIN"
