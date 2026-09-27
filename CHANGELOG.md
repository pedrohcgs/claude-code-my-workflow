# Changelog

All notable changes to this template are documented here. We follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and use loose semantic versioning: **major** when fork upgrades require manual migration, **minor** for new skills or features that are additive, **patch** for fixes and docs.

If you have forked this template, see the **Upgrading** section at the bottom for how to pull updates without losing your customizations.

---

## v2.6.0 — 2026-09-26

A **currency and consistency release.** Claude Opus 5.5 and Fable 5.1 shipped after v2.5.1: the
Opus tier's default effort dropped from `high` to `medium`, thinking became always-on, and forced
tool choice disappeared from both top tiers. This release re-verifies the lineup against
Anthropic's docs, re-reads every effort pin against the new default, and — because a model that
follows instructions more literally makes a contradiction between two files more expensive —
runs Anthropic's prompt-audit method over the skills, agents, rules, and references, re-checks
every finding against the current tree, and fixes what survived. Dated prompt idioms were nearly
absent; the debt was drift between files.

### Changed — model refresh

- **Model SSoT** (`model-versions.md`) now reads Fable 5.1 | Opus 5.5 | Sonnet 5 | Haiku 4.5,
  verified 2026-09-26 and expiring 2026-11-25, with prices, effort defaults, minimum Claude Code
  versions (the current Opus needs ≥ 2.1.280), the Haiku retirement floor, and a re-verified
  alias table. Its update protocol gains a step: re-read every `effort:` pin when a default moves.
- **`model-routing.md`** — the effort section is rewritten for an Opus tier that defaults to
  `medium` and thinks more per turn at a given level; the Fable section now rests on cost and on
  Anthropic's own routing advice. The launch-week "28/28 structured-output failures" observation
  is retired: the forced-tool protocol it measured no longer exists on either top tier.
- **Effort pins (owner decision, 2026-09-26).** `editor`, both referees, and `claim-verifier` keep
  `high` — one level above the Opus default, on purpose. `verifier`, `quarto-critic`,
  `tikz-reviewer`, `sim-reviewer`, and `domain-reviewer` move to `medium`. `/respond-to-eval`,
  `/teach-from-paper`, `/grant-proposal`, `/respond-to-referees`, and `/new-diagram` drop their
  pin and inherit the session. `agent-fleet.md` gains an Effort column.
- README, guide, and TROUBLESHOOTING lineup, effort, and retirement text follow the SSoT; the
  guide gains a short **"Prompting the current Opus"** callout drawn from Anthropic's Opus 5.5
  prompting guide.

### Changed — permissions (owner decision, 2026-09-26)

- **`.claude/settings.json` no longer sets `defaultMode: "bypassPermissions"`.** Current Claude
  Code does not honour a bypass default in project settings — the terminal session starts in
  Manual mode — so the shipped default was dead configuration; with no override, Claude Code
  ≥ 2.1.283 starts in auto mode. This supersedes the v2.5.0 ruling that kept the bypass default,
  whose premise no longer holds for project settings. The allow list is unchanged.
  `.vscode/settings.json` still carries two bypass keys, but they do not set the VS Code starting
  mode: the current extension reads `claudeCode.initialPermissionMode` and
  `claudeCode.allowDangerouslySkipPermissions` from user settings only, and never reads the
  unprefixed key, so VS Code bypass is configured in user settings.
- TROUBLESHOOTING, the guide, and `/permission-check` now teach the two override rules (project
  settings cannot set bypass or auto; the VS Code extension ignores project settings for its
  starting mode), and the protected-path text matches the docs (Manual prompts, auto routes to
  the classifier, bypass allows).
- **Restricted data stays off the model.** A paste-ready deny-rule block, and a new section in
  `confidential-data.md` covering deny rules, external capture tools, and external-model consults.

### Changed — `/commit` stops at the commit (owner decision, 2026-09-26)

- **`/commit` no longer pushes, opens a pull request, or merges by default.** It runs the gates and
  commits (on a new branch when on `main`). `--pr`, or asking for a pull request, pushes and opens
  one. **It never merges**: a merge happens only when you say to merge that pull request, after
  its CI and reviews (human, Codex, Copilot) have been read. Before, the skill's last step merged
  the pull request as soon as it was opened, before any reviewer had commented.

### Changed — the external referee

- `external-oracle-process.md` is model-neutral, with a dated targets table (GPT-6 Pro when the
  account offers it, GPT-5.6 Sol Pro as the validated fallback, the API only with explicit
  consent, then the manual path), Oracle ≥ 0.21 / Node ≥ 24, the fail-closed `pro` effort tier,
  recovery commands, and a rule to record the model and effort that actually answered.
- `/oracle-review` gains a pre-send confidentiality check (restricted data, uncleared outputs,
  credentials — manuscripts and code are meant to be sent), and `/adjudicate-review`'s `PARTIAL`
  verdict is renamed `DOWNGRADED`, so both skills and the reference share CONFIRMED / REFUTED /
  DOWNGRADED.

### Fixed — contracts nothing honoured

- **Reviewer output contract.** `orchestration-schemas.md` required a validated JSON findings
  array that no reviewer agent was asked to produce — and the reviewers are read-only, so they
  could not write it or compute its ids. Each reviewer that feeds a reducing skill now ends its
  response with an id-less JSON block; the dispatching skill fills the ids with the new
  `validate-findings.py --fill-ids` and validates before reducing. Read-only reviewers are no
  longer told to save files; the severity map targets the JSON enum.
- **Skills that could not run as written:** two forked skills that needed the user mid-run; two
  skills that invoked user-invoked-only skills; three different stopping rules for one
  loop-until-dry primitive; a `/commit` gate `/verify-claims` promised and nothing implemented; a
  `/compress-session` hook example whose exit code would have blocked every compaction; a spec
  path no downstream skill read.
- **Hooks and status line:** `post-compact-restore.py` and the status line classified plan
  status by matching words anywhere in the file (and could restore a finished plan); both now
  read the Status field, like `pre-compact.py`. Restored context is labelled historical. The
  status line uses Claude Code's native context percentage and shows effort. The
  `root-of-trust-guard` docstring is now a raw string — its invalid escapes would become a
  syntax error in a future Python, and the guard fails open.
- Dead references and stale facts across skills, agents, and rules; pressure language removed
  from the two critics that run inside convergence loops; a MathJax nesting error in
  `beamer-translator`'s aligned-math rule.

### Changed — context cost

- `meta-governance.md` and `orchestrator-protocol.md` are path-scoped, so a research or teaching
  session no longer loads them; always-loaded rules drop by roughly two thirds.
  `prompt-shaping.md` is a short plain rule; `prompt-formatting-core.md` is retired to a tombstone.
- `MEMORY.md` keeps every lesson: stale ones gain dated addenda and related entries are merged to
  hold the 25KB cap, as `meta-governance.md` requires. `/promote-memory` proposes a demotion when
  the file nears its line or byte cap.

### Changed — output layout and quality rubric (owner decisions, 2026-09-26)

- **Generated results live in a top-level `output/`**, no longer in `scripts/<lang>/_outputs/`.
  This follows the AEA Data Editor's advice not to commingle code with its results, and it matches
  the layout `/replication-package` already deposits. R, Stata and Python all write there
  (Stata's environment record becomes `sessionInfo_stata.txt` so it cannot overwrite R's).
  Final tables, figures and logs are committed — after disclosure clearance when the data are
  restricted; `.rds`, `.parquet`, `.dta` and other regenerable intermediates are gitignored.
  `repo-hygiene.md` gains a "where each kind of file goes" table that states the whole layout.
- `/audit-reproducibility`, `/replication-package` and `/disclosure-check` default to `output/`
  and fall back to a pre-v2.6 `scripts/<lang>/_outputs/` when that is all a project has; the
  `claim-reconcile` hook watches both. **Forks:** `git mv scripts/R/_outputs output` (or re-run
  `00_run_all.R`), then point any `\input{}` paths at `output/`.
- **`quality_score.py` is the single source of the quality rubric.** `quality-gates.md` and the
  script had drifted both ways; the rule now embeds the script's `--print-rubric` tables, marks
  which rows the script detects and which are a reviewer checklist, and `check-derived-counts.py`
  fails on any difference. The two rows only the rule had (R domain bug −30, Quarto long line −1)
  moved into the script, and every deduction now reads its weight from the rubric.
- **Fixed:** the repo-hygiene gate rejected the top-level folders the new layout recommends
  (`output/`, `data/`, `R/`, `tests/`); they are now allowed.
- **Fixed:** `scripts/R/05_figures.R` reported writing `fig_main.pdf` when the PDF device had
  failed — cairo compiled in but not loadable, as on macOS without XQuartz — and left
  `Rplots.pdf` in the working directory. It now chooses the device by opening it, and stops,
  naming the file, if a promised figure was not written (#156).
- **Fixed:** `/replication-package` wrote Stata's environment to `output/stata_version.txt`; the
  Stata convention requires `output/sessionInfo_stata.txt`, and the skill now also checks that
  every `.do` pins `version NN` (#157).
- **Fixed:** `promote-memory-council`'s description said "forked context" while its body requires
  a fresh one (#158); the same wording is corrected in seven other files, and the guide.
- **Fixed:** `slide-qa.py` exited 0 on a deck whose math never typeset (no network, or MathJax
  blocked); it now fails with exit 2 and says how to fix it (#159). A slide that both overflows and
  hides clipped content now reports both, instead of only the first (#160).
- **Fixed:** `quarto-critic` could return APPROVED with major issues open, so `/qa-quarto` never ran
  its fixer on them; APPROVED now requires every hard gate to pass and no critical or major issue
  (#161).
- **Fixed:** 131 statements in the README, the guide, rules, skills and agents disagreed with the
  repository after the release was assembled (counts, paths, flags, removed features); each was
  confirmed against the tree and corrected. A second, independent pass over the README, the guide,
  `CLAUDE.md` and the landing page checked 865 statements and confirmed 44 more, also corrected —
  among them the guide's worked examples, which showed `/slide-excellence`, `/review-paper` and
  `/data-analysis` doing steps they do not do (#162).
- **Fixed:** `/deep-audit` lost `disable-model-invocation: true` when the v2.5 verification skills
  were merged, so a vague "audit this" could start its repo-wide fix loop; the flag is restored.
- **Fixed:** the guide no longer has agents argue for one estimator each. Pattern 9's "Agent Debates"
  told users to debate DiD vs synthetic control vs RDD, which the owner's methods ruling forbids;
  it is now "Independent Advocates", with a method-neutral example (competing framings), each
  advocate in its own context and the researcher deciding (#165).
- **Fixed:** refereed manuscripts stay out. `master_supporting_docs/` no longer invites papers you
  are refereeing into a committed folder; `/oracle-review`, `confidential-data.md` and
  `/triage-inbox`'s referee scaffold no longer send or copy in a manuscript or proposal you are
  reviewing; the guide says which terms (consumer or commercial) cover each kind of account (#166).
- **Fixed:** `/triage-inbox` digests are gitignored — they hold email subjects, senders and referee
  manuscript IDs — so inbox triage now runs as a local scheduled task, where the digest and the
  referee tracker persist, not as a cloud routine (#167).
- **Fixed:** session advice agrees with itself and with the handoff hook. Within a task, let compaction
  carry you; between unrelated tasks, `/clear`; to stop or hand off, `/checkpoint`, quit, and
  start a fresh `claude` — the hook hands the newest checkpoint, once, to the next fresh session
  (`--continue` and `--resume` do not get it) (#168).
- **Fixed:** TROUBLESHOOTING said deny rules do not cover shell commands; it now says Claude Code applies
  them to `cat`, `head`, `tail`, `sed`, `tee` and redirect targets (not to scripts, nor to a command
  that reads files without naming them, such as `grep -r pattern .`), and how to reach data kept
  outside the checkout (#169).
- **Fixed:** `/preregister` looked for a `paper_type:` field that `/interview-me` never writes (it
  writes a `**Paper type:**` line), so the paper type never reached the style choice.
- **Fixed:** `check-derived-counts.py` counted `/translate-to-quarto`'s Phase 6.5 as a second
  Phase 6, so the README's wrong "11 translation phases" passed; it now counts 12.
- **Fixed:** the hardcoded-path check read R strings that open with an escaped backslash — how R
  writes LaTeX — as Windows paths, so the template's own `04_tables.R` scored 0.
- **Fixed:** `check-derived-counts.py` compared the battery-size claim in *published* CHANGELOG
  entries against today's battery, so adding a case demanded an edit to released history; it now
  reads only the current release, like the inventory rows.

### Added

- **Slide QA in a real browser** (`scripts/slide-qa.py`). It loads a rendered Quarto deck in
  headless Chrome and measures what a reader sees on each slide — text, formulas (MathJax or
  KaTeX), images, chunk output, painted boxes — against the slide edges, in every fragment state
  and every tab, uncounted slides included. It also flags content hidden inside a scrolling
  element, and saves one screenshot per slide. `/visual-audit`, `/qa-quarto` and
  `/slide-excellence` run it, and `quarto-critic` and `slide-auditor` take their overflow findings
  from the measurement instead of guessing from the source. Needs Playwright for Python in a
  virtual environment named by `SLIDE_QA_PYTHON` (see Prerequisites); it drives the installed
  Chrome, and without it the skills fall back to the source.
- **Replication log.** Every `/audit-reproducibility` run now appends to
  `quality_reports/replication-log.md`: the commit it checked (marked `-dirty` for uncommitted
  code), and for each claim the reported and computed values, the exact accessor that produced
  the number, the tolerance and the verdict. Append-only, so a co-author can review the history
  instead of the code.
- **Session handoff** (`.claude/hooks/session-handoff.py`, on `SessionStart[startup]` and
  `UserPromptSubmit`). A fresh session is handed the newest `/checkpoint` or `/compress-session`
  file written in the last 7 days, labelled as notes to verify. It counts as used only once you
  type a prompt, so a session opened and closed unused (or a headless `claude -p` run, which never
  receives it) leaves it for the next one. `CLAUDE_HANDOFF=off` opts out;
  `CLAUDE_HANDOFF_MAX_AGE_DAYS` changes the window.
- **Specification ledger.** `/data-analysis` and `/stata-replication` append every specification
  they estimate — kept, dropped or failed — to `quality_reports/spec-ledger.md`, with the commit it
  ran on and, for anything not kept, why. It records the search without advising which
  specification to run; estimates are optional, and left out on restricted data until cleared.
- **Replication log and specification ledger are enforced append-only.** The repo-hygiene gate
  fails a commit that edits or removes a committed line — at pre-commit against the last commit,
  and in CI against the branch the work merges into, so a rewrite made without the hook is caught
  too. New lines may go anywhere, so a merge that interleaves two co-authors' entries passes.
  `ALLOW_LOG_REWRITE=1` covers a disclosure redaction, with the reason in the commit message.
- **Quote check on reviewer findings** (`validate-findings.py --check-quotes`). A quotation in a
  finding's evidence must be the text of the cited file, or of another file the evidence names by
  path — compared with LaTeX markup, dashes, whitespace and case normalised, except that a quote
  containing a backslash must match the source exactly. A PDF manuscript is read through
  `pdftotext`; a file that cannot be read as text leaves its quotes unchecked rather than failed.
  A miss goes back to its reviewer once; still unmatched, the finding is dropped before judging.
  The reviewer agents and the seven-pass lenses are told to quote verbatim.
- **Submissions are data, not instructions.** The editor, both referees, the claim verifier, the
  seven-pass lenses, `/review-paper`, `/adjudicate-review` and `/oracle-review` treat text in a
  manuscript, report or model reply that addresses an AI reviewer as a finding, never an order.
- **Slide QA catches broken assets** — images, backgrounds, video and other media that fail to
  load, local or remote, and local files that load only because the filesystem ignores letter
  case (they break on Linux and GitHub Pages) — each pinned to the slide that uses it.
- **`gate:off`** in the status line when the repo's pre-commit gate is not installed.
- **Faster pre-commit.** The hook battery (most of the suite's run time) is skipped locally when no
  hook, hook setting or battery file is staged; CI runs every gate on every pull request and on
  every push to a branch other than main.
- **"Changed defaults"** is a required section of the PR template and of the PR body `/commit`
  writes.
- **`/checkpoint` and `/compress-session` write only what the session established** — no
  `path:line` they did not read, no padded sections, earlier handoff text carried forward only if
  re-checked — because the handoff now hands their files to the next session automatically.
- **GitHub issues as the project's memory.** `CLAUDE.md` now states the practice, and
  `issue-ledger.md` spells out what gets an issue: every shipped bug (opened before the fix),
  every improvement deferred for later, every owner decision that blocks work, and one summary
  issue per review round over an unmerged branch. Issues are closed by hand when the fix lands —
  a short closing comment for a small fix, the full seven sections for anything that can move a
  result — and never carry restricted data. A guide section explains the habit for papers.
- **`/issues`** files findings as issues, lists what is open, and closes an issue with a comment on
  what was tried and how it was fixed; it shows every draft and posts nothing without a yes, and
  warns before posting to a public repository. `/review-paper`, `/seven-pass-review` and
  `/adjudicate-review` offer it at the end.
- **Duplicate check on every new issue.** `scripts/file-issue.py` searches open and closed issues
  several ways and creates nothing until each candidate has been reviewed; the issue body records
  the check. A new hook, `issue-guard.py`, denies a raw `gh issue create` (or a REST or GraphQL
  create) and points to the script. It is spawned only for `gh` commands (`"if": "Bash(gh *)"`,
  Claude Code 2.1.85 or later; older versions run it on every Bash call, still correctly).
  After the PR review (#164) it also sees a create behind shell control words (`if`/`then`,
  `{ }`, `!`, loops) or in a GraphQL query file, and the issue body records which kinds of search
  ran rather than their text.
- **Open issues at startup (opt-in).** With `CLAUDE_ISSUES_AT_START=1`, the new `open-issues.py`
  hook lists open issues' numbers and titles — by the owner and collaborators only — when a
  session starts. Off by default: it calls GitHub on every startup.
- **Guide: adopting the template in an existing project** — six steps, tested end to end on a
  project with its own README and folders.
- `check-model-versions.sh` catches superseded **model IDs**, refuses to let a comparison excuse a
  line that asserts a **default**, and scans `agent-fleet.md` — qualified on seeded defects, with a
  ledger row. `validate-findings.py --fill-ids`, with a ledger row.
- README and guide: the mid-2026 Claude Code features worth knowing; TROUBLESHOOTING:
  deadline-safe updates and the headless credit pool.

- **Small edits borrowed from claudeblattman** (after reading it for ideas; it also turned up the
  defects above, #165–#169; each was filed as an issue before it was fixed):
  - **A missing lens is not a dry round** in the review loop (`orchestrator-protocol.md`).
  - **Restricted data:** deny patterns for data outside the checkout (`//` and `~/` anchors), and
    Claude Code's own transcripts and file history named as copies a data agreement covers.
  - **`/lit-review`** reports independent vs apparent study counts and searches for null results.
  - **`/new-skill`** asks which steps send or cannot be undone, and whether self-critique needs a
    fresh context.
  - **`/grant-proposal --call <file>`** reads the program's actual call — its sections, limits and
    review criteria override the generic funder profile.
  - **Scanned PDFs:** `/teach-from-paper`, `/respond-to-referees`, `/respond-to-eval` and
    `/seven-pass-review` compare `pdfinfo`'s page count with the pages that returned text; the extracted text goes to a
    private temp folder that is deleted when the skill is done (before, a plaintext copy was left behind).
  - **Guide:** an optional fresh-context read of a plan before approval; read any skill, hook or
    plugin before installing it.

### Considered, not adopted

- **claudeblattman** (MIT) — beyond the small edits above: assistant and meeting skills, a persona
  council, completeness and skeptic agents, a causal-language audit (its design ranking is method
  content), and prompt skills either duplicate what the template has or do not fit it.
- **ai-memory** — two ideas adapted (labelled restore context; demote near the cap); the tool
  itself captures prompts and shell output in every repository by default, which conflicts
  with `confidential-data.md`.
- **claude-code-tips** — ideas only; the repository is All Rights Reserved.
- **Scan of ai-memory and awesome-ai-agents (both MIT), 2026-09-26 — owner declined:** an OpenAlex
  first pass in `/lit-review` (judged a risk to retrieval quality), a paste-ready sandbox block,
  further `confidential-data.md` additions, gitleaks and pinned CI actions, an author check before
  push, and a skill-description budget check.
- **awesome-ai-agents** — no scholarly tools; its restricted-data concern is adopted above,
  browser-measured slide QA is adopted (see Added), and gate mutation testing goes to the backlog.

**Inventory at release: 61 skills, 18 agents, 37 rules, 11 hooks, 11 gates**
(v2.5.1: 60 skills, 8 hooks; the rest unchanged).

### Verification of this release

- **Audit before change.** Anthropic's prompt-audit method ran over the skills, agents, rules,
  references, `CLAUDE.md`, and `MEMORY.md` in four read-only passes; every finding was then
  re-checked against the released tree before planning, and only survivors were acted on.
- **Two fresh-context reviews of the diff** (correctness and consistency; prompt quality of the
  new text): 28 findings, every one checked against the files before fixing — 27 confirmed and
  fixed, 1 refuted (its claim is in Anthropic's own Opus 5.5 prompting guide; now cited).
- **A loop-until-dry review** — six lenses (facts, runtime contracts, cross-file consistency,
  prompt quality, docs, scripts), each finding checked by one verifier trying to reproduce it and
  one trying to refute it: round 1 confirmed 56 of 61, round 2 confirmed 31 of 39 (many duplicates
  across lenses); all confirmed findings are fixed. **The loop was stopped after round 2 by
  owner decision, so convergence (two consecutive rounds with nothing new) is not claimed.**
- **Gates:** `./scripts/backtest.sh` passes all 10 gates, including the hook battery
  (312 cases, seconds to run; the new case fails against the hook's old watch pattern).
  Every checker this release changed was re-qualified on seeded defects with clean controls
  (ledger rows): `check-model-versions.sh` 5/5 recall, 0/4 false positives;
  `validate-findings.py --fill-ids` 4/4; `check-derived-counts.py` seven-pass pattern 1/1,
  rubric parity 4/4 with 0/1 false positives, current-release battery scoping 1/1 with 0/1;
  `quality_score.py` path check 3/3 with 0/3, and its rubric refactor left every report
  byte-identical on 13 files; `slide-qa.py` on two regression decks built from an adversarial
  review (34 slides: 18 planted failures, one per failure mode, and 16 clean controls, MathJax and KaTeX) — every verdict as expected;
  `session-handoff.py` 8/8 seeded faults, each caught by its own battery case;
  `validate-findings.py --check-quotes` 24 cases (8 invented or altered quotes caught, 16 genuine
  quotes passed — LaTeX, PDF, elisions, parity, inline code) plus an unreadable file left
  unchecked; the append-only check 10 cases in a throwaway repository (edits, deletion, a staged
  edit, `git rm --cached`, CRLF, a merge, a CI rewrite); slide-qa assets 8 cases plus the 45
  control slides; the pre-commit battery skip on ten staged-path lists and a 129 KB list.
- **An adversarial review of the three additions** (slide QA, the replication log, the handoff)
  confirmed 26 of 27 findings, each reproduced by an independent verifier; all are fixed. A
  second review, of the ten scan additions, confirmed 44 of 46; all are fixed.
- The guide is re-rendered and stamped; `quality_score.py` reports no critical issues.

*Note:* the archived external-referee consult in
`quality_reports/oracle_audits/2026-08-23_v2.5.1-guard-design/` refers to "the v2.6.0 entry" —
that release was renumbered before shipping and is the **v2.5.1** entry below; this v2.6.0 is a
different release.

## v2.5.1 — 2026-08-24

An **enforcement release.** Disciplines that had been working conventions in the owner's
research repositories become mechanisms here: the qualification ledger stops being a document
and becomes a build dependency, the guard hooks stop being trusted and start being re-tested on
every run, and reviewer independence stops being an instruction to the reviewer and becomes a
property of the environment it is dispatched into. Where v2.5 asked whether the template's
claims were true, v2.5.1 asks whether the things that check them still work.

### Added — enforcement

- **Gate 9 — `scripts/check-ledger-coverage.py`.** The qualification ledger becomes
  load-bearing. A **registered check with no ledger row fails the build**; a row filed under
  *Not yet qualified* is **visible debt** and warns instead of failing; a row naming a checker
  no longer on disk fails. The same gate covers the hook layer — every hook registered in
  `.claude/settings.json` must exist, be invocable, and be tracked — so a one-character path
  typo can no longer disable a hook silently while every gate stays green. The registered set
  is derived live from the gate runner, the session settings, and the commit entry point;
  grepping the ledger cannot know what actually runs.
- **Gate 10 — `scripts/hook-battery.sh`.** A standing seeded battery (234 cases, seconds to run)
  that re-fires every active guard hook's target failure on **every backtest run**: the deny
  cases, the clean controls that must stay silent, fail-open on a malformed event, and the
  documented escape hatches. Gate 9 proves a hook is *wired*; gate 10 proves it still *acts*.
- **`.claude/hooks/root-of-trust-guard.py`** (PreToolUse) — denies shell writes into
  `.claude/settings*.json`, `.claude/hooks/`, and `.githooks/`: the files that define every
  other gate. Reads pass, and `Edit`/`Write` stay allowed because they leave a reviewable diff.
  It is a **textual scan, and defense-in-depth rather than a proof** — it catches the direct
  forms and the payload carriers it knows, and its docstring names what stays out of reach
  (an interpreter it cannot read into, a path piped to a deleter, an unenumerated execution
  form). Both guards state their own boundary, because a guard trusted past its coverage is
  worse than none.
  The hatch is `ALLOW_ROOT_OF_TRUST_WRITE=1`, deliberately an explicit decision rather than a
  default.
- **`git-guardrails.py` gains a clean-tree precondition.** Merges, rebases, and pulls refuse to
  start over a dirty tree — commit it, or stash it under a label that says what it is
  (`--abort` / `--continue` / `--skip` / `--quit` / `--edit-todo` exempt; hatch
  `ALLOW_DIRTY_MERGE=1`). The asymmetry is the whole argument: the check costs one command, and
  the failure it prevents is uncommitted work destroyed by a merge that mostly succeeded.
  **Four of its rules refuse command shapes a fork may be running today — read them before you
  upgrade.** (1) A history op is accepted **only as a standalone simple command**: a second
  segment, a pipeline, a redirection, a command or process substitution, a grouping, a `cd`, or
  a variable assignment denies it *regardless of tree state*, so `git pull | tail -5`,
  `git pull > log 2>&1`, `git merge x && npm install` and `git merge $(cat branchfile)` are all
  now refused. That shape is the only thing a PreToolUse hook can honestly stand behind — a
  tree reading taken before bash runs says nothing about the tree the op starts from unless
  nothing on the line can write in between. (2) `--autostash` is **no longer unconditionally
  exempt**: it now reads the tree and is allowed only when no untracked (`??`) entry is
  present, because `git stash` does not stash untracked files at all. (3) A `-C <path>` the
  guard cannot resolve — an unexpanded `$var`, a directory that does not exist — **denies**,
  instead of quietly falling back to the session's own repository and allowing because *that*
  one was clean. (4) `--git-dir`, `--work-tree`, `--namespace`, `--bare`, and any `NAME=VALUE`
  assignment on the line (`GIT_DIR=`, `GIT_WORK_TREE=`, …) deny outright; run the op from the
  repository it belongs to. **The accepted cost is one extra tool call** — with its own hook
  cycle and agent round trip, not "one extra keystroke", as an earlier draft of the hook's own
  docstring claimed.
- **The hook layer is qualified, not assumed.** Every guard hook and every gate this release
  adds carries a ledger row with **recall and false-positive rate** measured against seeded
  defects *and* clean controls — gate 9 fails the build if one is missing — including a
  *grading-the-grader* row that stubs a guard hook to always-allow in a copied hook directory
  and confirms the battery goes red and names the failing case. Six further rows record
  **visible debt**: the five passive hooks and the pre-commit entry point, unmeasured and
  saying so, because a hook nobody watches is the gate most likely to be dead.

### Added — the fencing and disposition layer

- **`.claude/rules/review-fencing.md`** — path-scoped to `.claude/agents/**` and
  `.claude/skills/**/SKILL.md`, so it binds where reviewers are actually authored. Independence
  is a property of the **environment**, not a sentence in a prompt: a reviewer with a spotless
  context still holds a checkout containing the previous round's verdicts, the passport listing
  every number the paper claims, and the stamp recording what the current render was built
  from. *Prompting an agent to review independently while it can `grep` for the answer is an
  honour system with a search tool.* So an independence-critical reviewer gets a **neutral copy
  outside the checkout** under a filename that carries no verdict, prior verdicts withheld, its
  own reading formed before it sees anyone else's, and positive controls fenced from the answer
  keys this template itself commits — passports, `.render-stamp`, the qualification ledger.
  With a table of when to fence and when in-repo review is exactly the point.
- **The `WITHDRAW` disposition** joins the verification ladder. When a default, a capability, or
  an automatic behaviour misses the numeric bound it preregistered, it is **demoted to explicit
  opt-in — never rescued by widening the bound**, because a bound moved after seeing the number
  is a description of the result, and every claim that later cites it is circular. Three
  obligations discharge it: publish the failing number, the bound it missed, and the disposition
  **where users read**; preserve the failing campaign as negative calibration evidence, never
  re-run against unchanged inputs; and enumerate every adjacent surface as affected or
  explicitly not. *The bound is the promise; the default is the endorsement.*
- **A noise floor beside the positive control.** The seeded case proves a checker can fire; it
  says nothing about how far the checker moves when nothing happened. So an invariance claim —
  *"this change moved nothing"* — now also carries a **same-kind no-op** put through the
  identical measurement, whose observed effect is the largest movement that still counts as
  nothing. Fires on the known-affected case, stays quiet on the no-op; either control alone is
  decoration. A "no difference" with no floor under it has a threshold too — unstated, and
  chosen after the fact.
- **Run labels, attached when a run is queued and never when it lands** — `pre-specified`,
  `confirmatory`, `exploratory` — as part of the append-only ledger row, so a label cannot be
  revised in the direction of the result. Only the first two can support a headline claim; an
  exploratory run produces a hypothesis for the next pre-specification, which is a reason to
  write a contract rather than evidence for the current one.
- **Name the level you measured at.** Configuration, design, and the realized result are three
  different levels, and evidence at one does not transfer to another: a setting present in a
  config file is not a design that used it, and a design is not a result that reflects it. Say
  *"the fitted output reports X"*, not the level-ambiguous *"the analysis uses X"*. Checking the
  convenient level instead of the computed one is how an artifact passes every structural layer
  while the claim resting on it was never measured at all.

### Added — contracts and references

- **Four laws close the last mile of `research-agent-laws.md`.**
  **18 — a count is a computation, not a reading:** every number a decision or a reader rests
  on is produced by a command whose output *is* the number, and is reported together with that
  command; a figure taken off a scrolled buffer is a guess wearing a count's precision. Scoped
  on purpose — it binds published and gating numbers, not every figure in conversation.
  **19 — name the state you actually reached; never a later one:** *modified*, *verified*,
  *committed*, *pushed*, and *integrated* are five different states, and claiming a later one
  than you reached is the whole defect. Where a task ends belongs to its contract; only the
  honesty of the report belongs to the law.
  **20 — history operations normally start from a porcelain-clean repository**, and an
  exception is an explicit override *reported as an exception* — mechanised by the guard above,
  within the boundary that entry now states.
  **21 — delegated screens run under a written rubric, and waves are adjudicated whole:** the
  default verdict is a **declared decision, not a constant** — EXCLUDE where a false include is
  the error you could still catch later, never on a recall-first sweep, and NEEDS-HUMAN where
  neither error is recoverable — with per-candidate evidence, a re-check whose sampling method,
  sample size, tolerated disagreement rate and escalation are fixed **before** the screen runs,
  and verdicts joined to candidates by id. Early returns are *status*, not input.
  **These wordings were corrected mid-release, and the correction leads.** Laws 19 and 21 were
  drafted in this branch as *"done" is a state of the repository — committed and pushed, and
  only then reported* and *EXCLUDE as the default verdict*, and an external referee falsified
  both before the release shipped. Requiring every task to end pushed breaks a collaborator who
  asked for a working-tree diff to review, a contributor without push rights, and anyone
  offline — so the law now governs the honesty of the claim, not where the work stops.
  EXCLUDE-by-default inverts on a recall-first screen: it silently drops relevant evidence, and
  unlike a bad include, nothing downstream ever surfaces the loss. Law 20's flat *"start from a
  clean tree"* was narrowed for a third referee finding, on what a pre-execution check can
  establish at all. The wordings above are the ones that shipped; earlier drafts survive
  nowhere but in this paragraph.
- **`templates/executor-contract.md`** — the dispatchable contract for delegated work: the goal,
  the acceptance bar, exact paths, the gates the result must pass, the output contract, and the
  mechanisms the executor is allowed to refuse. State the bar; never the implementation.
- **`templates/screening-rubric.md`** — the screening rubric whose **default verdict is a
  declared decision, not a constant**: EXCLUDE on a precision-first shortlist, never on a
  recall-first sweep, NEEDS-HUMAN where neither error is recoverable — with the adjudication
  table and the dispatcher spot-check that keep a delegated screen from drifting into an
  opinion poll with citations.
- **`.claude/references/release-engineering.md`** — shipping research software as an artifact:
  user-facing message and silent-resolution censuses (census first, rewrite second), frozen
  feature matrices for ports and reimplementations, inherited tests claimed **by name and by
  hash**, release preflight archives built from `git archive` rather than the working tree,
  downstream consumers pinned by commit SHA, and status contracts that are generated rather
  than written.

### Changed

- **Simulation studies declare an assumption regime.** `simulation-conventions.md`,
  `/simulation-study`, and the `sim-reviewer` agent now require a per-script header naming the
  estimand, **every** maintained assumption, the **single** assumption this run relaxes and how
  severely, and how correct specification was **verified** rather than asserted. Behind it: a
  firewall — a within-assumption claim may not cite an out-of-assumption run — and
  relax-exactly-one over a severity grid, because two relaxations at once make a failure
  unattributable.
- **The passport gains `appears_in`, and reproducibility becomes two-directional.** Every
  artifact that displays a number is declared, and all declared displays must agree at the
  coarser display precision. A declared display that cannot be located resolves to **FAIL**; a
  claim with no `appears_in` is reported **horizontally unchecked**, not silently clean. The
  vertical check passes contentedly while a deck quotes last month's value — only the
  horizontal one catches that. Wired through the whole loop: `claim-reconcile.py` nudges when a
  declared display is edited (naming the *siblings* that were not), `nightly-repro-check.sh`
  marks a claim **STALE** when any display is touched after `last_verified_on`, and `/commit`
  triggers the passport read on a display diff as well as a script diff.
- **Oracle transcripts are archived in-repo**, under
  `quality_reports/oracle_audits/YYYY-MM-DD_topic/` — committed, unlike the session-log and plan
  subdirectories that `.gitignore` excludes — so that any claim resting on an external consult
  cites the archived transcript rather than "the oracle said", recalled from a session that has ended.
- **`/checkpoint` gains an in-flight slot.** Anything the session started and did not wait for —
  a long compute job, a scheduled routine, a queued render, a review still out with another
  model — is recorded with four things: what is running, where its artifacts land, the command
  that checks on it, and the verdict that ends it. A checkpoint silent about running work hands
  the next session a false picture of what is finished.
- **`/commit` subject lines state what is true *after* the commit** — a plain claim a reader
  could go and test, not a narration of the afternoon. Process detail (which review round, how
  many attempts) belongs in the body if it belongs anywhere.
- **`/coauthor-brief` labels every status `measured` or `inferred`**, and *measured* must name
  the command that produced it. Both belong in a brief; mixing them silently does not, because
  the reader cannot tell which claims they can build on without re-checking all of them.
- **`/blast-radius` follows a change across repositories.** A consumer in another repo pins this
  one by commit SHA, so a change that moves a number the downstream reports is **not finished
  when this repo goes green**: before/after evidence for what moved, regeneration of the
  downstream artifact, and the re-pin all belong to the *same* round as the change. A downstream
  left pinned to the old SHA is an honest, inspectable state; one pointed at a moving reference
  silently inherits a number nobody re-verified.

**Inventory at release: 60 skills, 18 agents, 37 rules, 8 hooks, 10 gates**
(was 60 / 18 / 36 / 7 / 8 at v2.5.0).

### Removed — the methods veto, extended

The v2.5 veto on unvetted difference-in-differences content is **extended to empirical causal
methods generally** — regression discontinuity, synthetic control, instrumental variables,
event studies, and matching-as-identification. The reason is the owner's and is unchanged:
strong claims about how to run a method do not ship without the owner's current sign-off, and
that sign-off is not available now.

Removed: the design-specific fork sections of `/challenge`'s fork catalogue and the
corresponding sections of its sensitivity-statistics catalogue — Rosenbaum Γ went with them,
matching being the same class — the matching rows of `/challenge`'s sensitivity table, the
named-statistics list at rung 4 of `verification-ladder.md`, the IV and matching/RD peeves in the
`editor` persona, and the methods referee's first-stage-F blocker.

Re-domained rather than removed, because the pedagogy was never about the method: the
`/diagnose` worked example, the `/coauthor-brief` sample entry, the `/research-ideation`
identification template, two `/vaccinate` defect seeds, the preregistration template's estimator
menu, and the Chain-of-Verification examples — which now carry a synthetic citation rather than
multiplying claims about a real paper's contents.

What remains is the standard, written down: neutral taxonomy (method names as category lists),
journal- and field-content descriptions, canonical-package pointers conditional on the user's own
prior choice, citations to the owner's published work, explicit decline-to-judge stances, and
historical records, which are not rewritten — a past entry may be superseded or extended, never
quietly restated. Where a catalogue section was removed, a one-line
note stands in its place; where a single named list was cut (rung 4 of the verification ladder),
the surrounding text now points to the statistics canonical in your own design's literature —
either way the absence is visible rather than mysterious. The ruling is
recorded in `.claude/rules/meta-governance.md` (2026-08-23) and the lesson extended in
`MEMORY.md`. Method **diagrams** — the `did-two-period` and `event-study` TikZ snippets — are
drawings, not usage guidance; they are kept, flagged for a later ruling.

### Verification of this release

Three independent kinds of review ran against this branch, and **each found defects the other
two could not.** That is the finding worth carrying forward: no single method was sufficient,
and the one that mattered most was the one that asked a different question.

**The adversarial rounds** — fresh-context lenses, refute-biased verification of every finding,
fix, re-audit — drove the mechanical surface. They were good at what they were pointed at: counts
recomputed from source, links, staleness, guard bypasses. Twice the defect a round found was one
the *previous* round's own fix had introduced, and once a round's fix had disclosed a residual
list that was itself wrong about what it had missed — which is the argument for re-auditing in
fresh context rather than trusting a fixer's report of its own work. Two findings are worth
naming because the class generalizes. A guard folded a path's parent segments by string while the
tool it guards folds them through the kernel; the two agree until a symlink sits in front, and
then they name different repositories — so the guard read one tree and the command changed
another. And a docstring enumerating the redirection spellings a guard catches drifted from the
code in *both* directions at once: it listed four, the regex already caught a fifth nobody had
written down, and the shell accepts a sixth that neither had. Both were found by running the
command, not by reading the code — and the second is the concrete cost of the open debt this
release records, that nothing gates a docstring against the code it describes.

**The guards catch the direct forms, and not every spelling of them.** A path can be written many
ways that all reach the same file — a glob, a different case on a case-insensitive filesystem,
a quote or a backslash sitting inside the name, a variable, a command substitution. Successive
review rounds each turned up another one, which is what a text scan over shell syntax is like:
useful, and not a closed set. Both guards' residual lists say plainly which forms they have been
tested against and that there are others; they are not an enumeration of everything that exists.
We are not trying to catch every spelling, and nothing here should be read as claiming to.

One distinction is worth keeping, because it changes what a fix can do. Most of those forms are
just *text*: the information is in the command line, so a scanner can be taught to read it. A
symbolic link is not — it is a fact about the filesystem, and reading the command line cannot
recover it. So that one is written down as out of reach rather than chased. What the guards buy
is that the ordinary accident costs a denial; if you need a guarantee, the mechanism has to be
something other than a text scan.

**The template's own skills, run against the template**, found what those rounds structurally
could not — the rounds asked *"is this correct?"*, never *"what does this do to a user?"*
`/blast-radius` reproduced, end to end using this guide's own worktree recipe, that a gate added
by this release **committed to the user's branch and then blocked every retry**: git exports an
absolute `GIT_DIR` into hooks from a linked worktree, and `git -C` does not isolate against it.
The same defect meant a block of battery cases had been passing by reading the *outer*
repository — green for the wrong reason — so they were re-qualified rather than assumed.
`/verify-claims` measured that the story motivating gate 9 was false: a mistyped hook path does
not fail silently. `/humanize` found the release's own teaching illustrations were one template
run five times.

**An independent frontier-model referee returned HOLD.** Its lead finding was reachable by
neither of the above: the clean-tree guard read the tree at `PreToolUse`, *before* the shell
command ran, so a command that dirtied the tree and then ran a history operation was allowed.
Every internal round had tested chains in one direction only. The release was paying the guard's
full usability cost while the guarantee it advertised did not hold in the direction that
mattered. Its findings were reproduced against real git before being accepted, and every one is
answered — including several where the right response was to *delete* a claim rather than soften it. The consult is
archived at `quality_reports/oracle_audits/2026-08-23_v2.5.1-guard-design/` with the prompt as
asked, the answer unedited, and a bound on its coverage stated by the referee itself: it read the
guards' documented design, not their source, so it is evidence about what the design claims and
not about whether the code matches.

**Claims withdrawn rather than softened.** A release that argues for verification should say
plainly what it got wrong:

- *"No textual feature of the command can make a dirty tree read as clean"* — falsified in
  review; the guard identifies forms, and an unidentified invocation passes outside the rule.
- *"A closed allowlist over the whole command"* — it is a best-effort recognizer.
- *"One extra keystroke"* — it is another tool call, hook cycle and round trip.
- *`reflog`/`ORIG_HEAD` backstop a bad merge* — they recover **commits**; this protects exactly
  what is not committed.
- *Law 19: every task ends pushed* — deleted. A collaborator who asks for a working-tree diff
  completes their task.
- *Law 21: EXCLUDE is the default verdict* — deleted for a recall-first screen, where it
  silently drops relevant evidence and nothing downstream ever surfaces the loss.

**Qualification.** Every gate carries a row in `quality_reports/qualification/LEDGER.md` with the
defect classes seeded, recall, false-positive rate against a clean control, and a reproduction
command. The hook battery is itself graded: stubbing each guard to always-allow must turn it red,
and the per-guard **section tallies** are recomputed from the battery's own source by a
gate. The stub OUTCOMES are recorded as dated measurements carrying their reproduction
command, not gated — which guard *decides* a case is a runtime property, and the two
guards share a deny list by import, so no static read of the test file recovers it. Each fix in
this release was qualified in both directions — reverted in a copy to confirm its own cases go
red, and run against the clean control to confirm no others do.

**Disclosed rather than claimed closed.** The guards are defense-in-depth over a deliberate
bypass posture, not proofs, and each docstring names what it cannot see. One seam is left open
and recorded, and it is narrower than an earlier draft of this section said: the destructive-verb
deny list is now **shared** across the two hooks, so a `reset --hard` or a `clean -fdx` carried
inside a shell payload is caught. What is not shared is the **dirty-tree** check, so a merge,
rebase or pull inside such a payload is still seen by neither hook. That half stays open on
purpose — it needs a resolved repository and a live `git status`, and duplicating
repository-identity resolution is exactly the surface review showed was wrong twice.
The referee's preferred design, a trusted runtime wrapper, was consciously deferred in favour of
its own cheaper fallback. Nothing gates a docstring against the code it describes; that is
recorded as open debt, and it is how the redirection defect above survived. And this prose is
model-drafted: `writing-with-ai.md` is explicit that no model pass changes what a neural detector
sees, so the only real measurement is a detector run against the rendered guide.

### Provenance

This release was driven by a banked, adjudicated audit (2026-08-23) that asked one question of
the owner's research repositories: which disciplines those projects developed in practice have
**not** been incorporated here? Insights were banked to disk before any of them was acted on,
the wave was adjudicated once and whole rather than first-return-first, and every candidate gap
was confirmed against the template on disk before it earned a change. The confirmed gaps
clustered; the highest-severity clusters drove the enforcement and fencing work above —
meta-gating the qualification ledger, testing the hooks instead of trusting them, fencing the
reviewers, declaring the assumption regime, horizontal claim parity — while the same audit's
lower-severity findings account for the contract, reference, and last-mile-law additions. The
clusters left unaddressed are recorded rather than quietly dropped. The changes then went
through the template's own adversarial review loop — fresh-context lenses, refute-biased
verification, fixed and re-audited until dry — before release.

---

## v2.5.0 — 2026-08-23

### Removed — `/did-event-study` (owner veto, 2026-08-22)

The staggered-DiD pipeline skill is **removed**. The owner — whose own methods it drove — has
not vetted its current content, and **methodological prescriptions in the owner's field do not
ship without the owner's current sign-off**. A recorded sign-off from an earlier version does
not transfer to later content. Estimation is driven through the canonical packages directly
(`did`/`DRDID`/`HonestDiD` in R, `csdid`/`drdid`/`honestdid` in Stata). The veto applies to
ALL unvetted DiD-prescriptive content, removed in the same release:
the `did-conventions.md` rule, the staggered-DiD sections of `/challenge`'s fork catalogue,
the honest-DiD entry in its sensitivity-statistics catalogue, the two DiD eval cases, the
tracked validation report `quality_reports/did_validation.md`, the pre-trends prescriptions
baked into the editor / referee personas and worked examples, the citation-metadata claim of
a "validated DiD/event-study workflow", and
every one-line echo of those prescriptions in the references, guide, and landing page. What
remains says only: use the canonical packages and the owner's published work. Eval
measurements are preserved in the qualification ledger as records, annotated.


A **verification and currency release.** The substrate moved underneath the template over ten
weeks — a tool was renamed, two model generations shipped, and a fixed upstream bug left a
stale blocker in the backlog — while every gate stayed green. v2.5 fixes the facts, and then
fixes the reason the gates did not notice.

### Fixed — the tool that no longer exists

- **`Task` → `Agent`.** The subagent-spawning tool is `Agent`; `TaskCreate`/`TaskGet`/… are the
  unrelated agent-teams task-list tools. Migrated across **33 skill frontmatters** and 20 files
  of body prose, using **dual listing** (`Agent` *and* `Task`) so forks on older Claude Code
  keep working. The `PostToolUse` matcher `Bash|Task` — which had silently stopped firing on
  subagents — is now `Bash|Agent|Task`.
- **`check-skill-integrity.py` generalized** beyond its hard-coded `Task` check. It immediately
  found a real defect the `Task`-only version could not see: `/new-skill` invoked `Agent`
  without declaring it.

### Fixed — model currency, and the gate that missed it

- **SSoT → Opus 5 / Sonnet 5** (Fable 5 remains the top tier), with the **provider-dependent
  alias table** (Bedrock and Google Cloud resolve `sonnet` to Sonnet 4.5; Microsoft Foundry
  resolves `opus` to Opus 4.6) and a **60-day expiry**.
- **Consuming surfaces made tier-abstract** (“the Opus tier”, not a point version) so they
  cannot drift again. The guide's model paragraph now points at the SSoT instead of restating it.
- **`check-model-versions.sh` tightened.** Its `GA 2026-0` allow-marker was whitelisting *any*
  line that carried a GA date, which is how two stale guide lines passed. Removed, and the
  **line-scoped nature of allow markers** is now documented in the gate as a known limitation.

### Fixed — stale recommendations

- `meta-governance.md` claimed MEMORY.md **“stays in Claude's system prompt.”** It does not —
  there is no `@MEMORY.md` import. Corrected, with the consequence stated.
- Plugin packaging was deferred on `anthropics/claude-code#11278`, **closed 2025-11-09**.
- Two `[LEARN:framing]` entries that v2.0 superseded and nobody retired (orchestrator “pattern,
  not a runtime”; “quality gates advisory only”) marked **SUPERSEDED**, with what still holds.
- **Auto mode** is no longer plan-gated: since 2026-08-14 it is the default starting mode for
  new Pro/Max/Team sessions.
- The **Fable routing rule** is flagged **stale, needs re-measurement** — it rests on a
  launch-week observation from June that predates Opus 5.

### Added — the verification layer

- **`/vaccinate`** — grade the grader. Seeds known defects plus a **clean control**, runs the
  check or review agent blind, and reports **recall** and **false-positive rate** into
  `quality_reports/qualification/LEDGER.md`. Ships a **defect library** of realistic seeds by
  artifact type. The rule it enforces: *an unqualified check is not weak evidence — it is none.*
- **`verification-ladder.md`** — seven rungs from *qualify the checker* to the external oracle;
  the four-layer artifact ladder (existence → **substantiveness** → wiring → coherence); the
  three independence mechanisms; the specification-search ledger; and how the loop converges
  (**batch the fixes, then one confirmation round** — not one-finding-per-round).
- **`external-oracle-process.md`** — the full Claude Code → **GPT-5.6 Sol Pro** process: setup,
  invocation, artifacts, the **evidence-forcing prompt contract** (location + quote + *failing
  case*), the **coverage manifest**, the **HELD list**, **CONFIRMED / REFUTED / DOWNGRADED**
  adjudication, and the hard-won mechanics. With the limit stated as loudly as the appeal:
  *agreement is not confirmation; models correlate on the same wrong answer.*
- **`provenance-and-ground-truth.md`** — naming oracles with roles and **pinned commit SHAs**,
  declaring **precedence before measuring**, the **divergence-kinds taxonomy** (not every
  difference is a bug), the tolerance registry and the `all.equal` scale trap, the
  **never re-bless in the commit that moves it** rule, and the clean-room boundary.
- **The five credibility questions** — reproducibility ≠ implementation fidelity ≠ statistical
  performance ≠ measurement validity ≠ identification. Evidence for one never clears another.

### Added — enforcement

- **`scripts/check-links.py`** — every relative markdown link and heading anchor must resolve.
  Wired into the gate suite, so pre-commit and CI both run it. It found **8 broken references**
  on first run, including that *every* relative link from the guide to a repo file 404s on the
  published website. Guide links to repo files are now GitHub blob URLs.
- **`disallowed-tools` on 9 read-only skills.** `/proofread`, `/review-r`, `/visual-audit` and
  friends keep `Write` (for their report) but can no longer `Edit` the artifact they were told
  to only report on. Previously nothing stopped them.
- **Frontmatter conformance.** Audited continuously by the `check-spec-conformance` gate — all 60 skills at release — against the
  [Agent Skills spec](https://agentskills.io/specification): names, description length, and
  the 500-line body guidance all pass (median body: 121 lines). `author`/`version` — read by
  neither the spec nor Claude Code — moved under `metadata:`.

### Added — scheduling guidance that changes a recommendation

`scheduled-routines.md` gains the **three-mechanism decision table**. The consequence for
research: a cloud routine runs against a **fresh clone with no local file access**, so a
nightly reproducibility check on local — or restricted — data belongs in **Desktop scheduled
tasks**, not cloud routines.

### Verification of this release

Every one of the **eight** gates was qualified with seeded defects and a clean control, and
each carries a row in `quality_reports/qualification/LEDGER.md`. The composite stress test —
10 seeded defects spanning six gates in one pass, 10/10 caught, 0 false alarms — is recorded
there too, alongside the per-gate seedings for the remaining two (spec-conformance:
empty-description seed; derived-counts: wrong journal/phase/snippet/gate-count seeds).

Three gates caught this release's own work before it shipped, and two external Codex review
rounds (4 + 4 findings) were adjudicated with every finding reproduced before being acted on —
7 confirmed and fixed, 1 refuted with line evidence. A 14-component adversarial workflow audit
(85 agents, refute-biased verification) then confirmed 63 further defects, all fixed in this
release; its full findings are preserved in the qualification ledger's audit note.

And one finding worth more than the fixes: **rebuilding the landing page silently removed it
from gate coverage.** Every gate stayed green because the page was no longer being *matched*.
A gate that matches nothing reports nothing. Caught by seeding a defect into that specific
surface; coverage restored and re-proved. A falling assertion count is now documented as the
signal to investigate.


### Added — the laws from the working machine

`research-agent-laws.md` — 17 laws for running agents on research infrastructure, each paid
for by a real incident, cross-referencing rather than restating what is already mechanised.
Three wired into mechanisms: **parallelism must be provably run-shape-independent** (seed by
task, not worker; prove it with a two-core vs four-core bit-identity check — worker-based
seeding silently binds results to the execution shape), the **five-question memory capture
gate** with a ban on just-in-case memories, and **push-on-failure / silence-on-success** for
routines, where *did not run* is a failure rather than silence.

### Added — writing

- **`writing-with-ai.md`** separates two problems that get conflated: **readability** (editing
  fixes it, worth doing whoever wrote the text) and **provenance** (only human rewriting fixes
  it). An article polished through several rounds of surface de-AI-ing came back from a neural
  detector at **100 % AI-written** — those classifiers read the token-level statistics of LLM
  generation, which survive any transformation the model applies, *because every transformation
  is still LLM-generated text*. **A model cannot make its own output stop reading as model
  output.** Plus the internal-vs-external-facing decision and the human-readable standard.
- **`/humanize` scope narrowed** accordingly: a clean report means the prose reads *well*, not
  that it reads *human*.
- **`/voice-profile`** — the positive counterpart, deferred since v1.9. Extracts a voice profile
  from your own prior papers using one subagent per document, and audits drafts against it.
  `/humanize` now reads it and stops flagging documented quirks as AI tells.

### Added — from a usage-insights review of 14 sessions / 367 hours

- **`agent-authored-code.md`.** The top friction was buggy code, and most of it was written by
  the agent during the session rather than found in the codebase: bulk transformations run
  without a dry run, paths resolved after a `cd`, `pgrep` monitors matching themselves so a
  chain waits on itself, long runs with no heartbeat. *A bulk edit is not done when the script
  exits 0; it is done when you have read a sample of the result.*
- **Scope Discipline** at the top of `CLAUDE.md` — do exactly what was asked; list adjacent
  ideas as suggestions instead of implementing them.
- **`/diagnose` gains contract-first triage and an audit/repair split.** State the documented
  contract and whether the reported scenario is even *in* contract before writing anything;
  Phase 1 is read-only with `UNVERIFIED` marked, Phase 2 repairs only approved rows.
- **`pdf-processing.md` extended for corpora.** The rule was right for one paper and does not
  scale by multiplication; more than two or three documents means one subagent per document.

**Inventory at release: 60 skills, 18 agents, 36 rules, 7 hooks, 15 references, 8 gates**
(was 52 / 18 / 32 / 7 / 9 / 3 at v2.1.0).

### Changed — external Oracle referee review adopted (2026-08-22)

An independent GPT-5.6 Sol referee run over the full guide (34 min, complete coverage
ledger) returned 28 findings and 15 suggestions. Adjudication: 26 findings confirmed and
fixed (including a safety-relevant false claim that bypass mode still prompts on protected
paths — current docs say it does not), 2 refuted against the official docs (auto mode IS
the Pro/Max/Team default; /checkpoint does not collide with a built-in). High-value
suggestions adopted: adoption ladder, enforcement-contract matrix, pattern pathways,
red-then-green demo, git survival kit, data-license decision steps, claims legend, typed
replication tolerances, and two new staleness checks (guide-version parity, reversed
injection syntax). Remaining suggestions dispositioned in `v2.0-backlog.md` under the
owner's two rulings: no further session-time enforcement hooks, and no prescriptive
empirical-practice content without explicit sign-off.

### Upgrading from v2.1

1. Pull, then run `./scripts/install-hooks.sh` if you have not already — the gate suite now
   includes the link checker.
2. If you customized skill frontmatter, note that `allowed-tools` now lists **both** `Agent`
   and `Task`. Keeping a stale `Task`-only entry is harmless (it is a pre-approval list, not a
   restriction) but you lose pre-approval on subagent calls.
3. If you customized `guide/workflow-guide.qmd`, expect conflicts — repo-file links moved to
   GitHub blob URLs.

---

## v2.1.0 — 2026-06-10

A **currency + citability release**, driven by a 48-agent web-verified audit ("is this actually up to date and the best for economists, today?"). The architecture audit came back clean — the fixes are facts, not structure.

### Changed — model refresh (Fable 5)

- **`model-versions.md` SSoT** — Claude **Fable 5** (GA 2026-06-09) added as the top tier: `claude-fable-5` (alias `fable`), opt-in, $10/$50 per MTok, 1M context, falls back to Opus 4.8 on flagged content, needs Claude Code ≥ 2.1.170. Opus 4.8 demoted from "newest" to "current Opus tier; API/account default". Marker, table, and verified-date updated per the file's own protocol.
- **`model-routing.md`** — new section "Where Fable 5 fits — and where it does not": the fleet deliberately stays on Opus/Sonnet/Haiku (2× price on the judgment tier + launch-week forced-tool-protocol failures observed at 28/28 vs 0 on Opus 4.8); Fable 5 recommended only for interactive long-horizon sessions. Re-evaluate at point releases.
- **`check-model-versions.sh` hardened** — version regex generalized (`4.x` → any `major[.minor]`, so bare "Fable 5" is tracked), Fable added to the tier loop, and a new **superlative-drift check** (flags "newest/most capable" claims naming a non-top tier) — the exact class of claim the Fable launch falsified while the old gate stayed green. SSoT update protocol gains a manual superlative-grep step.
- README model-lineup bullet rewritten (Fable 5 = most capable, Opus 4.8 = default + routed tier); CONTRIBUTING's Co-Authored-By example made version-free.

### Fixed — Claude Code doc currency (3 real bugs)

- **`scheduled-routines.md`**: the `/schedule` example used a **fabricated flag syntax** (`--cron/--prompt`) — replaced with the real natural-language form + `/schedule update` for precise cron, the 1-hour minimum interval, the daily run cap, and the committed-repos-only constraint. The MCP guardrail was **inverted**: cloud Routines include **all connectors with write access by default** (the risk is a fully-armed connector, not a missing one) — rewritten to least-privilege guidance.
- **`templates/skill-template.md` + guide**: `allowed-tools` was taught as a restriction; per current docs it is a **pre-approval list** ("does not restrict which tools are available: every tool remains callable"). The actual restrictor is **`disallowed-tools`** — now documented, with a read-only-skill pattern (`disallowed-tools: ["Edit","Write","Bash"]` + `AskUserQuestion` for unattended loops) and new `paths` / `when_to_use` / `arguments` rows. Security note rewritten; guide gains an "`allowed-tools` does not sandbox" warning callout.

### Added

- **`/submission-disclosures`** — the submission-time disclosure block: **AI-use disclosure** matched to the target journal's *verified-current* policy (fetched at draft time, not remembered), CRediT roles, COI, and data-availability statements. Two independent audits flagged this as the most economist-salient 2026 norms gap (AEA-family journals now mandate AI-use statements). Distinct from `/disclosure-check` (statistical disclosure).
- **`CITATION.cff`** — the repo is now citable (GitHub "Cite this repository"); Zenodo DOI is a follow-up (backlog).
- **`.github/SECURITY.md` + `.github/CODE_OF_CONDUCT.md`** — community-health files a public template shipping hooks + autonomous loops should have.
- **GitHub discoverability** — repo topics (was: zero) + homepage URL set.

**Inventory at release: 52 skills, 18 agents, 32 rules, 7 hooks** (was 51 / 18 / 32 / 7 at v2.0.0).

---

## v2.0.0 — 2026-06-09

A **paradigm-shift major release.** The template moves from a *prompt-craft contractor* — craft a prompt, invoke a skill, read a report — to a **verification-gated research lab**: you state a goal, a fleet of specialist agents does the labor under **gates that enforce themselves**, and you act as the **auditor of the disagreements they surface**. Two ideas converge: *"loops, not prompts"* (Boris Cherny / the Claude Code team) and *"ground truth is a process, not a dataset"* (Amazon Science). The result modernizes the **orchestration**, not the substance — the passport, simulation contract, and journal-calibrated referees are untouched. Shipped against `quality_reports/plans/2026-06-09_v2.0-modernization-master-plan.md`.

### ⭐ Why upgrade — read this even if you've used the template before

If you forked v1.x, here is what is *materially different* now (one-stop summary):

| Before (v1.x) | Now (v2.0) |
|---|---|
| Quality gate ran **only inside `/commit`** — a direct `git commit` bypassed it | A real **git pre-commit hook** (`./scripts/install-hooks.sh`) runs surface-sync + quality (≥80) on **every** commit |
| The review loop was *"a pattern, not a runtime"* — prose a human triggered | A **real runtime**: fan-out → reduce → judge **+ hallucination gate** → **loop-until-dry** (`orchestrator-protocol.md`) |
| A numeric mismatch was always a **FAIL** (so people disabled the gate) | A defensible, **named** alternative is recorded as **`EXPLAINED`** and flows into your response-to-referees; real errors stay fail-closed |
| Hooks **nagged** ("you should update the log / compile") | Hooks **act**: the Stop hook **auto-writes** the session log; `git-guardrails` **blocks** destructive git; `claim-reconcile` flags stale claims the moment analysis changes |
| 17 of 18 agents ran on `model: inherit` (cost savings unrealized) | Every agent **pinned** to model + effort (Opus referees / Sonnet reviewers / Haiku mechanical) |
| You **audited** reproducibility | You **produce** the deposit: `/replication-package` builds the AEA DCAS / openICPSR package |
| Onboarding said *"paste this starter prompt"* | Onboarding is **goal-first**; the `/prompt` and `/prompt-only` skills are retired (shaping is now ambient) |

**If you do only one thing after pulling v2.0:** run `./scripts/install-hooks.sh` to activate the pre-commit gate.

**Inventory at release: 51 skills, 18 agents, 32 rules, 7 hooks** (was 38 / 18 / 28 / 6 at v1.10.0). Net: +15 skills, −2 retired; +4 rules; +2 hooks, −1 retired. New: 9 references (3 added), 2 output-styles, CI.

### Added — economist "producer" skills (the biggest gold-standard gap)

- **`/replication-package`** — assembles a submission-ready **AEA DCAS / openICPSR** deposit: standard README, dataset manifest, computational-requirements capture, a Table/Figure → `script:line` map (from the passport), and a confidential-data deposit note. Gates on `/audit-reproducibility` (blocks on FAIL, allows EXPLAINED). *Move from auditing reproducibility to producing the deliverable.*
- **`/capture-environment`** — snapshots the computational environment: `renv.lock` + `sessionInfo` (R), `requirements.txt`/`uv.lock` (Python), Stata version + ado list, seeds/RNG, and an optional pinning `Dockerfile`.
- **`/did-event-study`** — a **thin wrapper** over canonical staggered-DiD packages (Callaway–Sant'Anna `did`, Sun–Abraham `fixest::sunab`, HonestDiD; Stata twins) that surfaces each package's *native* diagnostics and **never reimplements an estimator**. Warns on the never-treated vs not-yet-treated control choice (the contested decision the EXPLAINED disposition exists for).
- **`/power-analysis`** — power / required-N / MDE for two-arm RCTs (clustering/ICC), multi-arm, and simulation-based designs; feeds `/preregister`.
- **`/disclosure-check`** — statistical-disclosure-limitation pre-screen for restricted-data outputs (small cells, dominance, PII); gates on CRITICAL.
- **`/grant-proposal`** + **`/data-management-plan`** — compose the confidential-data + environment-capture primitives into NSF/NIH/ERC-shaped drafts + requirements checklists.
- **`/coauthor-brief`** — a collaborator/multi-machine handoff brief (git delta, per-artifact state, reproduce-locally + restricted-data access steps).
- **`confidential-data.md` rule** — restricted/IRB-data protocol (never commit raw data; disclosure clearance; restricted-data-safe multi-author git topology). **AEA Data Editor / DCAS policy** added to `journal-profiles.md`.

### Added — teaching-at-scale (the repo's origin, previously a blind spot)

- **`/syllabus`**, **`/teach-from-paper`**, **`/respond-to-eval`** (the teaching analogue of `/respond-to-referees`), and **`/scaffold-exercises`** (graded problem sets with worked solutions + explainers, adapted from `mattpocock/skills`).

### Added — autonomy, runtime, and authoring

- **Real orchestration runtime** — `.claude/references/orchestration-schemas.md` (the `FINDING`/`SCORECARD`/`RUN_CONFIG` contracts + the post-judge **hallucination gate**) and `agent-fleet.md` (the 18-agent manifest with tiers). `orchestrator-protocol.md` rewritten from *pattern* to *runtime*.
- **Event-driven + scheduled autonomy** — `claim-reconcile.py` (flags stale numeric claims when an analysis script/output changes), `.claude/references/scheduled-routines.md` + `scripts/nightly-repro-check.sh`, and **`/triage-inbox`** (schedulable, human-gated email/calendar triage + referee-obligations tracker).
- **`/new-skill`** — scaffolds a convention-compliant skill that passes `check-skill-integrity` on the first try (adapted from `mattpocock/skills`' write-a-skill).
- **`/diagnose`** — root-cause a wrong/failing empirical result with a disciplined **reproduce → minimise → hypothesise → instrument → fix** loop (the net-new idea from a fresh pass over `mattpocock/skills`, reshaped for research code where the bug is usually a *silent wrong number*, not a crash; competing-hypothesis fan-out via `Task`, `--no-fix` to localize without editing).
- **Output styles** — `.claude/output-styles/academic-writing.md` and `referee.md` (the template shipped zero before).
- **CI** — `.github/workflows/gates.yml` (surface-sync + integrity + model-version checks on every PR) and `deploy.yml` (re-render the guide → `docs/` on push to `main`).
- **Enforcing pre-commit hook** — `.githooks/pre-commit` + `scripts/install-hooks.sh` (opt-in via `core.hooksPath`).
- **`git-guardrails.py`** (PreToolUse) — blocks `git reset --hard`, `git clean -f`, `git push --force`, and blanket `git add -A`; warns on hardcoded machine paths in code (`CLAUDE_STRICT_PATHS=1` to hard-block).
- **Table-row sync gate** — `check-surface-sync.py` now verifies that the enumerative skills/agents *tables* (not just prose counts) carry one row per item on disk — the drift that hid the v1.5.0 peer-review trio for three releases.

### Changed

- **Verification 2.0 — "ground truth is a process."** `audit-reproducibility` and `claim-verifier` gain an **`EXPLAINED`** disposition: an out-of-tolerance numeric/citation mismatch stays a fail-closed FAIL **unless** the author records a *concrete named alternative* (e.g. "never-treated vs not-yet-treated comparison group"), in which case it is surfaced, non-blocking, and carried into the response-to-referees. The hard floor holds (fabricated citations, unmatched claims, vague notes never downgrade). `audit-reproducibility` also no longer presumes the manuscript is the oracle — a mismatch means "one of {paper, code} must change."
- **Loop-until-dry.** `qa-quarto`, `review-paper --adversarial`, `deep-audit`, and `seven-pass-review` converge when a round surfaces no new CRITICAL/MAJOR finding (2 dry rounds), with the old "max 5 rounds" demoted to a fallback cap; synthesizers run the **post-judge hallucination gate** (an editor can't desk-reject on a reason no referee raised).
- **Hooks act instead of nagging.** `log-reminder.py` now **auto-writes** a structured session-log entry on each meaningful change-set (was a stderr reminder). `pre-compact.py`'s DRAFT-plan block is **ON by default**. The statusline now shows context-% + dirty-file count + plan status.
- **Per-agent model routing realized.** All 18 agents pinned to `model:` + `effort:` per `model-routing.md` (9 Opus / 8 Sonnet / 1 Haiku).
- **Goal-first onboarding.** The README "How It Works" leads with *goal-first, gate-enforced*; the guide and landing page reframed accordingly. "Contractor mode" remains, augmented.

### Removed

- **`/prompt` and `/prompt-only` skills** — retired. Prompt-craft is 2023-era; a loop-first workflow shapes every ambiguous request automatically, so this is now the ambient **`prompt-shaping.md`** rule, not a command. (`prompt-formatting-core.md` re-pointed; `/interview-me` remains for multi-turn specification.)
- **`verify-reminder.py` hook** — retired. Its per-edit "compile reminder" is superseded by the Stop-hook completion note in the auto-writing session log.

### Upgrading (forkers pulling v2.0)

1. **`./scripts/install-hooks.sh`** — activate the pre-commit gate (the single highest-value step).
2. If you customized `/prompt` or `/prompt-only`, move that logic into your own rule or `/interview-me` — the skills are gone.
3. If you reference `verify-reminder.py` in a fork, remove it; the Stop hook (`log-reminder.py`) now writes logs.
4. Pin `model:`/`effort:` in any custom agents (`model-routing.md`), and re-run `./scripts/check-surface-sync.sh` after adding skills — it now checks table rows too.
5. No data migrations; the passport schema is backward-compatible (`EXPLAINED` is additive).

### Notes

- Count surfaces (README, CLAUDE.md, guide source + rendered HTML, landing page, skill template) updated to 51 / 18 / 32 / 7; `check-surface-sync.sh` (now including the table-row gate), `check-skill-integrity.py`, and `check-model-versions.sh` all pass.
- Explicit **non-goals** (documented, not omissions): no autonomous daemon, no plugin marketplace, no multi-estimator production fleet (one `/did-event-study` proof-of-concept), no challenger→auditor→ledger pipeline (the zero-cost `EXPLAINED` mechanism instead), `MEMORY.md` stays the committed memory backend.

---

## v1.10.0 — 2026-05-31

A **hub-expansion + currency-refresh** minor release. The template gains a Monte Carlo simulation capability and an R package-development release gate, refreshes the model / effort / cost guidance for **Opus 4.8**, and reframes itself as a hub for an entire research program — not just slides and papers. Shipped against the plan at `quality_reports/plans/2026-05-31_v1.10.0-simulation-and-hub.md` (local-only per the `quality_reports/plans/*` ignore rule). No breaking changes.

**Inventory at release: 38 skills, 18 agents, 28 rules, 6 hooks** (was 36 / 16 / 26 / 6 at v1.9.0). Adds 2 skills (`/simulation-study`, `/r-package-check`), 2 agents (`sim-reviewer`, `r-package-reviewer`), and 2 rules (`simulation-conventions`, `r-package-conventions`).

### Added

- **`/simulation-study` skill** (`.claude/skills/simulation-study/`) — scaffolds and runs a reproducible Monte Carlo study: a parameterized DGP, an estimator grid, a seeded replication loop (L'Ecuyer-CMRG streams for parallel reps), and a summary of bias, RMSE, empirical SE, coverage, and size/power — each reported with its Monte Carlo standard error. Mirrors `/data-analysis`; saves per-replication raw results + a summary table to `scripts/R/_outputs/`.
- **`sim-reviewer` agent** (`.claude/agents/sim-reviewer.md`) — a read-only reviewer for the simulation-specific layer that general R review misses: DGP↔estimand alignment, replication budget + Monte Carlo SE, coverage computed against the *truth* (not the point estimate), parallel-seed discipline, and claims↔tables parity. Builds on `r-reviewer` (Cat 9 error handling, Cat 11 numerical discipline) instead of duplicating it.
- **`simulation-conventions` rule** (`.claude/rules/simulation-conventions.md`) — path-scoped Monte Carlo discipline (the DGP/estimand contract, L'Ecuyer seeding, MCSE reporting, coverage-vs-truth, raw-result storage). Sibling to `r-code-conventions.md`; auto-loads only on simulation files.
- **`/r-package-check` skill** (`.claude/skills/r-package-check/`) — the R package release gate: regenerates docs (`devtools::document()`), runs the test suite, runs `R CMD check --as-cran`, triages every ERROR / WARNING / NOTE against CRAN policy, then runs `r-package-reviewer`. Produces a CRAN-submission checklist. Does not bump versions or submit.
- **`r-package-reviewer` agent** (`.claude/agents/r-package-reviewer.md`) — reviews package *source* (DESCRIPTION / dependency hygiene, NAMESPACE & imports, roxygen completeness, testthat coverage, CRAN-policy red flags). Builds on `r-reviewer` (general numerical discipline) instead of duplicating it.
- **`r-package-conventions` rule** (`.claude/rules/r-package-conventions.md`) — path-scoped package-source standards (no `library()` in `R/`, roxygen-generated `NAMESPACE`, Imports vs Suggests, testthat 3e, CRAN-policy red flags, semver + NEWS). `r-code-conventions.md` now carries an explicit "analysis scripts, not package source" scope banner pointing here.
- **"One repo, many project types" framing** (README + landing page) — positions the template as a hub for courses, papers, replication, simulation studies, and the R package gate, with Stata/Python package checks and personal-productivity workflows on the roadmap (`.claude/references/v2.0-backlog.md`).

### Changed — Opus 4.8 currency refresh

Brings the model / effort / cost guidance up to date — every claim re-verified against official Anthropic docs on 2026-05-31:

- **Model lineup → Opus 4.8.** README, the guide (lineup callout + routing table + rendered HTML), `model-routing.md`, `TROUBLESHOOTING.md` (retirement migration target), `statusline.sh`, and the v2.0 backlog now lead with **Opus 4.8** (`claude-opus-4-8`, GA 2026-05-28, API default, $5/$25, 1M context) as the newest model; Opus 4.7 is named as the prior generation. Historical CHANGELOG entries are left intact.
- **Effort guidance.** **Opus 4.8 defaults to `high`** — its `high` does roughly what 4.7's `xhigh` did, for fewer tokens. The old "xhigh recommended for 4.7 / default to medium" framing is replaced with "`high` is the default; reserve `xhigh` for the hardest runs; `ultracode` (xhigh + dynamic workflows) for repo-scale autonomous tasks." `model-routing.md` gains a new **effort-axis** section (effort is the first cost lever, model tier the second).
- **Cost / cache.** Prompt-cache TTL framed correctly: 5-min default on API keys; **1-hour automatic on Claude Pro/Max subscriptions**. The 70/20/10 routing split is unchanged (Sonnet 4.6 / Haiku 4.5 remain the current tiers).
- **Auto mode.** Now described as on Team / Enterprise / API and rolling out to Max, gated on Opus 4.6+ or Sonnet 4.6 (was "Max + Opus 4.7").
- **Version pin** updated to `v1.10.0` (2026-05-31).

### Fixed — hook output channels, non-fatal scoring, + a model-version drift gate

- **`context-monitor.py` + `verify-reminder.py` were silent on the user side.** Both fire on `PostToolUse` and `print()` plain ANSI-colored text — which reaches Claude's context as literal escape-code noise and never reaches the **user** at all. Both now emit the proper PostToolUse JSON contract: a clean `systemMessage` (shown to the user) **and** `hookSpecificOutput.additionalContext` (injected into Claude's context), ANSI-free. Verified against the [hooks reference](https://code.claude.com/docs/en/hooks).
- **`context-monitor.py` calibration.** The old "context %" was a bare tool-call counter (`MAX_TOOL_CALLS = 150`) that cried wolf far too early against a 1M-token window. It now estimates tokens from the `transcript_path` size against `CLAUDE_CONTEXT_WINDOW_TOKENS` (default 1,000,000), falls back to a configurable counter (`CLAUDE_CONTEXT_MAX_TOOL_CALLS`, default 400), and labels the figure a coarse proxy.
- **New model-version drift gate.** `.claude/references/model-versions.md` is now the single source of truth for current model point versions, and `scripts/check-model-versions.sh` flags any superseded version presented as current in user-facing surfaces (historical CHANGELOG + "prior generation"/comparison lines are allowed via markers). Wired into `scripts/check-surface-sync.sh` as a third pre-commit gate, so the ~6-week model-staleness class that prompted this release can't silently recur.
- **`post-compact-restore.py` ANSI on SessionStart.** The post-compaction restore message printed ANSI color codes, which on `SessionStart` land in Claude's context as literal escape-code noise. It now emits a clean, ANSI-free message via the `SessionStart` `additionalContext` contract.
- **`quality_score.py` timeouts were fatal.** A `quarto render` (120s) or `Rscript` (10s) timeout returned the same as a real compilation failure → `auto_fail`, score 0, commit blocked. Timeouts (and a missing tool) are now a distinct **could-not-verify** state: the score reflects the static checks and the report notes which check was skipped. Both timeouts are env-configurable (`QUALITY_QUARTO_TIMEOUT`, `QUALITY_RSCRIPT_TIMEOUT`).

### Notes

- Count surfaces (README, CLAUDE.md, guide source + rendered HTML, landing page, skill template) updated to 38 / 18 / 28 / 6; `check-surface-sync.sh` passes.
- The entire audit **P0** (Opus 4.8 currency refresh, the two silent-hook fixes, the `model-versions.md` drift gate, the `post-compact-restore.py` SessionStart cleanup, and the `quality_score.py` could-not-verify fix) was folded into this release. The main remaining roadmap item is Stata/Python package dev — see `.claude/references/v2.0-backlog.md`.

---

## v1.9.0 — 2026-05-20

A **guide-refresh + ecosystem catch-up** minor release shipped in five passes against the plan at `quality_reports/plans/2026-05-20_v1.9.0-guide-refresh.md` (local-only; not tracked in git per the standard `quality_reports/plans/*` ignore rule). No breaking changes.

**Inventory at release: 36 skills, 16 agents, 26 rules, 6 hooks** (was 30 / 14 / 24 / 6 at v1.8.0). The release adds 6 skills (`/humanize`, `/prompt`, `/prompt-only`, `/compress-session`, `/promote-memory`, `/stata-replication`), 2 agents (`humanize-auditor`, `promote-memory-council`), and 2 rules (`model-routing.md`, `stata-code-conventions.md`).

### Pass 1 (PR #114, merged 2026-05-20) — guide refresh mechanical corrections

Eight mechanical corrections that bring the guide in line with Anthropic shipments through May 2026 (Weeks 17–20), reframe three lingering "automatic orchestrator" mentions, refresh the clo-author citation to its current MAS v2 architecture, and add a Models / API section to TROUBLESHOOTING covering the 2026-06-15 Sonnet 4 + Opus 4 retirement and the Agent SDK credit-pool split. No new skills, agents, rules, or hooks. On-disk inventory unchanged.

### Fixed

- **`guide/workflow-guide.qmd` + `TROUBLESHOOTING.md` + `CHANGELOG.md`** — `/less-permission-prompts` → `/fewer-permission-prompts`. Verified against Anthropic's [Week 16 changelog](https://code.claude.com/docs/en/whats-new/2026-w16) and Boris Cherny's launch announcement: the skill shipped under `/fewer-permission-prompts` from day one. The previous template name was a typo, not a rename — historical-changelog wording rewritten for accuracy.
- **`guide/workflow-guide.qmd:46–157`** — three lingering framings of orchestration as automatic ("Claude automatically: → Runs X, → Runs Y...") rewritten to name the invoked skill explicitly ("Claude invokes `/slide-excellence`, which internally..."). Reinforces the [orchestrator-protocol rule](.claude/rules/orchestrator-protocol.md) — there is no repo-wide daemon; orchestration lives inside the invoked skill.

### Added — Anthropic shipments since 2026-04-27

- **Model lineup callout** (Multi-Model Strategy section) — documents Opus 4.7 as the Max/Team Premium default (GA 2026-04-16, same pricing as 4.6: \$5/\$25 per MTok), Sonnet 4.6 as workhorse (1M context still available; the 4.5 1M beta retired 2026-04-30), Haiku 4.5 as the fast tier. Sources: [Opus 4.7 announcement](https://www.anthropic.com/news/claude-opus-4-7), [Platform release notes](https://platform.claude.com/docs/en/release-notes/overview).
- **`xhigh` effort level** (Effort Levels table + How-to-set list) — introduced Week 16 (Apr 13–17, v2.1.105–113); recommended for Opus 4.7 coding work. Bare `/effort` now opens an interactive slider. Hooks see `effort.level` and `$CLAUDE_EFFORT` is set in Bash subprocess env (Week 19).
- **Auto mode flag retirement** (Permission Modes table) — `--enable-auto-mode` no longer required for Max + Opus 4.7 users as of Week 16.
- **`/goal <verifiable condition>`** (Session Management + Anthropic Utilities) — shipped Week 20, v2.1.139 (May 11). "Keep working until X holds" command, distinct from `/loop` (interval) and plan mode (strategy approval). Pairs with `/commit` quality gates. Source: [`docs.claude.com/en/goal`](https://code.claude.com/docs/en/goal).
- **`claude agents` dashboard** (Cost-Conscious Parallelism + Anthropic Utilities) — also Week 20, v2.1.139. Single screen for all background sessions; aligned with the `/review-paper --peer` parallel-referee pattern.
- **`/loop` alias `/proactive`** noted (Week 16).
- **`worktree.baseRef` setting** (Pattern 12) — Week 19. New callout explains `fresh` (default; branch from remote default) vs `head` (branch from local HEAD). Surprises users with uncommitted in-flight edits — documented inline.

### Added — TROUBLESHOOTING entries (Models and API section)

- **Sonnet 4 / original Opus 4 retire 2026-06-15** — migration checklist covering `ANTHROPIC_MODEL` env, `.claude/settings.json` model overrides, agent frontmatter pins, and CI `claude -p --model` calls. Recommended replacements: Sonnet 4.6 and Opus 4.7 respectively.
- **Agent SDK credit-pool split (2026-06-15)** — heads-up that `claude -p` headless subprocess calls (used by `/coarse-review` and any other `claude -p`-based skill) draw from a separate monthly Agent SDK credit pool after the cutover. Anthropic posts cited: [Apr 8 "Decoupling Brain from Hands"](https://www.anthropic.com/engineering), [Platform release notes](https://platform.claude.com/docs/en/release-notes/overview).

### Changed — ecosystem references

- **clo-author** (Ecosystem section) — new callout documenting v26.05 (2026-05-10): MAS v2 (second-generation multi-agent system), Skill-Centric Restructure (13 skills + 18 agents, up from 17), HTML Dashboard. The `/checkpoint` attribution to v4.2.0 remains accurate as historical record (that's where the pattern was adapted from); the callout makes clear that current forkers of clo-author get the MAS v2 / skill-centric layout.

### Provenance

This pass is the first slice of a research-grounded refresh. Four parallel research agents (Anthropic ecosystem, community repos, cross-vendor coding agents, internal guide audit) plus two verification agents (Anthropic claim verification, ARS source-code audit) ran on 2026-05-20. Findings, ranked recommendations, and source URLs are in `quality_reports/plans/2026-05-20_v1.9.0-guide-refresh.md` (local-only; not tracked in git per the standard `quality_reports/plans/*` ignore rule). Passes 2–5 add capability (B Cost & Caching section, C poli-sci breadth woven into guide body, D `/preregister` + `/checkpoint` patterns, E `/review-paper --variance N`, F `passport.yaml` claims provenance, G architect/editor cost-routing, H `/promote-memory` five-critic council, I HIGH-WARN claim-faithfulness blocking, J `/compress-session`, K SDK credit awareness, L Anthropic engineering-post citations, M `/prompt` port from Blattman, N `/humanize` detect-and-flag skill, plus Stata-MCP integration). All deferred to follow-up commits; nothing in this commit adds new on-disk infrastructure.

### Verification

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts unchanged (30 skills / 14 agents / 24 rules / 6 hooks)
- `./scripts/check-palette-sync.sh` — palette in sync
- `./scripts/check-skill-integrity.py` — all checks pass

### Pass 2A — guide-only capability adds (2026-05-20)

Two guide-body additions: weaves the v1.8.0 political-science breadth into the user-facing guide body (previously documented only in the v1.8.0 CHANGELOG entry), and introduces a new "Cost-Conscious Composition" subsection that documents prompt-cache TTL behaviour, per-agent model routing (70/20/10 pattern), and `/cost` / `/usage` monitoring. No new skills, agents, rules, or hooks. On-disk inventory still unchanged.

#### Added — political-science breadth surfaced in guide body

- **5-Lens Framework table** — added Political Science as a third worked example column alongside Economics and Physics. Lens entries reflect poli-sci norms (ignorability, conjoint AMCEs under Hainmueller–Hopkins–Yamamoto, `cjoint`/`survey::svyglm` defaults, manipulation-check fidelity).
- **Domain-reviewer ship status callout** — documents that the template ships *two* concrete customizations of `.claude/agents/domain-reviewer.md` (econ + poli-sci), both viable starting points for forkers' own fields.
- **`/review-paper --peer [journal]` callout** (Research Skills section) — new explainer covering the editor + 2-referee + editorial-decision pipeline, the journal-profiles starter set (AER, QJE, JPE, ECMA, JoE, APSR, AJPS, JOP), and the full 6-paper-type methods-referee taxonomy with sanity checks per type (reduced-form, structural, theory+empirics, descriptive, formal-theory, survey-experiment). The v1.8.0 formal-theory + survey-experiment additions are now discoverable from the main guide, not just from the CHANGELOG.
- **"What ships preloaded vs. what you customize" callout** (§7 Customizing for Your Domain) — explains what already ships for econ + poli-sci (journal profiles, paper types, discipline cards) and what forkers add for psych / sociology / public-health (~3 profiles + 2–3 paper types + 1 card per discipline). Points at `.claude/references/v1.9-backlog.md` as the candidate-next-breadth roadmap.

#### Added — Cost-Conscious Composition subsection (§ between Multi-Model Strategy and Permissions)

- **Prompt-cache TTL guidance** — documents the 60 min → 5 min default-TTL change and the opt-in `ENABLE_PROMPT_CACHING_1H` environment variable on API/Bedrock/Vertex/Foundry plans. Cites Apr 2026 community cost-analysis showing 30–60% effective input-cost increase for long pipelines without the 1-hour opt-in. Documents `cache_miss_reason` (public beta 2026-05-13) as the diagnostic.
- **70/20/10 model-routing pattern** — explicit table of Haiku (70%, mechanical work) / Sonnet (20%, review and critique) / Opus (10%, high-judgment work). Maps each tier to specific template agents (TikZ extraction → Haiku; r-reviewer → Sonnet; editor/methods-referee → Opus). Cites Anthropic's Apr 8 2026 "Decoupling brain from hands" post for primary-source endorsement.
- **Effort-budgeting guidance** — reach for `xhigh` (Opus 4.7) only when verified that the cheaper tier failed.
- **`/cost` and `/usage` monitoring callout** — when to run each and how to read cache hit-rate as a TTL-misconfiguration signal.
- **Agent SDK credit-pool 2026-06-15 callout** — links to the TROUBLESHOOTING Models / API section landed in Pass 1.

#### Verification — Pass 2A

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts still unchanged (30/14/24/6)
- `./scripts/check-skill-integrity.py` — all checks pass
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]

### Pass 2B — `/preregister` + `/checkpoint` promoted to Pattern entry (2026-05-20)

Promotes the v1.8.0 `/preregister` and `/checkpoint` skills from appendix entries to a first-class **Pattern 16: Preregistration and Submission Discipline** in the Workflow Patterns section. ~85 lines of new prose. Still no new skills, agents, rules, or hooks — Pattern 16 documents what already ships.

#### Added — Pattern 16: Preregistration and Submission Discipline

- **When-preregistration-matters checklist** — launch of experiment, observational analysis before outcome inspection, R&R PAP request, funding pre-submission.
- **Registry-comparison table** — OSF / AsPredicted / AEA RCT side-by-side (field, length, editability). Public-health / clinical-trial registries explicitly out of scope (on v1.9-backlog).
- **End-to-end workflow diagram** — `/interview-me` spec → `/preregister --style` → user uploads → `/checkpoint preregistration-submitted` → data collection begins.
- **Per-registry mandatory-field matrix** — 10 rows × 3 styles, showing MUST / SHOULD / MAY for each field. Captures registry-specific differences (e.g., AEA mandates intervention description and data-sharing plan; AsPredicted allows looser covariate specification).
- **`/checkpoint` pairing protocol** — explicit `pre-submit` → `submitted [registration-id]` → `data-arrived` snapshot sequence so the boundary between confirmatory and exploratory is structurally visible.
- **Post-flight `/verify-claims` integration** — every cited reference in the preregistration runs through Chain-of-Verification before submission. Hallucinated citations are the most common preregistration failure mode.
- **Anti-pattern protections enumerated** — HARKing, p-hacking, forking paths, selective reporting — and which fields of the preregistered document defend against each.
- **Field-specific guidance** — pointers to Christensen & Miguel (2018) for development economics, Monogan (2015) for political science, OSF Preregistration Guide for psychology.

#### Verification — Pass 2B

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts unchanged (30/14/24/6)
- `./scripts/check-skill-integrity.py` — all checks pass
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]

### Pass 2C — `/review-paper --variance N` reviewer-disposition variance mode (2026-05-20)

Adds a fourth `--peer` mode to `/review-paper`: **`--variance` (with integer N, default 3)** runs N referees with independently sampled dispositions from the 6-way taxonomy, then the editor synthesizes the results into a **decision distribution** (not a point estimate). Motivated by AgentReview (EMNLP 2024, [arXiv:2406.12708](https://arxiv.org/abs/2406.12708)), which found ~37% of paper decisions vary purely from reviewer-disposition sampling.

#### Changed — `/review-paper` SKILL.md

- New `--variance` flag in argument-hint and the sub-flags list under "Peer-review mode."
- New "Variance mode (`--peer --variance N`)" subsection: motivation (AgentReview), procedure (sample with replacement + stratification override that always includes a SKEPTIC if none drawn for N ≥ 3), output files (`referee_1.md` … `referee_N.md`, `decision_distribution.md`, `editor_synthesis.md`), cost discipline (referee-tier cost × N relative to default `--peer`; hard cap N=5; route referees to Sonnet for variance runs), and mutual-exclusivity rules (cannot combine with `--stress` or `--r2`/`--r3`).
- When-to-reach-for-it guidance: pre-submission "how confidently will this survive," cross-journal target comparison, post-rejection sanity check.

#### Changed — `editor.md` agent

- **Phase 1b (Referee selection)** now branches: default 2-referee deliberate-diversity sampling (existing) vs. variance-mode N-referee independent sampling **with replacement** (new). Stratification rule: if N ≥ 3 and the realised draw includes no SKEPTIC, replace one randomly chosen referee with a SKEPTIC. Realised-disposition table and stratification-override metadata are recorded for `decision_distribution.md`.
- **New "Variance synthesis mode" section** documents the two-file output (`decision_distribution.md` + `editor_synthesis.md`). The distribution file contains a realised-disposition table, a verdict-distribution table (counts and shares), a concern-frequency table (K-of-N), and an interpretation guide (tight modal majority + robust concerns; wide spread + high-K skeptic objection; bimodal "love-it-or-hate-it"). The editorial letter explicitly references the variance instead of collapsing it.

#### Verification — Pass 2C

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts unchanged (30/14/24/6)
- `./scripts/check-skill-integrity.py` — all checks pass (forward + reverse flag-parity OK after one cycle of integrity feedback — original `` `--variance N` `` single code-span fixed to ``--variance`` standalone code-span with `N` documented in prose)
- No on-disk inventory change

### Pass 2D — `/humanize` detect-and-flag skill (2026-05-20)

Ships a new skill and a new agent to audit academic prose for AI-voice tells. **Detect-only by design** — there is no `--rewrite` mode. The author edits manually after reading the report; auto-rewriting prose to strip AI tells degrades quality (cross-vendor research finding) and introduces *new* AI tells.

#### Added — new skill

- **`.claude/skills/humanize/`** — `/humanize [file] [--severity low|med|high]` runs a read-only audit on `.tex`, `.qmd`, or `.md` prose against 10 detection categories: (1) boilerplate transitions, (2) AI-cliché lexicon, (3) em-dash/punctuation overuse, (4) symmetric paragraph shapes, (5) tricolon abuse, (6) hedging stacking, (7) "Not only X, but also Y" frames, (8) formulaic openers, (9) hyphenation excess, (10) sycophancy/self-important framing. Output: `quality_reports/humanize_<filename>_report.md` (gitignored) with per-finding line numbers, severity (LOW / MED / HIGH), and suggested rewrites. Carries `disable-model-invocation: true`. Documents the no-`--rewrite` anti-pattern explicitly in the SKILL body.

#### Added — new agent

- **`.claude/agents/humanize-auditor.md`** — read-only auditor that runs the 10-category protocol and returns a structured report (per-category counts, per-finding table, concentration analysis identifying the top-3 most-affected paragraphs, recommendation thresholds for "rewrite" vs "strip" vs "cosmetic"). Calibration heuristics built in (~1000 words: 0 HIGH clean; 3 HIGH manageable; 8+ HIGH recommend rewrite). Reads `style-profile.md` if present to respect documented author preferences. Will not auto-flag single-mention idioms or discipline-legitimate constructions.

#### Changed — count-bearing surfaces

- **Inventory:** **31 skills, 15 agents, 24 rules, 6 hooks** (was 30 / 14 / 24 / 6). All count-bearing surfaces updated: `README.md`, `CLAUDE.md`, `guide/workflow-guide.qmd` (×3 places: capability table, You-Don't-Need-All-Of-This callout, Customizing-Skills section), `docs/index.html` (landing page), `templates/skill-template.md`. Verified via `./scripts/check-surface-sync.sh`.
- **`CLAUDE.md` Skills Quick Reference** — added `/humanize` row.
- **`guide/workflow-guide.qmd` Appendix** — added `Humanize Auditor` row to All Agents; added `/humanize` row to All Skills.

#### Verification — Pass 2D

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts now **31 / 15 / 24 / 6**
- `./scripts/check-skill-integrity.py` — all checks pass on the new SKILL.md
- `quarto render guide/workflow-guide.qmd` — clean render

### Pass 3A — claims provenance + HIGH-WARN gate + `/prompt` port (2026-05-20)

Strategic additions to the paper-pipeline lens: (a) machine-readable claims provenance via a new `passport.yaml` contract, (b) HIGH/MED/LOW-WARN severity tiers on `/verify-claims` with HIGH-WARN gate-refusing `/commit`, and (c) two new skills (`/prompt`, `/prompt-only`) ported from Chris Blattman's claudeblattman v2.1 with the Blattman-specific tool-routing and council elements stripped.

#### Added — new template

- **`templates/passport-template.yaml`** — starter passport file for per-paper claims provenance. Forkers copy once per paper to `quality_reports/passports/<paper-slug>.yaml`. Schema records claim text, manuscript location, source script + line, output file + field, tolerance overrides, last-verified timestamp, and PASS / FAIL / STALE / UNVERIFIED status per claim.

#### Added — new skills (2)

- **`.claude/skills/prompt/`** — `/prompt [text] [depth:light|standard|deep]` reformats an informal or dictated request into a structured six-section prompt (Role / Task / Context / Constraints / Output format / Bookend) then **executes** it immediately. Depth heuristic: Light (< 40 words, no jargon) emits Role + Task + Output + Bookend; Standard (40–200 words, 1+ domain term) adds Context + Constraints + Assumptions block; Deep (> 200 words, specific paper/dataset/submission target) adds Investigation pre-step. Always shows the formatted prompt to the user before executing.
- **`.claude/skills/prompt-only/`** — `/prompt-only [text] [depth] [--save path]` is the same skill **without execution**. Emits the formatted prompt as a reusable artifact. Optional `--save` writes to disk. Use for prompts you'll run later (different conversation, different model, recurring task).

Both ported with attribution from [`chrisblattman/claudeblattman`](https://github.com/chrisblattman/claudeblattman) v2.1. **Deliberately stripped:** Blattman's tool-routing table (ChatGPT / Perplexity / Gemini dispatch) and his `council` token (his `/council` skill is not in this template). Documented in [`.claude/references/prompt-formatting-core.md`](.claude/references/prompt-formatting-core.md) "What we don't ship" section.

#### Added — new reference

- **`.claude/references/prompt-formatting-core.md`** — shared reference used by `/prompt` and `/prompt-only`. Defines the six-section skeleton (Role / Task / Context / Constraints / Output format / Bookend), the depth-calibration heuristic, a worked example, and the explicit boundary with `/interview-me` (single-shot input shaping vs. multi-turn project specification).

#### Changed — claims provenance integration

- **`.claude/rules/replication-protocol.md`** — new "Claims Provenance: `passport.yaml`" section. Documents the YAML schema (paper metadata + per-claim entries with `id`, `claim`, `location`, `source_file`, `source_line`, `output_file`, `output_field`, `tolerance`, `last_verified_on`, `status`, `notes`), the `status` semantics (PASS / FAIL / STALE / UNVERIFIED), integration with `/audit-reproducibility` (passport-mode), `/commit` (advisory by default, gate-refuse on `--strict-passport`), and `/review-paper` (summary section). Attributes the pattern to [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) "Material Passport" while scoping our schema to numeric-claim provenance only (theirs threads ~13 contracts through ~6 agents; ours stays narrow).
- **`.claude/skills/audit-reproducibility/SKILL.md`** — new "Passport-mode (v1.9.0)" section. When a passport file exists, the skill reads + updates + rewrites it in place rather than emitting a one-shot report. Updates `status` per claim (PASS / FAIL / STALE), records discrepancies in `notes`, refreshes timestamps, refuses to auto-populate (passport scope is author-curated to avoid bad inferences).

#### Changed — HIGH-WARN claim-faithfulness tier

- **`.claude/skills/verify-claims/SKILL.md`** Phase 4 — three severity tiers introduced (HIGH-WARN: fabricated reference / direct contradiction / not-found retrieval interpreted as hallucination; MED-WARN: transient retrieval failure; LOW-WARN: source genuinely inaccessible). Tier aggregation table maps to PASS / PARTIAL / FAIL outcomes. **HIGH-WARN gate-refuses `/commit`** for files the skill was just run against unless `--no-fail-closed` or `verifyClaims.allowHighWarn: true` in settings.
- **`.claude/agents/claim-verifier.md`** — output schema extended to include a per-claim `Tier` column (HIGH / MED / LOW / —). New "Tier-assignment rules" section codifies the assignment logic: fabricated citation → HIGH; numerical contradiction → HIGH; directional contradiction → HIGH; transient retrieval failure → MED; genuine inaccessibility → LOW; reasonable paraphrase → no tier. "Be conservative on HIGH-WARN" — false positives erode the gate's authority.

#### Changed — count-bearing surfaces

- **Inventory:** **33 skills, 15 agents, 24 rules, 6 hooks** (was 31 / 15 / 24 / 6 after Pass 2D). Both new skills (`/prompt`, `/prompt-only`) propagated through README.md, CLAUDE.md, guide capability table, You-Don't-Need-All-Of-This callout, Customizing-Skills section, docs/index.html, templates/skill-template.md, guide appendix tables.
- **CLAUDE.md Skills Quick Reference** — added `/prompt` and `/prompt-only` rows.
- **Guide Appendix** — added `/prompt` and `/prompt-only` rows to All Skills table.

#### Verification — Pass 3A

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts now **33 / 15 / 24 / 6**
- `./scripts/check-skill-integrity.py` — all checks pass on both new SKILL.md files
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]

### Pass 3B — per-agent model routing + `/compress-session` + `/promote-memory` (2026-05-20)

Three additions to the cost-discipline and memory-management lenses:

- **G** — new `.claude/rules/model-routing.md` codifying the 70/20/10 architect/editor split (Haiku for mechanical work; Sonnet for review/critique; Opus for high-judgment work). Cites the Anthropic Apr 8 "Decoupling brain from hands" post for primary-source endorsement.
- **J** — new `/compress-session` skill that distils a long-session into a structured note before auto-compaction (motivated by Drew Breunig's "How Long Contexts Fail" four-mode taxonomy). Distinct from `/checkpoint` (explicit stop-point) and from auto-compaction (lossy truncation).
- **H** — new `/promote-memory` skill that runs a five-critic council (generality / staleness / redundancy / evidence / format) on candidate `[LEARN]` entries in `.claude/state/personal-memory.md` to decide what graduates to MEMORY.md. Pattern adapted from Chris Blattman's claudeblattman v2.1 five-critic council with attribution.

#### Added — new rule

- **`.claude/rules/model-routing.md`** — path-scoped on `.claude/agents/**/*.md` and `.claude/skills/**/SKILL.md`. Documents the 70/20/10 pattern with per-tier recipe (mechanical → Haiku 4.5; review/critique → Sonnet 4.6; high-judgment → Opus 4.7). Tags agents per tier (e.g., editor / methods-referee / claim-verifier / quarto-critic → Opus; r-reviewer / slide-auditor / proofreader / humanize-auditor → Sonnet; quarto-fixer / mechanical TikZ extraction → Haiku). Documents two anti-patterns: pushing Opus down a tier (defeats hallucination defence) and the self-as-architect-and-editor pairing (same-model self-pairings produce correlated errors).

#### Added — new skills (2)

- **`.claude/skills/compress-session/`** — `/compress-session [slug]` distils the current session into a structured note (Active state, Decisions made, Files touched, Open questions, Next actions, **Discarded as noise**, Proposed `[LEARN]` entries) and writes to `quality_reports/session_logs/YYYY-MM-DD_compression_<slug>.md`. Defends against [Drew Breunig's four failure modes](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html): poisoning, distraction, confusion, clash. Explicit "Discarded as noise" section is the novel contribution — failed hypotheses don't carry forward as ghost context. Optional PreCompact-hook integration that surfaces a reminder (does NOT auto-invoke — preserves the user's review step).
- **`.claude/skills/promote-memory/`** — `/promote-memory [filter]` runs a five-critic council in parallel (forked contexts via `Task`) on candidate `[LEARN]` entries. Each critic votes YES/NO on one dimension; majority (3+ of 5) promotes. Critics run on Haiku by default (per `model-routing.md`); the user is the final gate even on 5-of-5 unanimous votes. Saves an audit file at `quality_reports/memory_promotion_<date>.md` for forensics. Pattern adapted from Chris Blattman's claudeblattman v2.1 with attribution.

#### Added — new agent

- **`.claude/agents/promote-memory-council.md`** — implements the five-critic protocol. One agent file, five role specs (Generality / Staleness / Redundancy / Evidence / Format), dispatched in parallel via `Task` with `context: fork`. Each critic returns a strict `**Vote:** YES | NO` + one-sentence rationale; the calling skill aggregates. Architectural isolation: each critic sees only its dimension's relevant context (no cross-pollination, no groupthink).

#### Changed — count-bearing surfaces

- **Inventory:** **35 skills, 16 agents, 25 rules, 6 hooks** (was 33 / 15 / 24 / 6 after Pass 3A). All 6 count-bearing surfaces updated: README.md, CLAUDE.md, guide capability table, You-Don't-Need-All-Of-This callout, Customizing-Skills section, docs/index.html, templates/skill-template.md, guide appendix tables.
- **CLAUDE.md Skills Quick Reference** — added `/compress-session` and `/promote-memory` rows.
- **Guide Appendix** — added `Promote-Memory Council` row to All Agents, `/compress-session` + `/promote-memory` rows to All Skills, `Model Routing` row to path-scoped All Rules.

#### Verification — Pass 3B

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts now **35 / 16 / 25 / 6**
- `./scripts/check-skill-integrity.py` — all checks pass on both new SKILL.md files
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]
- `./scripts/check-skill-integrity.py` — all checks pass on both new SKILL.md files
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]

### Pass 4 — Stata expansion: stata-mcp + `/stata-replication` + audit-reproducibility extension (2026-05-20)

User-driven expansion of the template to support Stata-first projects (correction to the original v1.9.0 plan: AEA does not *mandate* Stata; the expansion targets users whose pipelines are Stata-first for reasons of audience reach or original-replication-package fidelity). Three sub-items:

#### Added — new skill

- **`.claude/skills/stata-replication/`** — `/stata-replication [paper-or-data]` scaffolds a numbered Stata pipeline (`00_install.do` through `99_run_all.do`) in `scripts/stata/` and executes via the [`stata-mcp`](https://github.com/SepineTam/stata-mcp) MCP server. Mirrors `/data-analysis` for R-first projects. `--from-r` flag ports an existing R pipeline. `--no-execute` produces scaffolding only. Phase 0 pre-flight halts if `stata-mcp` is not registered (with install instructions); Phase 4 (optional) runs R cross-check on `--from-r` translations to surface clustering-df / default-option drift.

#### Added — new rule

- **`.claude/rules/stata-code-conventions.md`** — path-scoped on `**/*.do` and `scripts/stata/**`. Codifies: standard header (`version 18`, `clear all`, `set seed`, `set sortseed`, `cap log close`, log capture); numbered pipeline (00–99); outputs convention (`scripts/stata/_outputs/` with `sessionInfo.txt`); `esttab` for publication-ready tables with `\input{}` mechanical-update pattern; significance-stars convention (`* 0.10 ** 0.05 *** 0.01`); clustering / SE discipline (`reghdfe`, cluster bootstrap for < 50 groups); balance + attrition via `iebaltab`; graph export to vector + raster; AEA Data Editor compliance checklist. Common Stata-to-R-or-AEA traps table.

#### Changed — `/audit-reproducibility` source-language coverage

- **`.claude/skills/audit-reproducibility/SKILL.md`** — new "Source-language coverage" section documents the three supported ecosystems (R / Stata / Python) with default outputs directories and read-output method per language. Stata-specific notes added: `.dta` outputs read via `haven::read_dta()` (R) or `pyreadstat.read_dta()` (Python); `esttab` `.tex` table-cell values as strongest provenance signal when manuscript uses `\input{}`; clustering-df discrepancy diagnosis (`reghdfe` vs `reg, cluster()`).

#### Added — TROUBLESHOOTING entry

- **`TROUBLESHOOTING.md`** — new "/stata-replication halts at 'stata-mcp not registered'" section. Documents the one-command install (`claude mcp add stata-mcp --scope user -- uvx stata-mcp`), the `uv` prerequisite, and the verify step (`claude mcp list`).

#### Added — Ecosystem entry

- **`guide/workflow-guide.qmd` Ecosystem section** — new "stata-mcp: MCP server for Stata execution" subsection (before ClaudeCodeTools). Documents SepineTam's project, install command, why it matters for v1.9.0's Stata expansion, and the parallel-skill relationship between `/data-analysis` (R) and `/stata-replication` (Stata).

#### Changed — count-bearing surfaces

- **Inventory:** **36 skills, 16 agents, 26 rules, 6 hooks** (was 35 / 16 / 25 / 6 after Pass 3B). All 6 count-bearing surfaces updated. Note: rules count rises only by 1 (the Stata convention rule); skills count rises only by 1 (`/stata-replication` itself); agents unchanged.
- **`CLAUDE.md` Skills Quick Reference** — added `/stata-replication` row.
- **Guide Appendix** — added `/stata-replication` row to All Skills, `Stata Code Conventions` row to path-scoped All Rules.

#### Verification — Pass 4

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts now **36 / 16 / 26 / 6**
- `./scripts/check-skill-integrity.py` — all checks pass on the new SKILL.md
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]

### Pass 5 — verification follow-ups: SDK credit awareness + Anthropic engineering-post citations (2026-05-20)

Closes the v1.9.0 cycle with two small but load-bearing additions:

#### K — Agent SDK credit-pool split (2026-06-15)

Already partially shipped in **Pass 1** (TROUBLESHOOTING "Models and API" section) and **Pass 2A** (Cost-Conscious Composition callout in the guide). Pass 5 confirms the coverage is complete — the `/coarse-review` skill is a Claude Code plugin (not in this template's `.claude/skills/`), so no SKILL.md callout was needed; the TROUBLESHOOTING entry and the guide callout already document the cutover, the affected pattern (`claude -p` headless subprocesses), and the diagnostic ("check the Agent SDK credit balance separately if `/coarse-review` fails with credit-exhaustion errors even though your interactive session works"). **K is closed.**

#### L — Anthropic engineering-post citations

- **Apr 8, 2026 — "Scaling Managed Agents: Decoupling the brain from the hands."** Already cited as primary-source endorsement of the architect/editor split in `.claude/rules/model-routing.md` (Pass 3B) and in the guide's Cost-Conscious Composition section (Pass 2A). No additional citation needed.
- **Apr 23, 2026 — "An update on recent Claude Code quality reports."** New callout added to the guide between the "Mandatory Verification" / "Don't Skip Verification" section and "Creating Your Own Domain Reviewer." Frames the post as a reminder that **model quality can regress** and that the template's verification patterns (`/verify-claims` with forked verifier, `/audit-reproducibility` with `passport.yaml`, cross-artifact review, HIGH-WARN gate-refuse, `/review-paper --variance N`) all assume drift rather than treating any specific checkpoint as a stable baseline.

#### Verification — Pass 5 (and final v1.9.0)

- `./scripts/check-surface-sync.sh` — 26/26 assertions pass; counts at release: **36 skills / 16 agents / 26 rules / 6 hooks**
- `./scripts/check-skill-integrity.py` — all checks pass
- `quarto render guide/workflow-guide.qmd` — clean render
- `python3 scripts/quality_score.py guide/workflow-guide.qmd` — 100/100 [EXCELLENCE]

### Release summary

| Pass | PR | Net additions to disk | What it shipped |
|---:|---:|---|---|
| 1 | #114 | 0 | Mechanical guide refresh, Anthropic Apr–May 2026 catch-up, clo-author v26.05 citation, Models / API TROUBLESHOOTING section |
| 2A | #115 | 0 | Poli-sci breadth woven into guide body, Cost-Conscious Composition subsection |
| 2B | #116 | 0 | Pattern 16: Preregistration and Submission Discipline |
| 2C | #117 | 0 | `/review-paper --variance N` reviewer-disposition variance mode |
| 2D | #118 | +1 skill, +1 agent | `/humanize` detect-and-flag for AI-voice tells |
| 3A | #119 | +2 skills, +1 template | `passport.yaml` claims provenance, HIGH-WARN claim-faithfulness gate, `/prompt` + `/prompt-only` port from Blattman |
| 3B | #120 | +2 skills, +1 agent, +1 rule | Model-routing rule (70/20/10), `/compress-session`, `/promote-memory` five-critic council |
| 4 | #121 | +1 skill, +1 rule | Stata expansion: `/stata-replication`, `stata-code-conventions.md`, `audit-reproducibility` source-language coverage, stata-mcp ecosystem entry |
| 5 | (this PR) | 0 | Apr 23 Anthropic post citation in verification section; closes SDK-credit awareness loop |

**Total v1.9.0 additions:** 6 skills, 2 agents, 2 rules, 1 reference, 1 template. No breaking changes. All count-bearing surfaces verified in sync. Provenance: every addition traceable to the research-grounded plan at `quality_reports/plans/2026-05-20_v1.9.0-guide-refresh.md` (local-only).

---

## v1.8.0 — 2026-04-27

A **disciplinary breadth + audit-hardening + Apr 2026 incorporation** minor release. The cycle landed in two passes: (1) infrastructure-only audit-hardening (mechanical parity checks via `check-skill-integrity.py`, living pet-peeves catalogue, PreCompact blocking, Routines awareness) and (2) capability work (two new skills `/checkpoint` and `/preregister`, political-science breadth via three journal profiles + two paper types + a discipline-cards reference, and Apr 2026 documentation: auto mode promotion, protected-paths gate explainer, session-management commands, Computer Use sidebar, Monitor tool integration, `disable-model-invocation` discipline). No breaking changes; counts updated across all monitored surfaces.

### Added — new skills

- **`.claude/skills/checkpoint/`** — `/checkpoint` produces a structured state snapshot (active plan, recent decisions, file pointers with line numbers, open questions, next 1–3 actions) into `quality_reports/checkpoints/YYYY-MM-DD_<slug>.md`. Companion to (NOT replacement for) the narrative session-log workflow under `quality_reports/session_logs/`. Carries `disable-model-invocation: true` (writes to a persistent state file — must be user-intent). Pattern adapted from Hugo Sant'Anna's [clo-author v4.2.0](https://github.com/hugosantanna/clo-author) with permission; reimplemented in original prose against this template's narrative-session-log + plan-on-disk + auto-memory architecture. Attribution header on the SKILL.md.
- **`.claude/skills/preregister/`** + **`templates/preregistration-template.md`** — `/preregister` drafts a registry-ready preregistration document in OSF, AsPredicted, or AEA RCT Registry style. Extracts hypotheses, design, sampling plan, exclusions, and analysis plan from a research spec (`/interview-me` output) or free-form description. MUST/SHOULD/MAY clarity annotation per section. Pre-flight cross-checks: directional hypothesis, named estimator, ex-ante exclusion rules, sample-size stopping rule. Post-flight CoVe verification of any cited literature (re-uses `/verify-claims`). Output: `quality_reports/preregistrations/YYYY-MM-DD_<slug>.md` (gitignored). Refuses retrospective preregistration (description containing realised results). Greenfield — not ported.

### Added — political-science breadth

- **`.claude/references/journal-profiles.md`** +3 profiles: **APSR** (highest theoretical bar; THEORY-disposition pool weight 0.30; methods-referee tilts toward formal-theory comparative-static sharpness), **AJPS** (methods-emphasis; CREDIBILITY 0.30, replication policy enforced), **JOP** (clarity-of-contribution bar; SKEPTIC 0.25). Each profile is ~40–45 lines following the existing schema.
- **`.claude/agents/methods-referee.md`** +2 paper types: **`formal-theory`** (pure theory; weights tilt toward model originality and comparative-static sharpness; sanity checks include equilibrium existence, assumption tractability, robustness to assumption relaxation) and **`survey-experiment`** (vignette/conjoint/list/factorial; weights tilt toward design, sampling, and attrition+manipulation checks; sanity checks include balance, manipulation-check pass rate, attrition asymmetry, sampling-frame validity). The 4 prior paper types (reduced-form / structural / theory+empirics / descriptive) are unchanged — additions are purely additive.
- **`.claude/agents/domain-reviewer.md`** template-marker comment now ships **two** customization examples (econ + poli-sci) to illustrate that the 5-lens structure is field-agnostic. Lens content under each example reflects field-specific norms (poli-sci: ignorability, conjoint AMCE algebra, Hainmueller-Hopkins-Yamamoto for cross-reference, `cjoint`/`survey::svyglm` package defaults).
- **`.claude/references/discipline-cards.md`** — new reference. Two cards: `econ` and `poli-sci`. Each card: paper-type frequency table, dominant journals (cross-referenced to `journal-profiles.md`), preregistration norms (cross-referenced to `/preregister --style`), method conventions (significance-stars conventions, SE conventions, dominant code language). Read by `/research-ideation`, `/interview-me`, `/preregister`, and the `editor` agent when paper-type or discipline is given without a target journal. Forkers extend for psych / sociology / public-health / etc.

### Changed — research-side skill paper-type awareness

- **`.claude/skills/research-ideation/SKILL.md`** — new Step 3 tags each generated RQ with a likely paper type from the 6-type taxonomy. Output format adds a `**Paper type:**` field per RQ. `discipline-cards.md` informs the default distribution.
- **`.claude/skills/interview-me/SKILL.md`** — Phase 1 ("Big Picture") now optionally asks the researcher what kind of paper they envision (same 6-type taxonomy). Saved to spec frontmatter as `paper_type:` so downstream skills (`/preregister`, `/data-analysis`, `/review-paper --peer`) can read it.

### Added — Apr 2026 feature documentation

- **`TROUBLESHOOTING.md`** +2 sections under Permissions:
  - **Bypass mode still prompts on protected paths** — explains the protected-path list (`.git`, `.vscode`, `.idea`, `.husky`, `.claude` with carve-outs for `commands/agents/skills/worktrees`) and that **auto mode** is the only mode that routes protected paths through the classifier instead of prompting. Documents the auto-mode requirements (Max/Team/Enterprise/API + Sonnet 4.6 / Opus 4.6 / Opus 4.7 + Anthropic API). Includes two workarounds for users without auto-mode access: edit through Bash (`python3` heredoc) or move edits out of `.claude/`.
  - **`.vscode/settings.json` key typo** — `claudeCode.allowDangerouslySkipPermissions` is silently ignored; the canonical key is `allowDangerouslySkipPermissions` (no `claudeCode.` prefix). The typo leaves the protected-paths gate active even with broad CLI bypass. Reload window after fixing.
- **`.vscode/settings.json`** — fixed the typo: `allowDangerouslySkipPermissions: true` (was incorrectly prefixed). Takes effect on next VSCode window reload.

### Changed — `disable-model-invocation` audit

- **`.claude/skills/create-lecture/`**, **`.claude/skills/new-diagram/`**, **`.claude/skills/learn/`** — added `disable-model-invocation: true` to frontmatter. Rationale: each writes a load-bearing persistent file (a new lecture `.tex`, a new TikZ source, a new SKILL.md respectively) that should only be created on explicit user intent. `/deep-audit` also gains the flag in this release (its body writes audit reports + applies fixes). The new `/checkpoint` and `/preregister` skills carry the flag too.

### Added — Apr 2026 doc additions (guide + onboarding)

- **`guide/workflow-guide.qmd`** — new `### Session Management` subsection under "Settings — Permissions and Hooks": `/btw` for side questions outside conversation history, `/rewind` and `Esc+Esc` for checkpoint navigation, `/clear` and `/compact <instruction>` for context resets, `Ctrl+G` for in-editor plan editing, `claude --continue` / `--resume` / `/rename` for cross-session continuity, plus `/checkpoint <slug>` (this template). Three composition patterns documented.
- **`guide/workflow-guide.qmd`** — added `auto` mode row to the permission-modes table; documented bypass mode's protected-path gate inline (`.git`, `.vscode`, `.idea`, `.husky`, `.claude` minus `commands/agents/skills/worktrees` carve-outs).
- **`guide/workflow-guide.qmd`** — Computer Use callout in the Adversarial Pattern section (Apr 2026 Week 14, research preview, optional). Frames Computer Use as the *visual loop* extension when text-level `/qa-quarto` and `/visual-audit` aren't enough.
- **`guide/workflow-guide.qmd`** — Monitor-tool subsection in "Cost-Conscious Parallelism" (Apr 2026 Week 15). Replaces polling-loop anti-pattern for long-running R fits, replication batch reruns, etc.
- **`guide/workflow-guide.qmd`** — new "Anthropic-Shipped Apr 2026 Utilities" section in the ecosystem area: `/team-onboarding`, `/autofix-pr`, `/powerup`, Ultraplan, `/fewer-permission-prompts`. Framed as off-ramps when this template's scope doesn't fit.
- **`README.md`** — Quick Start callout pointing forkers heavily diverging from academic content at Anthropic's `/init` to re-derive `CLAUDE.md`.
- **`templates/skill-template.md`** — new "When to set `disable-model-invocation: true`" subsection codifying the rule (write-load-bearing-persistent-file → set the flag) and the new "CLAUDE.md `@import` syntax" subsection documenting the Anthropic Apr 2026 import feature, with explicit guidance that this template's CLAUDE.md deliberately does NOT use it (under-150-line CLAUDE.md is better monolithic).
- **`.claude/skills/data-analysis/SKILL.md`**, **`.claude/skills/audit-reproducibility/SKILL.md`** — new "Long-running fits / batch reruns: use the Monitor tool" subsections. Document the background-launch + Monitor pattern for jobs that take more than a couple of minutes.

### Surface-sync

- Skills 28 → 30 (`/checkpoint`, `/preregister`). Agents unchanged at 14. Rules unchanged at 24. Hooks unchanged at 6. Counts updated across all 6 monitored surfaces (README, CLAUDE.md, guide `.qmd` + rendered `.html`, `docs/index.html`, `docs/workflow-guide.html`, `templates/skill-template.md`). `scripts/check-surface-sync.sh` clean; `scripts/check-skill-integrity.py` clean. Guide re-rendered with Quarto 1.8.x; `docs/workflow-guide.html` synced.

### Attribution

`/checkpoint` shape: adapted from Hugo Sant'Anna's [clo-author v4.2.0](https://github.com/hugosantanna/clo-author) with permission. Attribution header on `.claude/skills/checkpoint/SKILL.md`.

---

### Pre-v1.8.0 infrastructure (folded into this release)

Two themes that landed in the working tree before the v1.8.0 capability work: audit-hardening (mechanical parity checks + living pet-peeves catalogue that close classes of bug the agent-based `/deep-audit` was missing) and selective incorporation of Claude Code Apr 2026 features (Routines for AFK scheduling, PreCompact blocking, `/fewer-permission-prompts` as a sibling to our `/permission-check`).

### Added — mechanical integrity checks

- **`scripts/check-skill-integrity.py`** — deterministic parity checks that run in under a second. Four checks: (1) frontmatter `allowed-tools` ↔ body tool-invocation parity — catches the v1.7.0 PR #92 class of bug where 4 skills promised `Task` in their body but had no `Task` permission; (2) `argument-hint` ↔ body flag parity — documented flags advertised in the one-line hint; (3) internal markdown anchor resolution — no broken `[text](path#anchor)` links (the `#category-11-numerical-discipline` miss on PR #87); (4) rule `paths:` ↔ skill implementation parity — rule claims skill follows protocol, so skill body must reference the protocol's keywords (the `/interview-me` miss on PR #92).
- **`scripts/check-surface-sync.sh`** now runs both `check-surface-sync.py` (count assertions) and `check-skill-integrity.py` (parity). Either gate failing blocks `/commit` Step 0b.
- **`.claude/skills/slide-excellence/SKILL.md`** `argument-hint` updated to advertise `--fast`, `--skip-substance`, `--acknowledge-template-domain-reviewer` — the first real P2 the new check caught on baseline.

### Added — living pet-peeves catalogue

- **`.claude/references/audit-pet-peeves.md`** — 12-entry seed document cataloguing classes of bug review bots (Copilot / Codex) have caught on recent PRs that `/deep-audit` missed. Each entry: example + how to catch + why deep-audit missed it + when to apply. Grows with each PR — the meta-fix for the "audit agents keep missing this one thing" pattern.
- **`.claude/skills/deep-audit/SKILL.md`** now has a Phase 0 that runs the mechanical checks first (cheapest, most precise), and every agent in Phase 1 is instructed to read the pet-peeves file before reporting clean.

### Changed — documentation

- MEMORY.md `[LEARN:audit]` entry on the mechanical-vs-agent tradeoff (catch classes of bug where precision matters with deterministic checks; use agents for judgment calls).
- TROUBLESHOOTING.md section for `check-skill-integrity` failures — what each P0/P1/P2 means, how to resolve or tune.

### Fixed

- Self-referential false positive in the pet-peeves doc: example `[text](path#anchor)` markdown inside prose was matched by the anchor-resolution check. Script now strips inline code spans and fenced code blocks before scanning, so illustrative examples don't trigger the check.

### Added — Apr 2026 Claude Code incorporation

- **PreCompact hook can now block compaction** (`.claude/hooks/pre-compact.py`). Opt-in via env var `CLAUDE_PRECOMPACT_BLOCK_ON_DRAFT=1`: blocks once per DRAFT plan so the user can approve before losing mid-plan context. Uses the modern Claude Code block protocol (exit 0 + JSON `{"decision":"block","reason":"..."}` on stdout). Fires at most once per plan path — no lock-out loops. Default off; existing users get no change.
- **MEMORY.md `[LEARN:scheduling]` + `[LEARN:hooks]`** capturing two lessons from Apr 2026: (a) `CronCreate` is session-only in practice — use Claude Code Routines (launched Apr 14) for any autonomous work that must survive session termination; (b) PreCompact hooks can now block, which is the right primitive for "don't lose this context."
- **`.claude/references/audit-pet-peeves.md` entry 17** — don't use `CronCreate` for long-delay autonomous work; Routines is the right primitive.
- **TROUBLESHOOTING.md scheduling section** — explains `CronCreate` vs Routines tradeoff (short-delay in-session vs AFK work on web infra) and documents the PreCompact blocking guard. Plus a pointer to the built-in `/fewer-permission-prompts` skill as a sibling to our `/permission-check` (diagnose with `/permission-check`, remediate with `/fewer-permission-prompts`).

No stale model references audited — all 14 agents already use `model: inherit`, so they auto-adapt to Opus 4.7 / Sonnet 4.6 / Haiku 4.5 without changes.

---

## v1.7.0 — 2026-04-16

A **discipline-patterns** minor release. Additive infrastructure for anti-drift (summary-parity) and anti-hallucination (Post-Flight Verification / Chain-of-Verification). Full details below; no breaking changes for forks.

### Added — Post-Flight Verification (Chain-of-Verification)

Mirror of v1.6.0's Pre-Flight Reports, at the output side. Where Pre-Flight proves inputs were read before work, Post-Flight proves factual claims hold after drafting — before the skill returns to the user. Adapted from **Dhuliawala et al. 2023, "Chain-of-Verification Reduces Hallucination in Large Language Models" ([arXiv:2309.11495](https://arxiv.org/abs/2309.11495))**. The core CoVe idea — answer verification questions in a context that does NOT contain the original draft — is architecturally enforced here via `context: fork` on the verifier agent.

- **`.claude/rules/post-flight-verification.md`** — new path-scoped rule. Defines the 4-step CoVe protocol (draft → extract claims → generate verification questions → answer independently in fresh context → reconcile). Scoped to skills that generate factual claims. Fail-closed: if the verifier errors or times out, the draft is surfaced as provisional rather than shipped silently. Opt-out via `--no-verify`.
- **`.claude/agents/claim-verifier.md`** — new forked agent. Never sees the draft (enforced by `context: fork` at the Task boundary). Receives only: claims, verification questions, source-material pointers. Uses `Read`, `Grep`, `Glob`, `WebFetch`, `WebSearch`, `Bash`. Returns a structured verification report (PASS / PARTIAL / FAIL per claim, with evidence quotes + source locations).
- **`.claude/skills/verify-claims/`** — new user-facing skill. Runs Post-Flight on any draft the user hands to it (a `.md`, `.qmd`, `.tex`, `.txt` file). Accepts `--source <path-or-url>` to point at source material. Callable directly by users or spawned by other skills via `Task`.
- **Four skill integrations** — `/lit-review`, `/research-ideation`, `/respond-to-referees`, `/review-paper` (novelty probe in `--peer` mode). Each now runs Post-Flight internally before returning. Skip conditions documented per skill (e.g., `--no-verify`, user pre-verifies).

Rationale: `/lit-review` citations from WebSearch were hallucination-prone (already flagged in SKILL.md); `/research-ideation` negative-literature claims (e.g., "no prior work studies X") and dataset-structure claims are classic hallucination vectors; `/respond-to-referees` "we added X on page Y" claims can be wrong or out-of-date after revision; `/review-paper --peer` editor novelty probe depends on WebSearch.

### Added — anti–whack-a-mole rule (from earlier in v1.7.0 cycle)

- **`.claude/rules/summary-parity.md`** — path-scoped rule preventing surgical word-level fixes on summary paragraphs from introducing new drift elsewhere in the same paragraph. Triggers on CHANGELOG ledes, README taglines, PR `## Summary` blocks, skill/rule/agent frontmatter `description` fields, guide section abstracts, MEMORY.md `[LEARN]` headlines. Core heuristic: two review-bot flags on the same paragraph = rewrite structurally (abstract up), don't patch. Motivated by 3 consecutive Copilot findings on the v1.6.1 CHANGELOG opening (PRs #88–#90), each surgical fix introducing a new drift elsewhere.

### Added — audit learnings

- **`MEMORY.md`** new `[LEARN:audit]` entries capturing the whack-a-mole anti-pattern (summary-parity) and the CoVe vs critic-fixer vs cross-artifact distinction (three complementary verification mechanisms at three different architectural levels). Future sessions inherit both lessons on fresh context.

### Added — guide coverage

- `/verify-claims` and the new `claim-verifier` agent added to the guide's "All Skills" / "All Agents" tables. `post-flight-verification.md` and `summary-parity.md` added to "All Rules." Pre-existing gap in the rules table closed as well: `content-invariants.md` and `cross-artifact-review.md` were on disk but missing from the table; now listed. Path-scoped rule callout updated (16 → 20 path-scoped rules total).

### Changed — counts

- Skills 27 → 28 (`/verify-claims`). Agents 13 → 14 (`claim-verifier`). Rules 22 → 24 (`summary-parity.md` + `post-flight-verification.md`). Hooks unchanged at 6. Surface-sync gate propagates the new counts across all 6 monitored surfaces (README, CLAUDE.md, guide `.qmd` + `.html`, `docs/index.html`, `docs/workflow-guide.html`, `templates/skill-template.md`, `/commit` SKILL internal example).

### Changed — drift-proofing the v1.6.1 CHANGELOG lede (applied the new summary-parity rule)

- Rewrote the v1.6.1 opening paragraph abstraction-first ("No breaking changes. No new directories were added to `.claude/`; existing infrastructure was revised …"). First test of the new summary-parity rule on an existing entry. GitHub release notes for v1.6.1 synced to match.

### Governance note

v1.7.0 establishes the **discipline-pattern trilogy**:

1. **v1.6.0 Pre-Flight** (input discipline) — inputs were read before work.
2. **v1.6.1 summary-parity** (framing discipline) — summaries don't drift from bodies.
3. **v1.7.0 Post-Flight** (output discipline) — factual claims hold before work ships.

All three share a shape: **fail-closed, structured output block, honest fallbacks**. All three address classes of bugs a human reviewer would catch but the agent loop should catch earlier.

---

## v1.6.1 — 2026-04-16

A **framing honesty + hook friction** patch release. No breaking changes. No new directories were added to `.claude/`; existing infrastructure was revised to address two classes of issue surfaced by a multi-round audit:

1. **Claim-vs-reality drift:** v1.6.0 docs and rules described the "orchestrator" as if it were a repo-wide daemon that activates automatically after plan approval. In reality, the 6-step loop (IMPLEMENT → VERIFY → REVIEW → FIX → RE-VERIFY → SCORE) is a **pattern** implemented by specific skills (`/commit`, `/qa-quarto`, `/review-paper --adversarial`, `/slide-excellence`, `/create-lecture`, `/data-analysis`, `/review-paper --peer`). Plan approval does NOT trigger an auto-loop. Similarly, quality thresholds are **advisory inside `/commit`**, not enforced by a repo-wide git pre-commit hook.

2. **Hook blocking fatigue:** the Stop hook `log-reminder.py` used `{"decision": "block"}` to force session-log creation. Effective for discipline, disruptive for autonomous flows. Now exits 0 with stderr-only advisories.

### Changed — honest framing

- **`.claude/rules/orchestrator-protocol.md`** rewritten: opens with "This rule describes the contract that skills implement. The 6-step loop is a *pattern*, not a runtime." Adds a skill-by-skill implementation table (which skill covers which steps; notes where auto-fixing happens and where it doesn't). "Just Do It" mode clarified to explicitly NOT authorize commits on its own — `/commit` invocation is still required.
- **`.claude/rules/quality-gates.md`** renamed to **"Quality Review & Scoring Rubrics"** in practice (header kept for URL stability). Opens with an advisory-framing callout: enforcement is by the `/commit` skill only (halt + ask to override); a direct `git commit` bypasses the review.
- **`.claude/rules/cross-artifact-review.md`** clarifies that detection is **pattern-based** (`\input{scripts/...}` / `%% source:` / filename matches). If the manuscript has none of those signals, nothing auto-invokes — and `--no-cross-artifact` is a no-op. Removed a reference to an unimplemented `--with-scripts` forcing flag.
- **`.claude/rules/beamer-quarto-sync.md`** adds a **precedence-with-SSOT** section for the case where the Quarto file has manual post-translation edits: Beamer remains authoritative; presentation-only divergence (HTML-specific callouts) is allowed; structural drift is a bug.
- **`guide/workflow-guide.qmd`** 4 sections rewritten: "The Orchestrator" → "A Pattern, Not a Daemon"; "Quality Scoring" now advisory; the "Skills vs Orchestrator" callout acknowledges both paths invoke the pattern inside a skill. Removed 5 occurrences of "automatic orchestrator" overselling across the document.
- **`README.md`** contractor-mode framing updated: "runs the orchestrator pattern internally" instead of "runs autonomously." Quality Review section adds an explicit framing-honesty note: "advisory at the harness level — if you bypass the skill, you bypass the review."
- **`docs/index.html`** landing-page bullets reworded: "Contractor mode via skills" (not "Contractor mode orchestrator"), quality-scoring bullet describes halt-and-override inside `/commit`.
- **`CLAUDE.md`** Quality Thresholds table title now reads "(advisory)" with a one-line footnote clarifying `/commit`-only enforcement.

### Changed — hook friction relief

- **`.claude/hooks/log-reminder.py`** no longer blocks. Both block-return branches (no-log-exists and 15-response-counter) converted to stderr-only advisories. `THRESHOLD` raised from 15 → 50. Docstring updated to match the new semantics. The old blocking behavior was effective but disrupted `/loop` and batched-fix flows — stderr reminders preserve the nudge without halting execution.
- **`.claude/hooks/verify-reminder.py`** throttle bumped from 60s → 300s (5 minutes). Same reminder, less noise during iterative `.tex` / `.qmd` / `.R` edits.

### Added — orphan wiring + skill disambiguation

- **`templates/decision-record.md`** (v1.6.0 addition) now wired into `/interview-me`: when the researcher explicitly chooses among alternatives during an interview (e.g. DiD vs IV vs RDD, admin vs survey data), the skill produces an ADR alongside the research spec. Skipped when there's a single uncontested path.
- **Decision trees** added to the top of `/review-paper`, `/seven-pass-review`, and `/slide-excellence` SKILL.md files. Users can now pick the right skill at a glance: review-paper = most drafts; seven-pass = submission-ready / R&R; slide-excellence = slides; plus pointers to single-lens skills.
- **`.claude/agents/domain-reviewer.md`** and **`domain-referee.md`** both prefixed with a scope-disambiguation block. `domain-reviewer` is the general (not disposition-primed) substance reviewer used by `/slide-excellence` and `/seven-pass-review`. `domain-referee` is the disposition-primed variant used by `/review-paper --peer`. Same domain expertise, different calibration.
- **`.claude/rules/r-code-conventions.md`** adds **Section 8: Numerical Discipline** with the project epsilon (`eps <- 1e-12`) for CDF clamping plus 7 headline rules, cross-referenced to `r-reviewer` Category 11. The checklist gains a "numerical discipline" row.

### Added — documentation

- **`TROUBLESHOOTING.md`** +5 sections for v1.5/v1.6 features:
  - **Permissions / bypass / statusline** (6-layer stack diagnosis, why `/permission-check` gates host-global reads, statusline parse-failure recovery)
  - **Peer-review pipeline** (missing journal profile, cloned referee reports, R&R continuation chain breaks)
  - **Surface-sync gate** (count drift resolution, adding a new skill breaks the gate by design)
  - **Pre-Flight Reports** (fail-closed semantics, first-lecture fallback in `/create-lecture`)
  - **Decision records** (where to save, gitignore behavior)
- **`README.md`** Quick Start adds two callouts: Python/R/markdown-only users can skip XeLaTeX/Quarto; `MEMORY.md` vs `personal-memory.md` distinction introduced early (was previously session-2 discovery only).
- **`MEMORY.md`** +6 new `[LEARN]` entries: framing (orchestrator is pattern, quality gates advisory, cross-artifact pattern-based), dogfooding (empty `quality_reports/` dirs is a red flag — Stop hook caught it mid-session), audit (claim-vs-reality is the highest-ROI lens for a governance-heavy template repo). Template inventory refreshed from 6 → 10 files + `tikz-snippets/`.
- **`guide/workflow-guide.qmd`** "All Skills" table adds `/seven-pass-review` and `/permission-check` (were missing).

### Fixed — review-driven polish (from Copilot + Codex on PR #87)

- **Broken anchor:** `r-code-conventions.md` linked to `#category-11-numerical-discipline`, but the actual heading in `r-reviewer.md` is `### 11. NUMERICAL DISCIPLINE`. Dropped the anchor, references by name.
- **Unimplemented flag:** `beamer-quarto-sync.md` advised running `/translate-to-quarto --diff [file]`, but the skill has no `--diff` option. Replaced with "regenerate into a scratch path, diff manually."
- **Contradictory scope:** `domain-reviewer.md` claimed "slides only" while also stating "used by `/seven-pass-review`" (a manuscript skill). Reframed as general reviewer for both artifacts; `domain-referee.md` is the disposition-primed manuscript variant.
- **Stale docstring:** `log-reminder.py` docstring described blocking behavior after the code had been converted to advisory. Updated.
- **Stale docstring:** `verify-reminder.py` said "within 60s" after throttle was bumped to 5 min. Updated.
- **Daemon phrasing in TROUBLESHOOTING:** `sessionInfo.txt` fix referenced "the orchestrator" as if it were a daemon. Points at `00_run_all.R` via `/data-analysis` or the user's pipeline runner instead.
- **`/context-status` regression averted:** intermediate commit had unwired `context-monitor.py` from `PostToolUse`, but `/context-status` reads the cache that hook writes. Codex flagged the dependency; the hook was re-wired before merge.
- **CHANGELOG upgrade example:** pin example updated from `v1.3.0` (2026-04-13) to `v1.6.0` (2026-04-15) to reflect current state.
- **Guide frontmatter date:** stale `2026-03-20` → `2026-04-15` (v1.6.0 release date).
- **v1.6.0 Pre-Flight claim:** CHANGELOG line about "fail-closed if inputs can't be read" now acknowledges `/create-lecture`'s first-lecture fallback (documented exception, not a contradiction).

### Governance note

v1.6.1 establishes the **"claim-vs-reality" audit lens** as a first-class review category going forward. When a template repo oversells itself, the gap is the first thing forkers notice when reality bites. The [LEARN:audit] entry in MEMORY.md captures this: for any governance-heavy feature, the audit question "is the claim mechanically enforced, or is it prose?" catches more real bugs than skill/doc consistency checks.

The Stop hook's conversion from blocking to advisory is a **philosophical tradeoff**: discipline vs. autonomy. v1.6.0 chose discipline (block until the user complies); v1.6.1 chooses autonomy (nudge but don't halt) because the blocking version disrupted `/loop`, batched audits, and autonomous-ship flows. The nudge survives in stderr, the discipline now depends on the user's own habit. If a future release finds this has quietly caused session-log neglect, the blocking form can be restored behind an opt-in setting.

### Verification

Pre-merge deep audit launched 4 parallel agents (guide content, hook code, skills/rules consistency, cross-doc). 1 genuine finding (stale docstring), 1 false alarm (log-reminder fail-open is correct). Fixed on branch before merge.

Surface-sync gate: 27 skills / 13 agents / 22 rules / 6 hooks matched across 6 surfaces. `quality_score.py` on `guide/workflow-guide.qmd`: 100/100.

---

## v1.6.0 — 2026-04-15

A **discipline-layer release**: the template's infrastructure now actively catches the class of bugs that produced reviewer-driven fix PRs in v1.5.x. Also adds two observability/diagnosis tools (statusline, `/permission-check`), doubles the referee pet-peeve pools, and ports three quality patterns from clo-author (Pre-Flight Reports, Content Invariants, Numerical Discipline). No breaking changes.

### Added — observability + diagnostics

- **`.claude/scripts/statusline.sh`** — always-visible mode badge (`[BYPASS] / [PLAN] / [AUTO-EDIT] / [PROMPT]`) + model + git branch. Renders on every turn. Wired via `.claude/settings.json` `statusLine`. Parses session JSON in a single `python3` invocation (per-turn perf).
- **`.claude/skills/permission-check/`** — new `/permission-check` skill. Read-only diagnostic: reads repo-local settings layers auto, requires explicit user confirmation before reading host-global (`~/.claude/settings.json`, VSCode user settings). Redacts unrelated keys. Surfaces drift across the 6-tier permission stack (VSCode user / workspace / CLI user / project / project-local / in-session runtime).
- **Six-Layer Permission Stack + Plan→Bypass Handoff** in the guide. Troubleshooting checklist for "prompts fire despite bypass." Explicit `callout-warning` that plan approval is NOT an enforcement boundary — exiting plan mode returns to `defaultMode` with full bypass authority.

### Added — surface-sync gate

- **`scripts/check-surface-sync.py` + `scripts/check-surface-sync.sh`** — cross-document count consistency gate. Counts `.claude/{skills,agents,rules,hooks}` on disk, scans 6 surfaces (README, CLAUDE.md, guide .qmd + .html, docs/index.html, skill-template) for count assertions using compound regex patterns (avoids false positives on unrelated phrases like "3 parallel agents" or attribution lines). Fails closed on drift — no `"commit anyway"` override. Wired into `/commit` as Step 0b.
- Addresses the systemic drift pattern that produced PRs #70, #76, #78 in v1.5.x (adding a skill updated `.claude/` but left stale counts in prose).

### Added — referee quality polish

- **Expanded editor pet-peeve pools:** 25 → 29 critical peeves (added: notation drift, seed-dependent results, covariate balance absent, overlap/common-support missing); 20 → 25 constructive peeves (added: "what this paper does not show" paragraph, raw-data figures, alternative specs, notation tables, careful attribution). Now exceeds clo-author v3.1 baseline (27/24).
- **`quality_reports/decisions/` + `templates/decision-record.md`** — ADR-style decision records. Template with Status / Problem / Options considered / Decision + rationale / Consequences / Rejected alternatives. Gitignored like plans/specs.

### Added — discipline patterns (ported from clo-author, adapted)

- **Pre-Flight Reports** in `/data-analysis`, `/create-lecture`, `/review-paper --peer`. Each skill now requires a structured output block proving inputs were read before doing work (dataset fields, project conventions, notation registry checks, journal profile, cross-artifact status). Fail-closed if inputs can't be read, **with a documented first-lecture fallback** in `/create-lecture` (proposes a minimal knowledge base when the template is still empty, to avoid deadlocking fresh forks).
- **`.claude/rules/content-invariants.md`** — new rule, path-scoped to `Slides/**/*.tex`, `Quarto/**/*.qmd`, `Quarto/**/*.scss`, `Preambles/header.tex`, `scripts/R/**/*.R`. Defines **INV-1 through INV-12**: palette sync, Beamer↔Quarto notation parity, Quarto CSS override contract, TikZ-as-SVG, single bibliography, no `\pause`, max 2 boxes per slide, motivation-before-formalism, `set.seed` once, relative paths only, transparent-bg figures, project theme on all plots. Critics can now cite invariants by number.
- **`r-reviewer` agent — category 11 "Numerical Discipline":** no float `==`, CDF clamping to open interval with named epsilon (not `[0,1]` — exact 0/1 to `qnorm` yields ±Inf), integer literals for counts (`1L`), pre-allocated vectors, deterministic bootstrap seeding, explicit `na.rm`, no `T`/`F` shorthands.

### Changed — skill trigger descriptions

- **17 `.claude/skills/*/SKILL.md` frontmatter rewrites** for reliable auto-invocation. Verb+object + "Use when: …" trigger phrases + disambiguation from sibling skills (e.g., `/interview-me` explicitly says NOT for lit review, pairs with `/research-ideation`). Follows the `deep-audit` gold-standard pattern. Cold-prompt auto-invocation is now reliable for `/commit`, `/deploy`, `/proofread`, `/data-analysis`, and siblings.
- **`commit` skill triggers tightened** after Codex flagged vague end-of-task phrases as risky: now only explicit commit intent ("commit", "ship it", "push this", "open a PR", "merge to main", "let's commit this"). Removed "wrap up these changes" and end-of-task-signal trigger.
- **Guide: "Writing Effective Trigger Descriptions"** expanded with the 3-part pattern (verb+object → "Use when:" phrases → disambiguation), A/B rewrite example, and a pre-ship checklist.

### Changed — documentation

- **Counts:** skills 26 → 27 (added `/permission-check`), rules 21 → 22 (added `content-invariants`). Agents and hooks unchanged. Synced across all 6 surfaces via the new sync gate.
- **Guide re-rendered** with the new sections (statusline, permission stack, Plan→Bypass handoff, expanded trigger-description guidance). `docs/workflow-guide.html` synced.

### Fixed — systemic quality during development

This release absorbed an unusual volume of reviewer-driven fixes from Codex and Copilot. Representative samples:

- **Count drift:** a single `replace_all` on `"26 skills"` missed `"26 skills, and 21 rules"` (extra "and"), missed `"26 slash commands"`, missed `"template's 26"`. The deep-audit skill now documents the phrasing-variant trap; the surface-sync gate prevents the class of bug.
- **Stop-hook block protocol:** some audit guidance implied non-zero exit codes are required to block. Actually, modern Claude Code accepts BOTH `exit 2 + stderr reason` (legacy) AND `exit 0 + JSON {"decision":"block","reason":"..."}` on stdout (modern — what `log-reminder.py` uses). Deep-audit skill now documents both protocols explicitly so future audit agents don't re-flag `log-reminder.py`.
- **Statusline parse-failure fallback:** parse error emitted `cwd="."` which wasn't empty, bypassing the `pwd` fallback. Fixed to emit empty third line and tightened the bash guard to treat `"."` as invalid.
- **`notify.sh` robustness:** best-effort notification now fails open on missing `jq` AND on malformed JSON input (defaults before jq attempt, silent stderr on parse).
- **Plan→Bypass framing:** initial guide text said "combines safety and prompt-free execution." Codex correctly flagged this as overselling — plan approval doesn't bind later execution to the approved plan. Reworded as "review-before-execute convenience" with a callout warning.
- **`/permission-check` privacy boundary:** first draft read `~/.claude/` and VSCode user settings unconditionally on ambiguous prompts like "why am I getting prompts?". In a shared/corporate environment this could leak host-global config. Restructured into Phase A (repo-local, auto) + Phase B (host-global, explicit user confirmation + key redaction).
- **CDF clamping math bug** in the new Numerical Discipline checklist: initial draft said `pmin(1, pmax(0, p))` but exact 0/1 to `qnorm` yields ±Inf. Fixed to open interval with named `eps`.
- **Content-invariants path globs:** initial frontmatter used bare directories; other rule files use quoted glob patterns. Aligned.
- **Seed format conflict** in `/data-analysis`: Phase 1 required YYYYMMDD (per `r-code-conventions.md`) but the template example still showed `set.seed(42)`. Made self-consistent.

### Attribution

The discipline patterns in this release (Pre-Flight Reports, Content Invariants, Numerical Discipline rules) are **ported from [Hugo Sant'Anna's clo-author](https://github.com/hugosantanna/clo-author) with adaptation to our lecture-shaped surface**. Hugo's v4.1.x has moved to a 10-verb skill consolidation + full paper-type branching we deliberately didn't port (doesn't fit our primary artifact). Invariants have lecture-specific codes (INV-1..INV-12) rather than clo-author's paper-centric ones.

### Governance note

v1.6.0 establishes the "discipline layer" as a first-class template concern. The surface-sync gate makes count drift a pre-commit error, not a reviewer catch. The statusline + `/permission-check` turn permission debugging from detective work into a 2-second glance. The Pre-Flight Report pattern makes "agent hallucinated your variable names" a category of failure that can't happen silently.

---

## v1.5.0 — 2026-04-14

### Added — Simulated peer review

A new `--peer [journal]` mode for `/review-paper` that runs a full editorial pipeline: **editor desk review → referee selection (2 different dispositions from a 6-way taxonomy) → 2 blind referees in parallel → editorial synthesis (FATAL / ADDRESSABLE / TASTE)**. Calibrated per journal.

- **`.claude/agents/editor.md`** — journal editor persona. Desk-reviews (with optional WebSearch novelty probe, ON by default — opt out with `--no-novelty-check`), selects two referees with *deliberately different* dispositions from the 6-way taxonomy (STRUCTURAL / CREDIBILITY / MEASUREMENT / POLICY / THEORY / SKEPTIC), assigns each referee 1 critical + 1 constructive pet peeve, then synthesizes their reports into an editorial decision with classification and "MUST / SHOULD / MAY push back" response-planning block.
- **`.claude/agents/domain-referee.md`** — substance referee. 5 weighted dimensions (contribution 30 / lit positioning 25 / substance 20 / external validity 15 / journal fit 10). Disposition-primed. Requires "What would change my mind: [specific ask]" on every MAJOR concern — a discipline that separates adversarial review from productive review.
- **`.claude/agents/methods-referee.md`** — methodology referee with **paper-type branching**: reduced-form / structural / theory+empirics / descriptive. Each type has its own dimension weights and mandatory pre-scoring sanity checks (sign / magnitude / parameter plausibility / construct validity / etc.). Same "What would change my mind" requirement.
- **`.claude/references/journal-profiles.md`** — NEW directory. Ships with **5 econ journals** (AER / QJE / JPE / ECMA / ReStud), each with Focus / Bar / Domain-referee adjustments / Methods-referee adjustments / Typical concerns / Referee-pool weights / optional Table-format override. Plus a "Field adaptation" section with detailed instructions for non-econ users.
- **`templates/journal-profile-template.md`** — skeleton for adding your own journal/field. Includes a disposition reference and field-specific paper-type guidance (e.g., biology: observational/experimental/computational/review; political science: case-study/comparative/formal-model/survey).

### Changed

- **`/review-paper`** — now supports three modes: default (single-pass), `--adversarial` (critic-fixer loop from v1.4.0), and the new `--peer <journal>` pipeline. Sub-flags: `--peer --r2` / `--peer --r3` (R&R continuation — reloads prior reports, classifies concerns Resolved / Partial / Not addressed, max 3 rounds), `--peer --stress` (hostile editor — forces SKEPTIC dispositions, doubles critical peeves), `--no-novelty-check` (skip WebSearch probes). Output directory: `quality_reports/peer_review_[paper]/` with `desk_review.md`, `referee_domain.md`, `referee_methods.md`, `editorial_decision.md`.
- **`.claude/rules/cross-artifact-review.md`** — adds `--peer` ordering clause: in `--peer` mode, cross-artifact review runs **before** the editor's desk review so reproducibility FAIL can be cited as desk-reject grounds. In default and `--adversarial` modes, cross-artifact still runs at Step 6b (after the paper review).
- **Counts:** **10 → 13 agents** (editor, domain-referee, methods-referee). Skills (26) and rules (21) unchanged. Synced across README, docs/index.html, guide, templates, CLAUDE.md.

### Attribution

The simulated-peer-review pipeline is **adapted from [Hugo Sant'Anna's clo-author](https://github.com/hugosantanna/clo-author) with his explicit permission**. Hugo's work contributed:
- The pipeline shape (editor desk → 2 referees → editorial synthesis).
- The 6-way disposition taxonomy (STRUCTURAL / CREDIBILITY / MEASUREMENT / POLICY / THEORY / SKEPTIC).
- The journal-calibration schema (Focus / Bar / Typical concerns / Referee-pool weights / Table-format overrides).
- The paper-type branching in the methods referee (reduced-form / structural / theory+empirics / descriptive) with per-type dimension weights and sanity checks.
- The "What would change my mind" requirement on every major concern.
- The R&R continuation pattern (reload prior round, classify Resolved / Partial / Not addressed).

We reimplemented all files rather than copying verbatim (clo-author has no LICENSE file at time of adaptation; our version is original text under MIT). All new files carry an attribution header pointing back to clo-author.

Thanks to Hugo for both the inspiration and the permission. The fork is doing great work on the authoring side of the pipeline — complementary to our template's authoring + review orientation.

### Governance note

With v1.5.0, the template's review story is now the strongest single feature: single-pass review (fast feedback), adversarial loop (iterative revision), seven-pass parallel review (broad coverage), simulated peer review (journal-calibrated editorial pipeline), R&R continuation (R&R rehearsal), stress mode (hostile editor). Four complementary review modes, one skill.

---

## v1.4.0 — 2026-04-14

### Added — review-skills hardening

- **`.claude/skills/audit-reproducibility/`** — enforces `replication-protocol.md` by cross-checking numeric claims in a manuscript (`ATT = -1.632 (0.584)`, `N = 2,847`, p-values, percentages) against the actual R / Stata / Python outputs. Tolerance-graded PASS/FAIL per claim. Usable as a `/commit` gate (exit 1 on FAIL). Addresses the "I updated the analysis but forgot to update Table 2" bug.
- **`.claude/skills/seven-pass-review/`** — mechanizes Pattern 15. Seven forked subagents, one per lens (abstract, intro, methods, results, robustness, prose, citations), run in parallel, then a synthesizer produces a prioritized revision checklist with cross-lens contradictions surfaced.
- **`.claude/rules/cross-artifact-review.md`** — paper ↔ code dependency-graph protocol. When `/review-paper` runs, auto-invokes `/review-r` on referenced scripts and `/audit-reproducibility` on the pair. Surfaces critical cross-artifact findings (code bug invalidates paper claim) at the top of the review report. Opt-out: `--no-cross-artifact`.

### Changed

- **`/review-paper`** — new `--adversarial` mode runs the critic-fixer loop from `/qa-quarto` (up to 5 rounds). Single-pass default unchanged. Now also auto-invokes cross-artifact review (Step 6b).
- **`/slide-excellence`** — conditional dispatch: only spawns subagents that can produce useful output (`tikz-reviewer` only on TikZ-bearing files, content-parity only when both `.tex` and `.qmd` counterparts exist, R reviewer only when R chunks are present). Pre-flight check refuses to run `domain-reviewer` if the agent is still the shipped template. New flags: `--skip-substance`, `--acknowledge-template-domain-reviewer`, `--fast`. Cuts token cost ~50% on typical `.qmd`-only files.
- **`/validate-bib`** — new `--semantic` mode: citation-drift detection (duplicate `.bib` entries for the same paper), crossref DOI verification with caching and rate limiting, within-file citation-style consistency, optional `--cite-claim` abstract surfacing. Structural mode unchanged. `--skip-doi` for offline.
- **`.claude/agents/domain-reviewer.md`** — adds `AUTO-DETECT-TEMPLATE-MARKER` so `/slide-excellence` can detect un-customized templates and warn before running generic substance review.
- **Counts:** 24 → 26 skills, 20 → 21 rules. Synced across README, `docs/index.html`, guide, templates, and `docs/workflow-guide.html`.

### Fixed — Codex round-2 regressions

- **Trust-boundary porousness (PR U1):** The `permissions.deny` on `.claude/settings.json` and `.claude/hooks/**` was bypassable via allowlisted shell tools (`Bash(python3 *)`, `Bash(cp *)`, etc.). Narrowed the broad shell allows and added a `PreToolUse` guard. *(Later removed in the bypass-mode directive — see "Removed" below.)*
- **TikZ prevention bypasses (PR U2):** `check_p3` missed `scale={0.8}` and `scale=\myscale`; `check_p4` incorrectly flagged `align=left` (treated `left` as a direction). Rewrote with a brace/bracket-balanced tokenizer that matches standalone option keys. Parse errors now exit 2 (visible) instead of silent 0.
- **R stale-state leak (PR U3):** `scripts/R/03_analyze.R` used `exists("df")` without `inherits = FALSE`, allowing a stale globalenv to satisfy the guard. Added `inherits = FALSE` to match the contract already applied to `02_clean.R` and `05_figures.R`.
- **R template silent-skip (PR U4):** `05_figures.R` silently switched to base-R PDF if `ggplot2` was missing and silently skipped SVG if `svglite` was missing. Made `ggplot2` a hard dependency (fail loudly); kept `svglite` optional but emits an explicit "SKIPPED" warning. Rewrote `scripts/R/README.md` to document hard vs. optional deps.

### Removed

- **`.claude/hooks/protect-sensitive-paths.sh`** — added in PR U1, removed the same release under explicit user directive: "bypass mode means bypass." Bypass permissions (`defaultMode: bypassPermissions`) is the user's chosen high-autonomy workflow; re-adding approval gates during autonomous runs is a regression. Persisted to memory as `feedback_bypass_permissions.md` so this decision isn't re-litigated.

### Governance note

When adversarial reviewers (Codex, Copilot) flag the absence of approval gates as a risk under bypass mode, the template now treats that as a documented tradeoff, not a bug. Hardening under bypass mode is limited to non-blocking signals (PostToolUse reminders, notifications, logging). See `feedback_bypass_permissions.md` in the project's memory directory.

---

## v1.3.0 — 2026-04-13

### Added — TikZ story overhaul

Ported the best parts of Scott Cunningham's [MixtapeTools](https://github.com/scunning1975/MixtapeTools) TikZ infrastructure and wired them into our pipeline end-to-end.

- **`.claude/rules/tikz-prevention.md`** — 6 authoring rules (P1–P6) that stop collisions at write-time: explicit node dimensions, coordinate-map comments, prohibition on `scale=`, directional keyword on every edge label, use the snippet gallery, one tikzpicture per idea.
- **`.claude/rules/tikz-measurement.md`** — six-pass protocol with concrete formulas: Bézier `max_depth = (chord/2)·tan(bend/2)`, character-width table by font size, label-gap calculation, 0.4 cm shape-boundary rule, matplotlib `arc3` Bézier helpers, full margin matrix.
- **`templates/tikz-snippets/`** — 8 production-ready standalone `.tex` diagrams (DAG basic, DAG mediation, two-period DiD, event study, timeline, regression scatter, 3-step flowchart, supply-demand). Every snippet compiles on the first try and passes the prevention grep checks.
- **`Preambles/header.tex`** — production-ready Beamer preamble (previously empty): 11-color palette matching the SCSS, shared TikZ styles (`dag-node`, `decision-node`, `observed-edge`, `counterfactual-edge`, `confound-edge`, `observed-dot`, `counterfactual-dot`), Beamer theme assignments, convenience macros (`\muted`, `\key`, `\good`, `\bad`, `\transitionslide`).
- **`Preambles/README.md`** — usage + palette contract + inventory.
- **`scripts/check-palette-sync.sh`** — greps `Preambles/header.tex` and `Quarto/theme-template.scss`, enforces that the five core palette names exist on both sides. Wired into `validate-setup.sh`.
- **`.claude/skills/new-diagram/`** — scaffold a new TikZ diagram from the gallery with prevention checks pre-applied; compiles standalone, invokes `tikz-reviewer` with measurement citations, loops until APPROVED (max 5 rounds).

### Changed

- **`/extract-tikz`** — mandatory Step 1 prevention pre-check (greps for bare edge labels and `scale=`) before the expensive compile + SVG cycle.
- **`tikz-reviewer`** agent now requires citing the specific pass and formula from `tikz-measurement.md` for every CRITICAL/MAJOR finding. Vague reports are rejected.
- **`settings.json`** allowlist expanded substantially (+23 Bash tools, +36 Edit/Write path rules): read-only tools (grep/cat/head/tail/awk/find/tree/basename/dirname/file), file ops (cp/mv/touch/mktemp), pipeline tools (pandoc/docx2txt/pdftotext), missing git/gh subcommands (tag/rm/mv/remote, issue/release), and Edit/Write pre-approvals for every directory we normally edit (.claude/**, templates/**, guide/**, docs/**, scripts/**, Preambles/**, Slides/**, Quarto/**, Figures/**, quality_reports/**, explorations/**, master_supporting_docs/**, .github/**, plus CLAUDE.md, README.md, CHANGELOG.md, MEMORY.md, .gitignore).
- **Counts:** 23 → 24 skills, 18 → 20 rules, 7 → 6 hooks. Synced across README, `docs/index.html`, guide body, guide appendix, and CLAUDE.md.
- **Guide** Step 3 "Adapt Your Theme" rewritten to document the two-surface palette contract and the sync script.

### Removed

- **`.claude/hooks/protect-files.sh`** and its `PreToolUse` registration. The hook used to block `Edit`/`Write` on `Bibliography_base.bib` and `settings.json` unless bypass was signalled. With the explicit `Edit(...)` / `Write(...)` allow-rules added to `settings.json` (above), Claude Code's permission system handles this cleanly and the extra hook was redundant friction. Removing it also cuts a failure mode (earlier sessions had to work around the hook with `python3 -c` writes).

### Attribution

TikZ prevention + measurement rules adapted from `tikz_rules.md` in [scunning1975/MixtapeTools](https://github.com/scunning1975/MixtapeTools). The source repo has no LICENSE file; its README says "Use freely. Attribution appreciated but not required." Both ported rule files cite Scott at the top.

### Copilot review follow-up (same day)

This release shipped as a sequence of small PRs (#53–#56) plus an end-of-day Copilot-review cleanup PR that fixed 15 issues Copilot caught across those four PRs, removed `protect-files.sh` per user preference, and unified cross-skill grep patterns. Summary of the biggest catches:

- LaTeX load order in `Preambles/header.tex` (xcolor before hyperref; `\makeatletter` around `\@ifclassloaded`; `inputenc` gated by `\ifPDFTeX`).
- `protect-files.sh` env-var bypass moved above `$(cat)` so it exits immediately.
- `/extract-tikz` and `/new-diagram` grep patterns unified character-for-character.
- P1 scoped to boxed nodes; P3 reconciled with the `scale=1.1` convention.
- `check-palette-sync.sh` uses absolute paths (`$(dirname "$0")/..`) and a stable exit-code contract.
- Removed `Bash(npm *)` from the allowlist (too broad — npm run executes arbitrary scripts).

---

## v1.2.0 — 2026-04-13

### Added

- **`/respond-to-referees` skill** — parses a referee report, classifies each concern (addressed / partially / deferred / disagreement), points to specific revisions, and drafts a complete response document using `templates/response-to-referees.md`. Use during the R&R stage of paper revision.
- **HelloWorld sample** — `Slides/HelloWorld.tex` and `Quarto/HelloWorld.qmd` — minimal decks that compile/render on a fresh fork before any project customization.
- **`scripts/validate-setup.sh`** — colored dependency checker for Claude Code, XeLaTeX, Quarto, R, Python, git, gh, and hook permissions.
- **GitHub templates** — `.github/CONTRIBUTING.md`, issue templates, and PR template.
- **CHANGELOG.md** — this file.

### Changed

- **`/commit` skill** — now runs `scripts/quality_score.py` and the `verifier` agent on changed files as a pre-commit gate. Halts on score < 80 unless the user explicitly overrides.
- **`/extract-tikz` skill** — now invokes the `tikz-reviewer` agent after SVG generation and loops on revisions to the Beamer source until APPROVED.
- **`/slide-excellence` skill** — `domain-reviewer` agent is now MANDATORY for `.tex` files (was optional).
- **`CLAUDE.md`** — example rows in the Beamer environments and Quarto CSS classes tables are now visible (not hidden in HTML comments). Added links to `MEMORY.md` and `quality_reports/` so Claude knows where cross-session context lives.
- **`README.md`** — added "Verify Your Setup" step in the Quick Start; replaced "Work in progress" disclaimer; added badges and CHANGELOG link.
- **`docs/index.html`** — added SEO metadata (description, keywords, Open Graph, JSON-LD `SoftwareApplication` schema).
- **Skill count: 22 → 23** across all surfaces.

### Fixed

- `scripts/quality_score.py` — Quarto compilation check no longer doubles the path when `cwd` is set to the file's parent (was producing spurious 0/100 scores).
- `scripts/validate-setup.sh` — git config check now guards behind `command -v git` to avoid misleading warnings when git is missing.
- `Slides/HelloWorld.tex` — added a citation and bibliography slide so `/compile-latex`'s 3-pass + bibtex pipeline completes cleanly on the onboarding sample.

---

## v1.1.0 — 2026-03-20

### Added

- **`/deep-audit` skill** — repository-wide consistency audit (4 parallel specialist agents).
- **2026 Claude Code feature support** — effort levels (`/effort low|medium|high|max`), 5 permission modes, 4 hook handler types, 11 new hook events documented.
- **Skill frontmatter reference** — `effort`, `context: fork`, `agent`, `hooks`, dynamic `!\`command\`` injection.
- **Pattern 15: Sequential Adversarial Audits** — seven-audit protocol for paper review (inspired by ClaudeCodeTools).
- **Ecosystem section** — autoresearch (Karpathy), ClaudeCodeTools, clo-author, claudeblattman, MixtapeTools.
- **Prerequisites section** — install command (`curl -fsSL https://claude.ai/install.sh | bash`), Node.js, Claude account, cost notes.
- **`plansDirectory` setting** — explicit `quality_reports/plans/` location.
- **Automatic "Last Modified" date** — `date-modified: last-modified` in guide YAML.

### Changed

- Major guide refresh: 2400+ lines, all 25 factual claims verified against official docs across two deep-audit rounds.
- Template cleanup for fork-friendliness — removed project-specific session logs, emptied `Bibliography_base.bib`, renamed Emory SCSS to generic `theme-template.scss`.

### Fixed

- All 5 Python hooks: `from __future__ import annotations`, fail-open `try/except`, `~/.claude/sessions/` storage, hash length consistency.
- `pre-compact.py` exit code (2 → 0) and stdout → stderr (PreCompact ignores stdout).
- `post-compact-restore.py` reads `source` field (was reading `type`, never ran).

---

## v1.0.0 — 2026-02-28

### Initial Release

- 10 specialized agents: proofreader, slide-auditor, pedagogy-reviewer, r-reviewer, tikz-reviewer, beamer-translator, quarto-critic, quarto-fixer, verifier, domain-reviewer.
- 22 skills covering LaTeX, Quarto, R, reproducibility, research, and meta-workflows.
- 18 rules (4 always-on, 14 path-scoped) for quality gates, verification, and domain standards.
- Hooks for notifications, context monitoring, session logging, and compaction state.
- Orchestrator protocol (contractor mode) with adversarial critic-fixer loop (max 5 rounds).
- Plan-first workflow with on-disk plan persistence across context compaction.
- Three-tier memory system: `CLAUDE.md` (project), `MEMORY.md` (auto-memory), session logs.
- GitHub Pages deployment via `scripts/sync_to_docs.sh`.

---

## Upgrading Your Fork

If you forked this repo and want to pull our updates:

```bash
git remote add upstream https://github.com/pedrohcgs/claude-code-my-workflow.git
git fetch upstream
git merge upstream/main           # or: git rebase upstream/main
```

Files you almost certainly customized — `CLAUDE.md`, `Bibliography_base.bib`, `Quarto/theme-template.scss`, your lecture files in `Slides/` and `Quarto/`, `.claude/agents/domain-reviewer.md` — may produce merge conflicts. Resolve in favor of your customizations; pull only the infrastructure improvements.

To pin to the newest release: `git checkout $(git describe --tags --abbrev=0)` — or name one explicitly (`git checkout v2.5.0`, latest as of 2026-08-23; see the tags list for what is current when you read this).
