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
