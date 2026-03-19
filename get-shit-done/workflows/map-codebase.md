<purpose>
Orchestrate parallel codebase mapper agents to analyze codebase and produce structured documents in .planning/codebase/

Each agent has fresh context, explores a specific focus area, and **writes documents directly**. The orchestrator only receives confirmation + line counts, then writes a summary.

Output: .planning/codebase/ folder with 7 structured documents about the codebase state.
</purpose>

<philosophy>
**Why dedicated mapper agents:**
- Fresh context per domain (no token contamination)
- Agents write documents directly (no context transfer back to orchestrator)
- Orchestrator only summarizes what was created (minimal context usage)
- Faster execution (agents run simultaneously)

**Document quality over length:**
Include enough detail to be useful as reference. Prioritize practical examples (especially code patterns) over arbitrary brevity.

**Always include file paths:**
Documents are reference material for Claude when planning/executing. Always include actual file paths formatted with backticks: `src/services/user.ts`.
</philosophy>

<process>

<step name="init_context" priority="first">
Load codebase mapping context:

```bash
INIT=$(node "$HOME/.claude/get-shit-done/bin/gsd-tools.cjs" init map-codebase)
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Extract from init JSON: `mapper_model`, `commit_docs`, `codebase_dir`, `existing_maps`, `has_maps`, `codebase_dir_exists`.
</step>

<step name="check_existing">
Check if .planning/codebase/ already exists using `has_maps` from init context.

If `codebase_dir_exists` is true:
```bash
ls -la .planning/codebase/
```

**If exists:**

```
.planning/codebase/ already exists with these documents:
[List files found]

What's next?
1. Refresh - Delete existing and remap codebase
2. Update - Keep existing, only update specific documents
3. Skip - Use existing codebase map as-is
```

Wait for user response.

If "Refresh": Delete .planning/codebase/, continue to create_structure
If "Update": Ask which documents to update, continue to spawn_agents (filtered)
If "Skip": Exit workflow

**If doesn't exist:**
Continue to create_structure.
</step>

<step name="create_structure">
Create .planning/codebase/ directory:

```bash
mkdir -p .planning/codebase
```

**Expected output files:**
- STACK.md (from tech mapper)
- INTEGRATIONS.md (from tech mapper)
- ARCHITECTURE.md (from arch mapper)
- STRUCTURE.md (from arch mapper)
- CONVENTIONS.md (from quality mapper)
- TESTING.md (from quality mapper)
- CONCERNS.md (from concerns mapper)

Continue to spawn_agents.
</step>

<step name="detect_runtime_capabilities">
Before spawning agents, detect whether the current runtime supports the `Task` tool for subagent delegation.

**Runtimes with Task tool:** Claude Code, Cursor (native subagent support)
**Runtimes WITHOUT Task tool:** Antigravity, Gemini CLI, OpenCode, Codex, and others

**How to detect:** Check if you have access to a `Task` tool. If you do NOT have a `Task` tool (or only have tools like `browser_subagent` which is for web browsing, NOT code analysis):

→ **Skip `spawn_agents` and `collect_confirmations`** — go directly to `sequential_mapping` instead.

**CRITICAL:** Never use `browser_subagent` or `Explore` as a substitute for `Task`. The `browser_subagent` tool is exclusively for web page interaction and will fail for codebase analysis. If `Task` is unavailable, perform the mapping sequentially in-context.
</step>

<step name="spawn_agents" condition="Task tool is available">
Spawn 4 parallel gsd-codebase-mapper agents.

Use Task tool with `subagent_type="gsd-codebase-mapper"`, `model="{mapper_model}"`, and `run_in_background=true` for parallel execution.

**CRITICAL:** Use the dedicated `gsd-codebase-mapper` agent, NOT `Explore` or `browser_subagent`. The mapper agent writes documents directly.

**Agent 1: Tech Focus**

```
Task(
  subagent_type="gsd-codebase-mapper",
  model="{mapper_model}",
  run_in_background=true,
  description="Map codebase tech stack",
  prompt="Focus: tech

Analyze this codebase for technology stack and external integrations.

Write these documents to .planning/codebase/:
- STACK.md - Languages, runtime, frameworks, dependencies, configuration
- INTEGRATIONS.md - External APIs, databases, auth providers, webhooks

Explore thoroughly. Write documents directly using templates. Return confirmation only."
)
```

**Agent 2: Architecture Focus**

```
Task(
  subagent_type="gsd-codebase-mapper",
  model="{mapper_model}",
  run_in_background=true,
  description="Map codebase architecture",
  prompt="Focus: arch

Analyze this codebase architecture and directory structure.

Write these documents to .planning/codebase/:
- ARCHITECTURE.md - Pattern, layers, data flow, abstractions, entry points
- STRUCTURE.md - Directory layout, key locations, naming conventions

Explore thoroughly. Write documents directly using templates. Return confirmation only."
)
```

**Agent 3: Quality Focus**

```
Task(
  subagent_type="gsd-codebase-mapper",
  model="{mapper_model}",
  run_in_background=true,
  description="Map codebase conventions",
  prompt="Focus: quality

Analyze this codebase for coding conventions and testing patterns.

Write these documents to .planning/codebase/:
- CONVENTIONS.md - Code style, naming, patterns, error handling
- TESTING.md - Framework, structure, mocking, coverage

Explore thoroughly. Write documents directly using templates. Return confirmation only."
)
```

**Agent 4: Concerns Focus**

```
Task(
  subagent_type="gsd-codebase-mapper",
  model="{mapper_model}",
  run_in_background=true,
  description="Map codebase concerns",
  prompt="Focus: concerns

Analyze this codebase for technical debt, known issues, and areas of concern.

Write this document to .planning/codebase/:
- CONCERNS.md - Tech debt, bugs, security, performance, fragile areas

Explore thoroughly. Write document directly using template. Return confirmation only."
)
```

Continue to collect_confirmations.
</step>

<step name="collect_confirmations">
Wait for all 4 agents to complete.

Read each agent's output file to collect confirmations.

**Expected confirmation format from each agent:**
```
## Mapping Complete

**Focus:** {focus}
**Documents written:**
- `.planning/codebase/{DOC1}.md` ({N} lines)
- `.planning/codebase/{DOC2}.md` ({N} lines)

Ready for orchestrator summary.
```

**What you receive:** Just file paths and line counts. NOT document contents.

If any agent failed, note the failure and continue with successful documents.

Continue to verify_output.
</step>

<step name="sequential_mapping" condition="Task tool is NOT available (e.g. Antigravity, Gemini CLI, Codex)">
When the `Task` tool is unavailable, perform codebase mapping sequentially in the current context. This replaces `spawn_agents` and `collect_confirmations`.

**IMPORTANT:** Do NOT use `browser_subagent`, `Explore`, or any browser-based tool. Use only file system tools available in your runtime.

**Antigravity-specific tools (preferred order):**
- `list_dir` — Directory structure exploration (fast, recursive counts)
- `find_by_name` — Find files by pattern/extension (supports glob, max 50 results)
- `grep_search` — Search file contents with ripgrep (fast, JSON output)
- `view_file` — Read file contents with line numbers (up to 800 lines)
- `run_command` — Execute shell commands for complex analysis (wc, head, jq, etc.)

**Anti-pattern:** Do NOT read every file. Use `find_by_name` + `grep_search` to locate key files, then `view_file` only the important ones.

**Analysis Paralysis Guard:** If you've made 5+ consecutive read/search calls without writing anything — STOP. Write what you have so far, then continue exploring for remaining docs.

Perform all 4 mapping passes sequentially:

**Pass 1: Tech Focus** → STACK.md + INTEGRATIONS.md

Exploration strategy:
```
# 1. Identify language/framework
find_by_name: go.mod, package.json, Cargo.toml, requirements.txt, pyproject.toml
find_by_name: Dockerfile, docker-compose.yml, docker-compose*.yml
find_by_name: Makefile, Taskfile.yml, justfile

# 2. Read dependency files
view_file: go.mod (Go deps), package.json (Node deps), requirements.txt (Python deps)

# 3. Find config files
find_by_name: *.env*, *.toml, *.yaml, *.yml (MaxDepth: 2)
find_by_name: nginx.conf, prometheus.yml, grafana*.json

# 4. Find integrations
grep_search: "database", "postgres", "mysql", "redis", "mongo" in config files
grep_search: "api.telegram", "webhook", "oauth", "smtp" across codebase
grep_search: "ssh.Dial", "gosnmp", "snmp", "net.Dial" for network integrations
```

Write `.planning/codebase/STACK.md` and `.planning/codebase/INTEGRATIONS.md`

**Pass 2: Architecture Focus** → ARCHITECTURE.md + STRUCTURE.md

Exploration strategy:
```
# 1. Map top-level structure
list_dir: project root
list_dir: cmd/, src/, internal/, pkg/, app/, lib/ (whichever exist)

# 2. Find entry points
find_by_name: main.go, main.py, index.ts, index.js, server.go
grep_search: "func main()" or "if __name__" or "createServer"

# 3. Find routing/handlers
grep_search: "HandleFunc", "router.", "app.Get", "app.Post", "@app.route"
grep_search: "http.Handler", "gin.Context", "fiber.Ctx", "chi.Router"

# 4. Find data flow
grep_search: "repository", "service", "handler", "middleware", "controller"
find_by_name: *repository*, *service*, *handler*, *middleware*
```

Write `.planning/codebase/ARCHITECTURE.md` and `.planning/codebase/STRUCTURE.md`

**Pass 3: Quality Focus** → CONVENTIONS.md + TESTING.md

Exploration strategy:
```
# 1. Check code style
find_by_name: .golangci.yml, .eslintrc*, .prettierrc*, .editorconfig
view_file: first 100 lines of 2-3 representative source files

# 2. Find test infrastructure
find_by_name: *_test.go, *.test.ts, *.spec.ts, test_*.py (count them)
find_by_name: testdata/, fixtures/, __mocks__/
grep_search: "func Test", "describe(", "it(", "def test_"

# 3. Check CI/CD
find_by_name: .github/workflows/*.yml, .gitlab-ci.yml, Jenkinsfile
view_file: CI config files

# 4. Error handling patterns
grep_search: "if err != nil", "try {", "catch", "except", ".catch("
grep_search: "log.Fatal", "log.Error", "slog.", "zerolog", "zap."
```

Write `.planning/codebase/CONVENTIONS.md` and `.planning/codebase/TESTING.md`

**Pass 4: Concerns Focus** → CONCERNS.md

Exploration strategy:
```
# 1. Find TODOs and known issues
grep_search: "TODO", "FIXME", "HACK", "XXX", "WORKAROUND"

# 2. Security scan
grep_search: "password", "secret", "token", "api_key" (check if hardcoded)
grep_search: "InsecureSkipVerify", "nosec", "nolint", "# noqa"
find_by_name: .env (should be gitignored, check .gitignore)

# 3. Performance concerns
grep_search: "time.Sleep", "sync.Mutex", "goroutine", "go func"
grep_search: "SELECT *", "N+1", "unbounded", "no limit"

# 4. Tech debt indicators
run_command: git log --oneline -20 (recent activity pattern)
run_command: wc -l across key files (identify oversized files)
find_by_name: *deprecated*, *legacy*, *old*, *backup*
```

Write `.planning/codebase/CONCERNS.md`

**Document quality rules:**
- Always include actual file paths with backticks: `src/handlers/auth.go`
- Include code snippets for patterns (3-5 lines max)
- Prioritize actionable information over exhaustive listing
- Each document should be 40-120 lines (enough to be useful, not overwhelming)

Continue to verify_output.
</step>

<step name="verify_output">
Verify all documents created successfully:

```bash
ls -la .planning/codebase/
wc -l .planning/codebase/*.md
```

**Verification checklist:**
- All 7 documents exist
- No empty documents (each should have >20 lines)

If any documents missing or empty, note which agents may have failed.

Continue to scan_for_secrets.
</step>

<step name="scan_for_secrets">
**CRITICAL SECURITY CHECK:** Scan output files for accidentally leaked secrets before committing.

Run secret pattern detection:

```bash
# Check for common API key patterns in generated docs
grep -E '(sk-[a-zA-Z0-9]{20,}|sk_live_[a-zA-Z0-9]+|sk_test_[a-zA-Z0-9]+|ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36}|glpat-[a-zA-Z0-9_-]+|AKIA[A-Z0-9]{16}|xox[baprs]-[a-zA-Z0-9-]+|-----BEGIN.*PRIVATE KEY|eyJ[a-zA-Z0-9_-]+\.eyJ[a-zA-Z0-9_-]+\.)' .planning/codebase/*.md 2>/dev/null && SECRETS_FOUND=true || SECRETS_FOUND=false
```

**If SECRETS_FOUND=true:**

```
⚠️  SECURITY ALERT: Potential secrets detected in codebase documents!

Found patterns that look like API keys or tokens in:
[show grep output]

This would expose credentials if committed.

**Action required:**
1. Review the flagged content above
2. If these are real secrets, they must be removed before committing
3. Consider adding sensitive files to Claude Code "Deny" permissions

Pausing before commit. Reply "safe to proceed" if the flagged content is not actually sensitive, or edit the files first.
```

Wait for user confirmation before continuing to commit_codebase_map.

**If SECRETS_FOUND=false:**

Continue to commit_codebase_map.
</step>

<step name="commit_codebase_map">
Commit the codebase map:

```bash
node "$HOME/.claude/get-shit-done/bin/gsd-tools.cjs" commit "docs: map existing codebase" --files .planning/codebase/*.md
```

Continue to offer_next.
</step>

<step name="offer_next">
Present completion summary and next steps.

**Get line counts:**
```bash
wc -l .planning/codebase/*.md
```

**Output format:**

```
Codebase mapping complete.

Created .planning/codebase/:
- STACK.md ([N] lines) - Technologies and dependencies
- ARCHITECTURE.md ([N] lines) - System design and patterns
- STRUCTURE.md ([N] lines) - Directory layout and organization
- CONVENTIONS.md ([N] lines) - Code style and patterns
- TESTING.md ([N] lines) - Test structure and practices
- INTEGRATIONS.md ([N] lines) - External services and APIs
- CONCERNS.md ([N] lines) - Technical debt and issues


---

## ▶ Next Up

**Initialize project** — use codebase context for planning

`/gsd:new-project`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- Re-run mapping: `/gsd:map-codebase`
- Review specific file: `cat .planning/codebase/STACK.md`
- Edit any document before proceeding

---
```

End workflow.
</step>

</process>

<success_criteria>
- .planning/codebase/ directory created
- If Task tool available: 4 parallel gsd-codebase-mapper agents spawned with run_in_background=true
- If Task tool NOT available: 4 sequential mapping passes performed inline (never using browser_subagent)
- All 7 codebase documents exist
- No empty documents (each should have >20 lines)
- Clear completion summary with line counts
- User offered clear next steps in GSD style
</success_criteria>
