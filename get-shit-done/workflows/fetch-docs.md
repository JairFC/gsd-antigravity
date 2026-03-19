---
name: gsd-fetch-docs
description: Real-time RAG documentation fetcher to eliminate hallucinated API usage.
---

<objective>
Before starting a phase that relies on an external library (e.g., Next.js 14, Stripe API), automatically scrape the web for the latest documentation, convert to markdown, and save it in `.planning/vendor/` to create an immutable truth-source.
</objective>

<execution_context>
@~/.gemini/antigravity/get-shit-done/workflows/fetch-docs.md
</execution_context>

<when_to_use>
- Automatically injected into `/gsd-plan-phase` if the stack involves new or rapidly changing technologies.
- Manually run `/gsd-fetch-docs <library name>` to sync local references.
</when_to_use>

<process>

## 1. Parse Input
Extract library name and optional version from args.
If absent, ask user: "Which framework or library docs do you need to fetch?"

## 2. Parallel Web Search
Spawn parallel calls to the `search_web` tool:
- Query: `{library} {version} documentation`
- Query: `{library} {version} getting started examples`
- Query: `{library} {version} API reference`

## 3. Extract and Parse
From the search results, extract structural Markdown.
Synthesize the examples and API surface into a comprehensive markdown file.

## 4. Save Vendor Doc
Save as `.planning/vendor/{library}.md`.
Inform the user:
> 📦 GSD will now use `.planning/vendor/{library}.md` as the ultimate source of truth, ignoring any outdated pre-training knowledge.

</process>
