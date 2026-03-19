# PROJECT.md Template — Go Microservice

Template for `.planning/PROJECT.md` optimized for Go backend microservices with Docker + PostgreSQL.

<template>

```markdown
# [Project Name]

## What This Is

[Microservicio en Go que ... — 2-3 oraciones. ¿Qué hace y para quién?]

## Core Value

[La cosa más importante. Si todo falla, esto debe funcionar.]

## Requirements

### Validated

<!-- Shipped and confirmed valuable. -->

(None yet — ship to validate)

### Active

<!-- Current scope. Building toward these. -->

- [ ] [Requirement 1]
- [ ] [Requirement 2]
- [ ] [Requirement 3]

### Out of Scope

<!-- Explicit boundaries. -->

- [Exclusion 1] — [why]

## Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| **Language** | Go 1.22+ | Standard library preferred over frameworks |
| **HTTP** | net/http / chi / fiber | [choose one] |
| **Database** | PostgreSQL 15+ | pgx driver, no ORM |
| **Migrations** | golang-migrate | SQL files in `migrations/` |
| **Config** | Environment vars | .env for local, Docker env for prod |
| **Container** | Docker + docker-compose | Multi-stage build |
| **Reverse Proxy** | Nginx | SSL termination, rate limiting |
| **Monitoring** | Prometheus + Grafana | Metrics endpoint at `/metrics` |
| **Logging** | slog (stdlib) | JSON structured logging |
| **CI/CD** | GitHub Actions | lint → test → build → deploy |

## Architecture

```text
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Nginx      │────▶│   Go API     │────▶│  PostgreSQL  │
│   :443       │     │   :8080      │     │   :5432      │
└─────────────┘     └──────┬───────┘     └─────────────┘
                           │
                    ┌──────┴───────┐
                    │  External    │
                    │  Services    │
                    │  (Telegram,  │
                    │   SSH, SNMP) │
                    └──────────────┘
```

**Patterns:**
- Repository pattern for data access
- Service layer for business logic
- Handler layer for HTTP concerns
- Middleware chain for cross-cutting (auth, logging, CORS)

## Directory Structure

```
.
├── cmd/
│   └── server/
│       └── main.go           # Entry point
├── internal/
│   ├── config/               # Environment configuration
│   ├── database/             # DB connection, migrations
│   ├── handlers/             # HTTP handlers
│   ├── middleware/            # Auth, logging, CORS
│   ├── models/               # Data models / structs
│   ├── repository/           # Database queries
│   └── services/             # Business logic
├── migrations/               # SQL migration files
├── docker/
│   ├── Dockerfile            # Multi-stage Go build
│   ├── docker-compose.yml    # Dev environment
│   └── nginx/
│       └── nginx.conf        # Reverse proxy config
├── scripts/                  # Helper scripts
├── go.mod
├── go.sum
├── .env.example
└── Makefile
```

## Constraints

- **Deployment**: Docker containers on Linux VPS
- **Database**: PostgreSQL only — no MongoDB, no SQLite
- **Auth**: JWT tokens via `golang-jwt/jwt/v5`
- **No ORM**: Raw SQL with pgx — queremos control total
- **Error handling**: Go idiomatic `if err != nil` + wrapped errors
- **Testing**: `testing` stdlib + `testify` for assertions

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| pgx over database/sql | Connection pooling nativo, COPY support, better types | — Pending |
| slog over zerolog | Stdlib, zero-dependency, good enough for our scale | — Pending |
| chi over gin | Lightweight, stdlib-compatible, better middleware chain | — Pending |

## Context

[Background: infraestructura existente, APIs externas, integraciones necesarias]

---
*Last updated: [date] after [trigger]*
```

</template>

<guidelines>

**When to use this template:**
- Backend API microservices in Go
- CRUD applications with PostgreSQL
- Network management tools (SSH/SNMP integration)
- Telegram bot backends

**Key differences from generic template:**
- Pre-filled tech stack table with Go ecosystem choices
- Architecture diagram with common integration points
- Directory structure following Go project layout conventions
- Constraints reflecting Go idioms (no ORM, error handling patterns)

</guidelines>
