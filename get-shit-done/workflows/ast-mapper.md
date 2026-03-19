---
name: gsd-ast-mapper
description: Generate a deterministic AST representation of the codebase using tree-sitter.
---

<objective>
To replace hallucinated codebase architecture documents with a deterministic, token-efficient, and parseable Abstract Syntax Tree map (AST-MAP.md).
</objective>

<execution_context>
@~/.gemini/antigravity/get-shit-done/workflows/ast-mapper.md
</execution_context>

<context>
Running `gsd-ast-mapper` compresses 10,000 files into a dense map of class, function, and variable signatures.
</context>

<when_to_use>
- Automatically triggered inside `/gsd-plan-phase` to inject code context without loading full files.
- Before major refactors.
- To sync `.planning/codebase/AST-MAP.md` after an external manual commit.
</when_to_use>

<process>

## 1. Tool Check
Verify if `tree-sitter` CLI or the Antigravity `ast_parser` tool is accessible.
If not, exit and advise user to install prerequisites or fallback to standard `/gsd-map-codebase`.

## 2. Directory Scan
Compile list of all tracked code files (ignoring `.gitignore`).
Exclude trivial assets: `.png`, `.jpg`, etc.
Exclude docs: `.md`, `.txt`.

## 3. Run Parser
Construct an AST repomap using the parser.
Output format should resemble Aider's repomap: 
```
src/main.ts:
      export clsss App
        constructor()
        init()
```

## 4. Save and Commit
Write output to `.planning/codebase/AST-MAP.md`.
Log byte size and token savings compared to raw files.
Commit the generated map.

</process>
