<purpose>
Visual E2E audit for frontend phases using the Antigravity browser_subagent natively.
Navigates to the running local dev server, captures screenshots, and compares the live UI against UI-SPEC.md.
Produces a scored UI-WATCH-REPORT.md with screenshot evidence.

ANTIGRAVITY ONLY: This workflow uses browser_subagent which is a native Antigravity tool not available in Claude Code.
</purpose>

<required_reading>
@~/.gemini/antigravity/get-shit-done/references/antigravity-tools.md
@~/.gemini/antigravity/get-shit-done/references/ui-brand.md
</required_reading>

<process>

## 0. Initialize

```bash
INIT=$(node "$HOME/.gemini/antigravity/get-shit-done/bin/gsd-tools.cjs" init ui-watch "${PHASE_ARG}")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Parse from JSON: `phase_dir`, `phase_number`, `phase_name`, `padded_phase`, `commit_docs`, `has_ui_spec`,
`ui_spec_path`, `has_watch_report`, `watch_report_path`, `dev_port`, `dev_command`, `project_root`.

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► UI WATCH — PHASE {N}: {name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**If `has_watch_report` is true:** Present:
- "Re-audit — overwrite previous report"
- "View — display existing report and exit"

## 1. Load UI Spec

```bash
# Parallel reads:
# view_file(ui_spec_path)            ← parallel (if exists)
# view_file(.planning/STATE.md)      ← parallel
```

**If `has_ui_spec` is false:**
> ⚠️ No UI-SPEC.md found for Phase {N}. Running audit against ui-brand.md visual standards only.
Continue (non-blocking).

Extract from UI-SPEC.md:
- Target URL routes (e.g., `/`, `/dashboard`, `/login`)
- Key components to verify (buttons, forms, nav, tables)
- Color/typography/spacing requirements
- Responsive breakpoints to check

If no routes specified, default to `http://localhost:{dev_port}/`.

## 2. Ensure Dev Server Running

```bash
# Check if something is listening on the expected port
curl -s --max-time 3 http://localhost:{dev_port}/ > /dev/null 2>&1
echo $?  # 0 = reachable, non-zero = not running
```

**If not running:**
```
◆ Starting dev server: {dev_command}
```

```bash
# Start in background — use run_command with short WaitMsBeforeAsync (3000ms)
{dev_command}  # e.g. npm run dev, python manage.py runserver, etc.
```

Wait 5 seconds, then retry the curl check. If still failing after 2 retries:
> ❌ Failed to reach dev server at localhost:{dev_port}. Please start it manually and retry.
Exit.

**If running:**
```
✓ Dev server reachable at http://localhost:{dev_port}/
```

## 3. Launch Browser Subagent (Multi-Route Audit)

For each route identified from UI-SPEC.md (or default to `/`):

**DO NOT parallelize browser sessions** — screenshots may conflict and the browser state must be sequential.

Spawn `browser_subagent` with this task template:

```
You are performing a visual UI audit for GSD Phase {phase_number}: {phase_name}.

Navigate to: http://localhost:{dev_port}{route}

Perform these checks in order:
1. Screenshot the full page immediately on load.
2. Check for obvious layout breaks (overflow, clipping, overlapping elements).
3. Verify the primary call-to-action button: exists, visible, correct color per spec.
4. Check typography: font sizes readable, no fallback fonts (Arial/Times visible = fail).
5. Check color palette: no raw browser defaults (blue links, grey borders).
6. Test one interactive element: click a button or fill a form field if present.
7. Check spacing: no cramped or zero-margin containers.
8. Screenshot the final state.

Report format (REQUIRED):
## Route: {route}
- Visual score: X/10
- Layout: PASS/FAIL — {details}
- CTA button: PASS/FAIL — {details}
- Typography: PASS/FAIL — {details}
- Colors: PASS/FAIL — {details}
- Interaction: PASS/FAIL — {details}
- Spacing: PASS/FAIL — {details}
- Screenshot saved: {path}
- Issues found: [list or "none"]
```

Collect all reports from each `browser_subagent` call sequentially.

## 4. Write UI-WATCH-REPORT.md

Build the consolidated report from the collected route audits:

```markdown
---
phase: {phase_number}
name: {phase_name}
audited_at: {ISO timestamp}
routes_checked: {N}
overall_score: {avg}/10
---

# UI Watch Report — Phase {N}: {name}

**Audited:** {timestamp}
**Routes:** {list}
**Overall Score:** {avg}/10

---

## Summary

| Route | Score | Layout | CTA | Typography | Colors | Interaction | Spacing |
|-------|-------|--------|-----|------------|--------|-------------|---------|
{rows for each route}

---

## Route Audit Details

{per-route sections with details and screenshot paths}

---

## Critical Issues
{list of FAIL items, or "None found ✓"}

## Recommendations
{top 3 actionable fixes sorted by impact}

---

## Screenshots
{embedded screenshot paths}
```

Write to: `{phase_dir}/{padded_phase}-UI-WATCH-REPORT.md`

## 5. Display Results

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► UI WATCH COMPLETE ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Phase {N}: {Name}** — Overall: {score}/10  ({routes_checked} routes)

| Route | Score |
|-------|-------|
{summary rows}

{If critical issues:}
⚠️ Critical Issues: {count}
{list top 3}

Full report: {path to UI-WATCH-REPORT.md}

───────────────────────────────────────────────────────

## ▶ Next

- `/gsd-ui-review {N}` — full 6-pillar scored audit
- `/gsd-debug` — fix critical issues found
- `/gsd-plan-phase {N+1}` — plan next phase

───────────────────────────────────────────────────────
```

## 6. Commit (if configured)

```bash
node "$HOME/.gemini/antigravity/get-shit-done/bin/gsd-tools.cjs" commit \
  "docs(${padded_phase}): UI visual watch report" \
  --files "${phase_dir}/${padded_phase}-UI-WATCH-REPORT.md"
```

## 7. Update State

```bash
node "$HOME/.gemini/antigravity/get-shit-done/bin/gsd-tools.cjs" state record-session \
  --stopped-at "Phase ${phase_number} UI Watch: score ${score}/10" \
  --resume-file "${phase_dir}/${padded_phase}-UI-WATCH-REPORT.md"
```

</process>

<success_criteria>
- [ ] Phase validated and UI-SPEC.md loaded (or warned if absent)
- [ ] Dev server confirmed running or started
- [ ] browser_subagent executed for each target route
- [ ] Screenshots captured and saved
- [ ] UI-WATCH-REPORT.md written with per-route scores
- [ ] Critical issues surfaced to user
- [ ] Report committed if commit_docs enabled
- [ ] Next steps presented
</success_criteria>
