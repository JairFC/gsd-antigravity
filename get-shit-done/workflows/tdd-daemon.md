---
name: gsd-tdd-daemon
description: Background continuous testing daemon that automatically spawns debug agents on test failures.
---

<objective>
Launch a continuous `npm run test:watch` command (or language equivalent).
When a test fails while the developer is saving files, intercept the failure output and automatically spawn a `gsd-debugger` fast-mode agent to patch the code without breaking flow.
</objective>

<execution_context>
@~/.gemini/antigravity/get-shit-done/workflows/tdd-daemon.md
</execution_context>

<context>
Daemon mode runs via an Antigravity background process.
</context>

<when_to_use>
- Inside `/gsd-execute-phase` when TDD is the chosen method.
- Any time the user is actively working on code and wants invisible pair-programming fixes.
</when_to_use>

<process>

## 1. Environment Setup
Find the test command in `package.json` or `Makefile`.
Start the command in watch mode.

## 2. Daemon Loop
Continuously pipe `stdout/stderr` from the test runner.
Wait for the word `FAIL` or `ERR` or non-zero exit code boundaries.
If passing: Print `GSD TDD: Tests Passing ✓` in console and wait.

## 3. Failure Interception
Extract the last 50 lines of test failure output.
Do not pause the watcher process. Keep it running.

## 4. Spawn Background Agent
Spawn a cheap, fast model (e.g., `gemini-1.5-flash` or `haiku`) as a subagent.
**Prompt to agent**:
"Fix the test failure in {recent_file}. Failing output: {stderr}. Edit the code directly via tools and exit."

## 5. Wait for Verification
The watcher detects the file save triggered by the agent. 
If tests pass, the daemon logs `GSD TDD: Auto-fixed {file} ✓`.
If tests fail again, the agent is aborted after 3 retries, logging `GSD TDD: Requires manual intervention.`

</process>
