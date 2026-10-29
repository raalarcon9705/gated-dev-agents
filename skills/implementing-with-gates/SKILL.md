---
name: implementing-with-gates
description: Use when implementing a feature, bugfix or refactor in any repo, in the main thread or as a subagent, and before claiming done, committing, pushing or handing off. Also when renaming, moving or deleting files, adding path aliases or DI wiring, working in an unfamiliar repo, or under pressure to "just push" because tsc, a build or a mocked unit test passes.
---

# Implementing With Gates

Done means proven by fresh evidence. tsc, builds and mocked tests each miss whole classes of breakage. **Violating the letter of a gate is violating its spirit.**

## Before Code

1. **Discover the repo contract:** conventions the caller states in the prompt first, then CI workflows (`.github/workflows`, etc.; exact commands live there), then the repo's own build files (see Ecosystems). Don't depend on CLAUDE.md or workspace docs. Find test, lint, build, boot/dev commands and the production/default branch. Package manager comes from the lockfile. Never guess it.
2. **Write a short PLAN:** steps, files, how it will be tested.
3. **Tests first or alongside.** **REQUIRED SUB-SKILL:** superpowers:test-driven-development.
4. **Contract:** frontend never builds UI for fields/mutations the backend doesn't expose. Check the current remote schema and report the gap. Own the backend? You own the contract.

## Gates Before Done, Commit, Push or Hand-off

Paste the output in the same message. Stale output or "should pass" doesn't count.

| Gate | Pass condition |
|---|---|
| Tests | Scoped to the touched package/app/file, green. Never repo-wide or `--parallel` all. If the caller gives a test-lock/wrapper command, use it. |
| Lint | Fixer run, re-checked, zero errors |
| Build | Exit 0 |
| Symbol integrity | Every deleted/moved/renamed path: no leftover imports, string references (mock/patch targets, dynamic imports, config, docs, Dockerfile, CI) or path aliases missing from a second resolver. Compile every build variant (features, build tags, extras). |
| Dead code | Every symbol, export, prop, param, import, branch or file your change stopped using: repo-wide search finds no references outside its own definition/tests, or it is deleted along with those tests. Linter/type-check unused rules: zero new warnings. Only code your change made dead; report pre-existing dead code, don't delete it. |
| Hygiene | Added comments match the file's density and explain only a non-obvious *why*; none restate code or narrate the change. No ticket/issue/bead ids (`ST-1111`, `#123`, `str-qwe`) in identifiers, file/test names, comments or strings (check command below the table). |
| Wire compat | New/changed field on a serialized type (JSON, DB, events): old payloads still deserialize, or it's a declared breaking change. |
| Boot | Backend: start it and get a clean startup log (DI/wiring errors escape build, tests and mocks). Frontend: dev server returns HTTP 200 on the route. Kill it after. |
| Behavior | User-visible change: exercise it (browser or curl) |

Hygiene check (hits are candidates; hex colors and real values are fine):

```bash
git diff <BASE> | grep -nE '^\+.*(\b[A-Z]{2,}-[0-9]+\b|#[0-9]+|\bstr-[a-z0-9.]+|\b(issue|ticket|bead)\s*[0-9a-z-]+)'
git diff <BASE> | grep -niE '^\+.*st[_-]?[0-9]+'
```

The code-quality pass belongs to superpowers:requesting-code-review.

## Ecosystems

| Stack | Commands from | Compiler/typechecker misses |
|---|---|---|
| JS/TS | lockfile → pnpm/yarn/npm, package.json scripts | bundler/test-runner aliases, `vi.mock`/`jest.mock` strings |
| Python | `uv.lock`/`poetry.lock`/`requirements*.txt`, pyproject `[tool.*]` | everything at runtime: `patch("old.path")`, `importlib`, DI/lifespan wiring |
| Go | `go.mod`, `.golangci.yml` | `//go:build` tags, env/config read at startup |
| Rust | `Cargo.toml` workspace members, `rust-toolchain.toml`, `--locked` | non-default features, serde shape, `sqlx`/macro-time DB checks |
| JVM/.NET | `pom.xml`/`build.gradle`, `*.csproj` | Spring/DI container wiring, reflection |

## Git

- Conventional Commits, one per logical unit. English only in commits, PRs and code comments. Tracker ids go in commit messages and PRs, never in code.
- Branch from `origin/<base>` after `git fetch`, never from a local ref.
- Never rebase shared branches. Merge.
- Never `git stash` as a parking lot, and never stash someone else's work.
- Stage explicit paths. Lint before every push.

## Stop and Escalate

- Blocked for more than ~15 min: report it.
- Another session is editing the same files, or the checkout is dirty on someone else's branch: use a worktree, or ask.

## Rationalizations

| Excuse | Reality |
|---|---|
| "tsc / pyright / go build / cargo check is clean, push" | Compilers miss runtime wiring, string refs, other build variants and wire shape. Run the remaining gates. |
| "User ordered the push, their call" | First say which gates are missing and that they take minutes. Still insists? Push labeled WIP, list unrun gates, never call it done. |
| "Mocked unit test passes" | The mock hides missing providers. Boot the app. |
| "Module compile test is enough" | Boot the real entrypoint. |
| "Full suite if it's quick" | Scope it. |
| "Rebase onto origin" | Merge. |
| "Stash for a clean tree" | Worktree. |
| "The old helper might be useful later" | Zero callers after your change = delete it. |
| "A comment with the ticket id gives context" | Context lives in the commit/PR. Name the code for what it does. |

## Red Flags: Stop

- "Done" or a push without gate output in this message
- "Clean up later" / "tests afterwards"
- Renamed a file and only the compiler/typechecker ran
- New injected dependency, app never started
- `git stash`, `git rebase`, or a branch from local `main`
- Replaced a function/component and never searched for the old one's remaining callers
- An identifier or comment containing a ticket, issue or bead id
