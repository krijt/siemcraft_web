# SiemCraft Webserver

Nginx container with automatic Let’s Encrypt for `siemcraft.verkeerd-verbonden.nl`, serving a Minecraft‑themed splash page on HTTPS (port 5443).

## Features
- Nginx reverse with HTTP→HTTPS redirect and ACME HTTP-01 challenge handling.
- Certbot issuance/renewal with self-signed fallback on first boot.
- Swarm-ready `docker-compose.yml` exposing 80 and 5443.
- Simple landing page in `index.html` baked into the image (replace as needed).
- Download drop at `/download` mapped from the host `./downloads` directory, auto-listed with styled fancyindex + custom CSS.

## Requirements
- Docker Engine with Swarm mode enabled.
- DNS A record for `siemcraft.verkeerd-verbonden.nl` pointing to the Swarm node.
- Outbound port 80 reachability for Let’s Encrypt validation.

## Configuration
- `LETSENCRYPT_EMAIL` (required): email for certificate issuance.
- `LETSENCRYPT_STAGING` (optional): set to `1` to test against the staging CA.
- `DOMAIN` defaults to `siemcraft.verkeerd-verbonden.nl`; override only if you change the host.

Volumes (defined in compose):
- `certs`: persists `/etc/letsencrypt` (certs/keys).
- `webroot`: persists ACME challenge files.
- Bind: `./downloads` → `/usr/share/nginx/html/download` (read-only in container).

## Build and deploy
```bash
docker build -t siemcraftweb .
docker stack deploy -c docker-compose.yml siemcraft
```

The stack publishes HTTP on 80 and HTTPS on 5443. Update `LETSENCRYPT_EMAIL` in `docker-compose.yml` before deploying. On first start you’ll see a self-signed cert until Let’s Encrypt issuance succeeds, after which certs are swapped and nginx reloads. Renewals run nightly via cron.

Place any files you want downloadable in `./downloads`; they’ll be reachable at `/download/filename` and listed at `/download/`.
