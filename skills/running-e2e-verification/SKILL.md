---
name: running-e2e-verification
description: Use when asked to "run the e2e", "smoke test", "verify the full flow" in an environment, to triage an anomaly seen in e2e output, or to run any project-specific e2e skill, in the main thread or as a subagent.
---

# Running E2E Verification

Browser end-to-end runs (Playwright or similar). Short orders are enough: infer env, flow and skill; never interrogate the operator.

## Procedure

1. **Short order.** Infer env and flow from the caller's prompt and the runner itself (config, spec names). If the caller names a project e2e skill, use only that one (it owns the harness). Don't depend on CLAUDE.md or workspace docs. Ask only if truly ambiguous; otherwise take the safe default and note it in the report.
2. **Preflight.** Install missing runner deps and browsers before running. A missing dependency is never a product defect.
3. **Environment.** Use the env the caller names, else the runner config's default (e.g. playwright.config `baseURL`). A reachable localhost is NOT a reason to use local; local only when explicitly asked. Headless by default. Headed only on explicit request, and never for flows that open native OS dialogs (downloads, Save As): drop headed silently and say why.
4. **Production.** Read-only flows only; leave no test data. Ask before changing data in staging or production-like environments.
5. **Credentials** come from gitignored env files. Never print them, commit them, or put them in messages.
6. **Known intentional behaviors.** Before flagging any anomaly, check the known-intended-behaviors list the caller provides (a file path or inline list), if any. When a finding is confirmed intended and the caller gave a file, add a row there; otherwise list it in the report as "confirmed intended".
7. **Goldens.** Expected fixtures are written from the source document plus the schema. Never adjust them to match system output.
8. **Report.** First word `PASS` or `FAIL`; then env, steps passed/failed, evidence paths (screenshots, traces, outputs). State whether each failure is product or harness/infra.

## Rationalizations

| Excuse | Reality |
|---|---|
| "Localhost is up, use it" | Reachability is not a request. Use the declared default. |
| "Browser missing, so the test can't run" | Install it and run. Not a finding. |
| "Headed so they can watch" | Only if asked; never with downloads/Save As. |
| "Golden fails, update it to match" | Goldens come from source + schema, never from output. |
| "That `~` looks like a bug" | Check the known-intended list first. |
| "I need env/flow details first" | Infer; note defaults in the report. |

## Red Flags

- Running local because a port answered
- Reporting an install or auth failure as a product bug
- Editing a golden or spec to get green
- Secrets in output or commits
- Report not opening with PASS/FAIL
- Writing to staging/prod without asking
- Skipping the known-intended check, or not recording a confirmed one
