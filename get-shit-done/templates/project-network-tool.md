# PROJECT.md Template — Network Management Tool

Template for `.planning/PROJECT.md` optimized for network management, monitoring, and automation tools.

<template>

```markdown
# [Project Name]

## What This Is

[Herramienta de gestión de red que ... — 2-3 oraciones. ¿Qué monitorea/automatiza y para qué tipo de red?]

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

### Out of Scope

<!-- Explicit boundaries. -->

- [Exclusion 1] — [why]

## Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| **Language** | Go / Python / Bash | [primary language] |
| **Database** | PostgreSQL 15+ | Device inventory, scan results |
| **Network Protocols** | SSH, SNMP v2c/v3, REST, LLDP, MNDP | Device communication |
| **SSH Library** | golang.org/x/crypto/ssh / paramiko | Remote command execution |
| **SNMP** | gosnmp / pysnmp | OID walking, polling |
| **Scheduling** | cron / systemd timers | Periodic scans |
| **Notifications** | Telegram Bot API | Alerts, reports |
| **PDF Reports** | go-pdf / reportlab | Automated scan reports |
| **Container** | Docker + docker-compose | Deployment |
| **Visualization** | D3.js / vis.js | Network topology maps |

## Network Context

### Supported Vendors

| Vendor | Protocol | Auth | Notes |
|--------|----------|------|-------|
| MikroTik | SSH (RouterOS CLI) | user/pass + key | MNDP neighbor discovery |
| Ubiquiti | SSH + REST API | user/pass | EdgeOS / UniFi |
| Cisco | SSH (IOS CLI) | user/pass + enable | Show commands |
| Generic | SNMP v2c/v3 | community/auth | OID-based discovery |
| Linux | SSH | key-based | Standard commands |

### Discovery Pipeline

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  IP Scanner   │────▶│  Port Probe   │────▶│  Vendor ID    │
│  (CIDR sweep) │     │  (22,161,80)  │     │  (OUI + banner)│
└──────────────┘     └──────────────┘     └───────┬───────┘
                                                   │
                     ┌──────────────┐     ┌────────▼───────┐
                     │  Neighbor     │◀───│  Device Poll    │
                     │  Harvest      │     │  (SSH/SNMP/API) │
                     │  (ARP/LLDP)   │     └──────────────┘
                     └──────┬───────┘
                            │
                     ┌──────▼───────┐
                     │  Topology     │
                     │  Builder      │
                     │  (Link Map)   │
                     └──────────────┘
```

## Architecture

```text
┌─────────────────────────────────────────────┐
│                  Frontend                    │
│  (Topology Map, Device Dashboard, Reports)   │
├─────────────────────────────────────────────┤
│                  API Layer                   │
│  (REST endpoints, WebSocket for live data)   │
├─────────────────────────────────────────────┤
│               Service Layer                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ Scanner  │  │ Poller   │  │ Reporter │  │
│  │ Service  │  │ Service  │  │ Service  │  │
│  └──────────┘  └──────────┘  └──────────┘  │
├─────────────────────────────────────────────┤
│              Protocol Adapters               │
│  ┌─────┐  ┌──────┐  ┌──────┐  ┌────────┐  │
│  │ SSH │  │ SNMP │  │ REST │  │Telegram│  │
│  └─────┘  └──────┘  └──────┘  └────────┘  │
├─────────────────────────────────────────────┤
│              PostgreSQL / Redis              │
└─────────────────────────────────────────────┘
```

## Constraints

- **Network Access**: Must handle unreachable hosts gracefully (timeouts, retries)
- **Concurrency**: Rate-limited parallel connections (AIMD algorithm)
- **Security**: Credentials stored encrypted, SSH keys preferred
- **Idempotency**: Scans can be re-run safely without side effects
- **Scale**: Support 1000+ IP addresses per scan cycle
- **Timeout**: Per-device timeout ≤ 30s, full scan ≤ 5 minutes

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| SSH over SNMP for MikroTik | RouterOS CLI gives richer data than SNMP | — Pending |
| OUI lookup for vendor ID | MAC prefix is most reliable vendor signal | — Pending |
| CIDR expansion for subnets | Supports /22, /16 without manual listing | — Pending |

## Context

[Background: network topology, number of devices, existing tools, pain points]

---
*Last updated: [date] after [trigger]*
```

</template>

<guidelines>

**When to use this template:**
- Network monitoring/management tools (like OpenClaw)
- Device discovery and inventory systems
- Topology mapping applications
- Automated audit and compliance tools

**Key differences from generic template:**
- Vendor compatibility matrix for multi-vendor networks
- Discovery pipeline diagram showing scan flow
- Protocol adapter architecture for SSH/SNMP/REST
- Network-specific constraints (timeouts, rate limiting, concurrency)

</guidelines>
