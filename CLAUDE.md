# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dockerized WordPress development environment using three services: WordPress (PHP 8.2 + Apache), MySQL 5.7, and Nginx (reverse proxy with SSL termination). The stack runs behind Nginx which proxies to the WordPress Apache container.

## Architecture

- **docker-compose_dev.yml** — Defines all three services and a shared `wp-network` bridge network
- **Nginx** reverse-proxies port 80/443 to WordPress Apache on port 80 via the `wp-network-wordpress` alias
- **MySQL** data is persisted to `../data/mysql` (outside the repo) to survive container rebuilds
- **SSL certs** are stored in `../data/nginx/certs/` — see `docs/certificates.md` for self-signed cert generation
- **WordPress source** is bind-mounted at `./wordpress/src` (gitignored except `.gitkeep`)
- Environment variables are loaded from `.env_dev` (copy `.env_dev_sample` to create it)

## Common Commands

```bash
# Start services
docker compose --env-file=.env_dev up -d

# Stop services
docker compose --env-file=.env_dev down

# Restart (stop + start in one line)
./docker-compose-env.sh

# View logs
docker compose --env-file=.env_dev logs -t

# Shell into a container
docker exec -it <container_id> /bin/bash
```

## Setup Checklist

1. Copy `.env_dev_sample` to `.env_dev` and set domain/credentials
2. Copy `.gitignore_sample` to `.gitignore`
3. Create `../data/mysql` directory for MySQL persistence
4. Generate SSL certs in `../data/nginx/certs/` (see `docs/certificates.md`)
5. Add domain to `/etc/hosts` (e.g., `127.0.0.1 my-domain.local www.my-domain.local`)
6. After first run, configure `wordpress/src/wp-config.php` with `WP_HOME`, `WP_SITEURL`, and `FS_METHOD`

## Key Configuration Files

- `.env_dev` — Docker Compose env vars (IP, domains, MySQL credentials, ports)
- `nginx/etc/nginx.conf` — Main Nginx config (read-only mount)
- `nginx/etc/templates/default.conf.template` — Nginx server block template (uses envsubst from env vars)
