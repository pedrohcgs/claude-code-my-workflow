# External oracle consult — PR #177 fork-safety stress test

**Date:** 2026-11-06
**Oracle:** GPT-6 (ChatGPT picker target "GPT-6") at Pro effort, browser transport, oracle CLI 0.22.2. The first attempt, with oracle 0.21.3, could not find ChatGPT's model picker and sent nothing.
**Repository state reviewed:** `0bd456d` plus uncommitted working-tree changes (the first repair of the fork-safety fix). The files sent are hashed in [`meta.json`](meta.json).
**Conversation:** `https://chatgpt.com/c/6aee5603-e200-83ea-9a41-732e299536ef`
**Artifacts:** [`prompt.md`](prompt.md) — the question as asked · [`transcript.md`](transcript.md) — the answer as returned, unedited · [`meta.json`](meta.json) — the same facts in machine-readable form

## Why this file exists

The repair of `scripts/file-issue.py` in PR #177, and the hook-battery cases i16–i20, rest on this consult. Following `.claude/references/external-oracle-process.md`, a claim that rests on a consult cites the archived transcript, not a recollection of a session.

**Fencing.** The referee received a neutral copy outside the checkout, under neutral file names. It did not receive the in-session review's findings, so its findings are independent evidence about the change. They are not independent of its own model's blind spots.

## Verdict returned

"The fork-safety fix is incomplete." 6 major and 8 minor findings, followed by a list of model claims the attached sources could not settle.

## Adjudication

Each finding was a candidate until it was checked against the code.

| # | Finding | Verdict | What changed |
|---|---|---|---|
| 1 | Remote origins fall through unpinned (`host:/path`, one-letter hosts, IPv6, embedded newline, malformed bytes) | **Confirmed** | Only a positively local origin is left to gh. Anything else that cannot be identified stops the script. Case i18 |
| 2 | The "dotless host means a github.com alias" guess misroutes Enterprise aliases and dotless hosts | **Confirmed** | ssh hosts are resolved with `ssh -G`; https hosts are kept as written. Cases i12 and i16 |
| 3 | An `OWNER/NAME` pin still lets `GH_HOST` choose the server | **Confirmed** | The pin is always `HOST/OWNER/NAME`, and `/commit` does the same. Case i11 |
| 4 | The template exemption ignores the host | **Confirmed** | Only the template on github.com is exempt. Case i17 |
| 5 | The printed follow-ups (`gh issue view/comment/reopen`) and the `/issues` preflight pick their repository separately | **Confirmed** | The follow-ups carry the same `--repo`; the preflight checks origin's repository. Case i20 |
| 6 | The fake `gh` cannot intercept native Windows Python, so a real `gh` could run | **Pre-existing; mitigated** | The battery's gh calls run with an unusable `GH_TOKEN`, so a real `gh` reached by mistake creates nothing. CI is Ubuntu-only. |
| 7 | `file://localhost` is mis-pinned or wrongly refused | **Confirmed** | `file:` is a local origin. Case i19 |
| 8 | A credential in the query string, or malformed userinfo, still reaches stderr | **Confirmed** | The error no longer repeats the URL. Case i14 |
| 9 | Flattened argv logging accepts a fused `--repo X`; the regex dots accept a near-miss host | **Confirmed** (the mutant was reproduced) | The fake gh logs each argument as `<word>`; assertions are exact and fixed-string. |
| 10 | "Claude can no longer change settings at all" overclaims | **Confirmed** | The wording now says Claude's tools no longer edit them, and that a branch switch or a merge can still replace the file. |
| 11 | "Outside the repository" is the wrong boundary | **Confirmed** | The wording now says "working directories", with Claude Code's session files excepted. |
| 12 | "`onFailure` catches only start/timeout" underclaims | **Confirmed** | It now also names unexpected exit codes and invalid output. |
| 13 | The ledger's dated totals were rewritten from 312 to 317 | **Rejected** | `scripts/check-derived-counts.py` requires every `N cases, exit 0` claim in `LEDGER.md` to state the current total. The reproduction lines describe the result of re-running today, and that re-run passes. |
| 14 | "Versions are pinned" also covers the unpinned R entry | **Confirmed** | The comment now names what is pinned and what is not. |

On the model facts: the referee confirmed every claim it could check against the attached excerpts. Of the claims it could not settle, Sonnet 5.5's release date (2026-09-28), its 1M context, 128K output, adaptive thinking and cache-read price were then checked against `platform.claude.com/docs/en/models/sonnet-5-5/overview` and agree. The remaining unsettled claims are on lines this PR did not change.
