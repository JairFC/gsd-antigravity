# PROJECT.md Template — Infrastructure & DevOps

Template for `.planning/PROJECT.md` optimized for infrastructure automation, Docker orchestration, and system administration projects.

<template>

```markdown
# [Project Name]

## What This Is

[Infraestructura/automatización que ... — 2-3 oraciones.]

## Core Value

[La cosa más importante. Si todo falla, esto debe funcionar.]

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] [Requirement 1]
- [ ] [Requirement 2]

### Out of Scope

- [Exclusion 1] — [why]

## Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| **Orchestration** | Docker Compose / Swarm | Container management |
| **OS** | Ubuntu 22.04 LTS | Target deployment |
| **Reverse Proxy** | Nginx | SSL, rate limiting, routing |
| **Database** | PostgreSQL 15+ | Primary data store |
| **Cache** | Redis 7+ | Optional: sessions, queues |
| **Monitoring** | Prometheus + Grafana | Metrics and dashboards |
| **Logging** | Docker logs + journalctl | Centralized via volume mounts |
| **Backup** | pg_dump + cron + git | Daily automated backups |
| **SSL** | Let's Encrypt / Certbot | Auto-renewal |
| **DNS** | Cloudflare | DNS management + CDN |

## Infrastructure Map

```text
┌─────────────────────────────────────────────────┐
│                  VPS / Server                    │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │  Nginx   │  │  App 1   │  │  App 2   │      │
│  │  :443    │──│  :8080   │  │  :8081   │      │
│  └──────────┘  └──────────┘  └──────────┘      │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ Postgres │  │  Redis   │  │ Grafana  │      │
│  │  :5432   │  │  :6379   │  │  :3000   │      │
│  └──────────┘  └──────────┘  └──────────┘      │
│                                                  │
│  Docker Network: app-network (bridge)            │
│  Volumes: pgdata, redis-data, nginx-certs        │
└─────────────────────────────────────────────────┘
```

## Docker Compose Services

| Service | Image | CPU Limit | RAM Limit | Restart |
|---------|-------|-----------|-----------|---------|
| nginx | nginx:alpine | 0.5 | 128M | always |
| app | custom build | 1.0 | 512M | unless-stopped |
| postgres | postgres:15 | 1.0 | 1G | always |
| redis | redis:7-alpine | 0.25 | 128M | always |
| grafana | grafana/grafana | 0.5 | 256M | unless-stopped |

## Operational Procedures

### Backup Strategy
- **PostgreSQL**: `pg_dump` daily at 03:00 UTC, keep 7 days
- **Volumes**: Docker volume snapshots weekly
- **Config**: Git-tracked, encrypted secrets via `.env`

### Deployment
- Build locally or CI → push image → `docker compose pull && docker compose up -d`
- Zero-downtime: health checks + rolling updates

### Monitoring Alerts
- Container restart count > 3 in 5min → Telegram alert
- Disk usage > 80% → Telegram alert
- PostgreSQL connection pool > 90% → Telegram alert

## Constraints

- **Budget**: Single VPS (4 CPU, 8GB RAM, 200GB disk)
- **Uptime**: 99.5% target (allows ~3.5h downtime/month for maintenance)
- **Security**: SSH key-only, fail2ban, UFW firewall
- **No Kubernetes**: Docker Compose is sufficient for our scale
- **Backups**: Must restore from backup in < 30 minutes

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Docker Compose over K8s | Single server, simpler ops, sufficient for scale | — Pending |
| Nginx over Traefik | More control, familiar, better docs | — Pending |
| pg_dump over WAL | Simpler, sufficient for our data volume | — Pending |

## Context

[Background: server specs, network topology, existing services, migration plan]

---
*Last updated: [date] after [trigger]*
```

</template>

<guidelines>

**When to use this template:**
- Docker Compose orchestration projects
- VPS setup and configuration
- CI/CD pipeline setup
- System administration automation

**Key differences from generic template:**
- Infrastructure map showing container relationships
- Docker Compose service matrix with resource limits
- Operational procedures (backup, deploy, monitoring)
- Budget and uptime constraints typical for VPS hosting

</guidelines>
