# Antigravity Tool Mapping

When executing GSD workflows on Antigravity, use these tool equivalences:

## Tool Translation Table

| GSD/Claude Tool | Antigravity Equivalent | Notes |
|----------------|----------------------|-------|
| `Read` | `view_file` | Use `AbsolutePath`. For binary files, omit StartLine/EndLine |
| `Write` | `write_to_file` | Must set `TargetFile` first. Use `Overwrite: true` for existing |
| `Edit` | `replace_file_content` / `multi_replace_file_content` | Single block → `replace_file_content`. Multiple blocks → `multi_replace_file_content` |
| `Bash` / `bash` | `run_command` | Set `Cwd` explicitly. Use `WaitMsBeforeAsync` for timing. Long commands → check `command_status` |
| `Grep` | `grep_search` | Set `SearchPath`, `Query`. Use `Includes` for file patterns |
| `Glob` | `find_by_name` | Use `Pattern` (glob format). Set `SearchDirectory` |
| `Task` | ❌ Not available | Use inline execution — follow workflow instructions directly |
| `AskUserQuestion` | Direct markdown output | Present options as numbered list, user replies in chat |
| `Skill` | `view_file` on SKILL.md, then follow | Read the skill file and execute its instructions inline |

## Key Differences

### File Operations
- **Always use absolute paths** in Antigravity
- `write_to_file` requires `TargetFile` as the FIRST argument
- For editing: prefer `replace_file_content` (single edit) or `multi_replace_file_content` (multiple non-adjacent edits)
- Never use `write_to_file` with `Overwrite: true` when you only need to change a few lines

### Command Execution
- `run_command` requires explicit `Cwd` (current working directory)
- For background/long commands: use small `WaitMsBeforeAsync` + `command_status` polling
- Interactive commands: use `send_command_input` to provide stdin

### Search
- `grep_search`: exact text or regex search within files
- `find_by_name`: find files/directories by name pattern
- Both are fast and reliable — no MCP dependency

### Context Loading
- Claude's `@file:path` syntax doesn't exist — use `view_file` explicitly
- Read project context files at the start of each workflow step
- `.planning/PROJECT.md`, `.planning/STATE.md`, `./CLAUDE.md` (or `./GEMINI.md`) for project context

### Git Operations
- Use `run_command` with `git` commands
- `gsd-tools.cjs commit` works normally — it calls git internally
- Always specify `Cwd` pointing to the project root

## Project Instructions File

GSD workflows reference `./CLAUDE.md` for project-specific instructions.
On Antigravity, also check for `./GEMINI.md` as an alternative.
The content is the same — project guidelines, coding conventions, etc.

## Parallel Tool Calls (Speed Optimization)

Antigravity supports **parallel tool execution** — multiple tools called in the same turn run simultaneously if they have no data dependencies.

### Rules
1. **Independent calls → parallel.** If call B doesn't need the output of call A, call both in the same turn.
2. **Dependent calls → sequential.** If call B needs data from call A's result, wait for A first.
3. **No limit on parallel calls.** You can call 5+ tools in one turn.

### Pattern: Parallel Context Loading
Instead of reading files one at a time:
```
# SLOW — 5 sequential round trips
view_file(PROJECT.md)    → wait → view_file(STATE.md) → wait → view_file(ROADMAP.md) → ...
```
Load all context simultaneously:
```
# FAST — 1 round trip for all 5
view_file(PROJECT.md)     ← parallel
view_file(STATE.md)       ← parallel
view_file(ROADMAP.md)     ← parallel
view_file(config.json)    ← parallel
view_file(GEMINI.md)      ← parallel
```

### Pattern: Parallel Research
Web searches for independent topics:
```
search_web("Go microservice patterns")     ← parallel
search_web("PostgreSQL connection pooling") ← parallel
search_web("Docker multi-stage builds")    ← parallel
```

### Pattern: Parallel File Writes
Writing independent output files:
```
write_to_file(.planning/research/STACK.md)        ← parallel
write_to_file(.planning/research/FEATURES.md)     ← parallel
write_to_file(.planning/research/ARCHITECTURE.md) ← parallel
```

### When NOT to Parallelize
- **Task execution within a plan** — tasks may depend on files created by prior tasks
- **Git commits** — must be sequential (each commit depends on prior state)
- **File reads → file edits** — need to read content before editing it
