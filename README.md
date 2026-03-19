<div align="center">

# GSD Antigravity

**Fork optimizado de [Get Shit Done](https://github.com/gsd-build/get-shit-done) para [Antigravity](https://deepmind.google/) runtime.**

Meta-prompting, context engineering y spec-driven development — adaptado para las herramientas nativas de Antigravity.

[![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](LICENSE)
[![Based on GSD](https://img.shields.io/badge/based%20on-GSD%20v1.26.0-36BCF7?style=for-the-badge)](https://github.com/gsd-build/get-shit-done)

</div>

---

## ¿Qué es esto?

Este es un **fork** del excelente proyecto [Get Shit Done (GSD)](https://github.com/gsd-build/get-shit-done) por **TÂCHES**, modificado y optimizado específicamente para el runtime **Antigravity** de Google DeepMind.

### ¿Por qué un fork?

GSD fue diseñado originalmente para Claude Code, y luego extendido a otros runtimes. Funciona en Antigravity, pero con limitaciones:

- **No tenemos `Task()`** — El mecanismo de subagentes de Claude. En Antigravity todo corre inline.
- **Tools diferentes** — Antigravity usa `view_file`, `grep_search`, `find_by_name`, `write_to_file`, `run_command` en vez de `Read`, `Write`, `Grep`, `Glob`, `Bash`.
- **Sin parallelización de agentes** — Los workflows de wave execution corren secuencialmente.

Este fork adapta los workflows, agrega plantillas de proyecto, y optimiza las instrucciones para las herramientas nativas de Antigravity.

---

## Cambios respecto al upstream

### 🆕 Plantillas de proyecto para stacks comunes

| Template | Stack | Uso |
|----------|-------|-----|
| `project-go-microservice.md` | Go + Docker + PostgreSQL + Nginx | Backend APIs, microservicios |
| `project-network-tool.md` | SSH + SNMP + REST + PostgreSQL | Gestión de red, monitoreo, topology |
| `project-infrastructure.md` | Docker Compose + Nginx + Backup | DevOps, configuración de VPS |

### 🔧 `map-codebase` optimizado para Antigravity

- Estrategias de exploración usando `view_file`, `grep_search`, `find_by_name`, `list_dir` 
- Patrones de búsqueda para Go, Docker, y networking
- Analysis Paralysis Guard (máx 5 lecturas antes de escribir)
- Reglas de calidad de documentos (40-120 líneas por doc)

### ⚡ `quick.md` con ejecución inline

- Detección automática de runtime (Task vs inline)
- **Step 5-ALT** completo: gather → analyze → plan → execute → verify — todo inline
- Plan template con formato XML listo para usar
- Deviation rules y self-check protocol incluidos
- Elimina el overhead de 3 rondas de subagentes

---

## Instalación

### Desde este fork (desarrollo)

```bash
git clone https://github.com/JairFC/gsd-antigravity.git
cd gsd-antigravity
node bin/install.js --antigravity --global
```

### Actualizar

```bash
cd gsd-antigravity
git pull origin main
node bin/install.js --antigravity --global
```

### Sincronizar con upstream

```bash
git fetch upstream
git merge upstream/main
# Resolver conflictos si los hay
node bin/install.js --antigravity --global
```

---

## Uso

Todos los comandos GSD estándar funcionan:

```
/gsd-new-project          # Iniciar proyecto nuevo
/gsd-map-codebase         # Mapear codebase existente
/gsd-discuss-phase 1      # Discutir fase
/gsd-plan-phase 1         # Planificar fase
/gsd-execute-phase 1      # Ejecutar fase
/gsd-quick                # Tarea rápida ad-hoc
/gsd-progress             # Ver estado actual
/gsd-help                 # Ver todos los comandos
```

> **Nota:** En Antigravity los comandos usan formato `/gsd-command` (con guión) en vez de `/gsd:command` (con dos puntos).

---

## Documentación original

Para la documentación completa del sistema GSD, consulta el [README original](https://github.com/gsd-build/get-shit-done) y la [Guía de Usuario](docs/USER-GUIDE.md).

### Conceptos clave de GSD

- **Context Engineering** — Archivos estructurados que dan al AI todo el contexto necesario
- **Wave Execution** — Plans paralelos agrupados por dependencias
- **Atomic Commits** — Un commit por tarea, historial limpio
- **Deviation Rules** — Qué hacer cuando algo se desvía del plan
- **Analysis Paralysis Guard** — Forzar progreso cuando hay demasiada investigación

---

## Créditos

Este proyecto es un **fork** de [Get Shit Done](https://github.com/gsd-build/get-shit-done), creado por **[TÂCHES](https://github.com/glittercowboy)** (Lex Christopherson).

El sistema original de meta-prompting, context engineering, y spec-driven development fue diseñado e implementado por TÂCHES. Este fork solo adapta y optimiza componentes específicos para el runtime Antigravity.

**Licencia:** MIT — Ver [LICENSE](LICENSE) para detalles.

---

<div align="center">

**Antigravity es poderoso. GSD lo hace confiable.**

*Fork mantenido por [JairFC](https://github.com/JairFC)*

</div>
