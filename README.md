# Gated Dev Agents

Claude Code subagents and skills for an **implement → spec review → code-quality review → QA** loop where "done" means proven by fresh evidence, not by a green build.

Built to slot into [superpowers](https://github.com/obra/superpowers)' `subagent-driven-development`, but every agent works on its own.

## What's inside

### Agents

| Agent | Role |
|---|---|
| `implementer` | Implements a scoped task and commits verified code. Runs every gate (scoped tests, lint, build, real type-check, boot, behavior), removes code its change made dead, keeps comments minimal and never puts ticket/issue ids in code. |
| `spec-reviewer` | Read-only. Checks the diff against the task text: nothing missing, nothing extra, nothing misunderstood, every requirement proven by a test. |
| `code-quality-reviewer` | Read-only. Reviews DRY/SOLID/KISS, correctness, tests, typing (detects Nx, Vite, SWC and other toolchains that don't type-check on build) and readability (line/function/file length, nesting, organization, naming). Hygiene checks only on modified files: comment excess, tracker ids, dead code left by the change. |
| `diff-premortem` | Blind risk read: sees only the diff, never the ticket or intent, and names the 1-3 most likely production incidents. |
| `qa-verifier` | Independent PASS/FAIL against acceptance criteria with evidence, adversarial temp tests and a pre-mortem. Never edits product code. |
| `e2e-runner` | Runs browser end-to-end flows against an environment and reports PASS/FAIL, separating product failures from harness failures. |

### Skills

| Skill | Used by |
|---|---|
| `implementing-with-gates` | `implementer` (and the main thread when implementing) |
| `verifying-changes` | `qa-verifier` |
| `running-e2e-verification` | `e2e-runner` |

## Install

### As a plugin (recommended)

```text
/plugin marketplace add raalarcon9705/gated-dev-agents
/plugin install gated-dev@gated-dev
```

Or from the shell:

```bash
claude plugin marketplace add raalarcon9705/gated-dev-agents
claude plugin install gated-dev@gated-dev
```

Agents and skills appear namespaced: `gated-dev:implementer`, `gated-dev:implementing-with-gates`, etc.

### As plain files

Copies into `~/.claude` (or a project's `.claude`) with bare names (`implementer`, `implementing-with-gates`):

```bash
git clone https://github.com/raalarcon9705/gated-dev-agents.git
cd gated-dev-agents
./install.sh                     # user-wide: ~/.claude
./install.sh --project ~/my-app  # one project: ~/my-app/.claude
./install.sh --uninstall         # remove
```

Existing files with the same names are overwritten. Restart Claude Code afterwards.

## Recommended companion

The skills reference `superpowers:test-driven-development`, `superpowers:verification-before-completion` and `superpowers:requesting-code-review`. Install superpowers for the full loop:

```text
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

## Usage

Dispatch through the Agent tool, passing everything the agent needs in the prompt. The agents ignore CLAUDE.md on purpose (`omitClaudeMd: true`), so project rules (branch naming, test-lock commands, trackers) apply only if you state them.

- **implementer:** repo/worktree path, base branch, full task text and acceptance criteria.
- **spec-reviewer:** full task text, the implementer's report, repo path, `BASE..HEAD`.
- **code-quality-reviewer:** summary, task text, repo path, `BASE..HEAD`. Run after spec-reviewer returns ✅.
- **diff-premortem:** only the repo path and diff range.
- **qa-verifier:** repo path, branch or range, acceptance criteria, environment.
- **e2e-runner:** runner path, flow, environment, fixtures.

## License

MIT
