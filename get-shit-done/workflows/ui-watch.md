---
name: gsd-ui-watch
description: Launch Antigravity Browser Agent to visually audit the UI against specifications
---

<objective>
Visually audit the UI by booting the application and instructing the browser subagent to interact with the local port.
Produces a UI-WATCH-REPORT.md with visual feedback, bugs, and screenshot references.
</objective>

<execution_context>
@~/.gemini/antigravity/get-shit-done/workflows/ui-watch.md
@~/.gemini/antigravity/get-shit-done/references/ui-brand.md
</execution_context>

<context>
Phase: $ARGUMENTS — optional, defaults to the last completed frontend phase.
</context>

<when_to_use>
- After completing a frontend feature phase.
- To verify a UI-SPEC.md requirement with physical browser clicks.
- Whenever visual layout regressions are suspected.
</when_to_use>

<process>

## 1. Setup Environment
Ensure the local dev server is running.
If it is not running, spawn it in background via `npm run dev` or equivalent.
Determine the local URL (e.g. `http://localhost:3000`).

## 2. Load UI Spec
Read the corresponding `UI-SPEC.md` for the current phase to understand the visual expectations (colors, spacing, layout, components).

## 3. Spawn Browser Subagent
Use the `browser_subagent` tool natively available in Antigravity.
Pass the specific URL to the tool and the task description.

**Task to Browser Subagent:**
```
Navigate to {local_url}.
Review the components against the following requirements:
{insert_ui_spec_summary}
Click on interactive elements. Check for layout shifts.
Take a screenshot of the final state.
Return a detailed report of visual discrepancies found.
```

## 4. Compile Report
Collect the results from the Browser Subagent.
Generate `.planning/UI-WATCH-REPORT.md`.
Log any failures.

## 5. Next Steps
If the browser reported visual issues, offer the user a choice to:
1. Fix them immediately using `/gsd-debug` or `/gsd-fast`.
2. Save the report and plan them into the next phase.

</process>

<success_criteria>
- [ ] Dev server running and accessible.
- [ ] browser_subagent successfully connected and inspected the UI.
- [ ] UI-SPEC.md requirements mapped correctly to the view.
- [ ] Visual discrepancies identified and logged in UI-WATCH-REPORT.md.
</success_criteria>
