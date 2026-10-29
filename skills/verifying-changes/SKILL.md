---
name: verifying-changes
description: Use when asked to verify, QA, test, validate, review-for-approval or sign off a change, PR, branch, commit, bead, ticket, or another agent's or skill's output, or when about to give a PASS/FAIL, LGTM, "good to go" or ship verdict, in the main thread or as a subagent, especially under time pressure or when tests, screenshots or the author already say it works.
---

# Verifying Changes

Run it, then give a verdict. CI, screenshots and the author's word are claims, not evidence. Builds on superpowers:verification-before-completion.

## Rules

1. **Read-only.** Never fix, revert or stash product code, even if asked; report it. The only writes allowed are temp adversarial test files, deleted afterwards.
2. **Run it.** Build, test, exercise. Code review alone is not QA.
3. **Use the repo's commands:** what the caller states in the prompt, else the repo's own build files (package.json, Makefile). Don't depend on CLAUDE.md or workspace docs. Use a test-lock command if the caller gives one. Scoped suites only.
4. **AC table.** Each criterion needs evidence (command plus output). One unmet = FAIL. Failing tests or lint = FAIL. An unrelated bug = PASS the item and report the bug separately.
5. **UI:** use a real browser (claude-in-chrome or Playwright) on the running app. For a shared component, exercise or trace EVERY mount surface and list them.
6. **Adversarial:** write 3-5 unit tests in a temp file covering boundaries, empty/null, malformed input and error paths. A failure is a proven gap: report its code and output. Delete the file, never commit it.
7. **Pre-mortem:** dispatch Agent `subagent_type: gated-dev:diff-premortem` with ONLY the repo path and diff range, never the ticket or intent. Report its 1-3 risks apart from AC. If it is unavailable, do it yourself from the diff only, before re-reading the ticket.
8. **Report.** The first word is `PASS` or `FAIL`. Then the env, branch and commit tested; the AC table; evidence; adversarial findings; pre-mortem risks.

Can't run something? **FAIL (unverified: <what>)**, never "not signed off yet" or "your call".

## Rationalizations

| Excuse | Reality |
|---|---|
| "Release cut in 20 min" / "if time runs out, your call" | The bar doesn't move. Blocked = FAIL (unverified). |
| "I'll fix small issues directly, as asked" | Verifiers never edit. Report it. |
| "Stash/revert the fix to see the tests go red" | That mutates the tree. Reproduce it in a temp test. |
| "Author was right the last 10 times" | A track record is not evidence for this diff. |
| "CI green" / "the screenshot shows it" | Existing tests and one happy path. Check every AC and every surface. |
| "Skim the diff" / "run the full suite" | A skim is not a pre-mortem. Run scoped suites only. |

## Red Flags: stop

- The reply doesn't start with PASS or FAIL
- About to edit, stash or revert product code
- An AC lacks output, or only one path/surface was checked
- The temp test file is still on disk
