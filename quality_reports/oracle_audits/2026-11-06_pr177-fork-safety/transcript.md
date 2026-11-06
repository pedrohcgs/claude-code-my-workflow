# Oracle Browser Transcript

Conversation: https://chatgpt.com/c/6aee5603-e200-83ea-9a41-732e299536ef

## Prompt

You are an adversarial code and documentation reviewer. Find real defects; do not praise.

## Briefing
The repository is a public GitHub template (`pedrohcgs/claude-code-my-workflow`, about 3,100 forks) that academic researchers fork to run Claude Code (Anthropic's agentic CLI) on their papers, slides and analysis code. It ships Python hooks that Claude Code runs before tool calls (`PreToolUse`), a `.claude/settings.json`, helper scripts, a bash "hook battery" of regression cases, a Markdown README/CHANGELOG/TROUBLESHOOTING, and a Quarto guide. Python 3.9+ on macOS, Linux and Windows (Git Bash) must be supported; bash scripts must work with both BSD (macOS) and GNU tools.

The attached `a-change.diff` is a pull request that is about to be pushed. It does four things:
1. **Fork safety.** Forks of the template had their private issues and PRs land publicly on the template. `scripts/file-issue.py` (full current file: `b-file-issue.py`) is the only sanctioned way Claude files an issue. It now reads `git remote get-url origin` and pins `gh ... --repo` to it, unless origin is the template itself or a local path. When origin is a remote URL whose owner/name cannot be read, it must fail closed (exit 2, nothing created). New battery cases i11–i15 (`c-battery-excerpt.sh`, which includes the fake `gh` used by the tests) cover this.
2. **Hook and settings defaults** (`d-settings.json`): `"onFailure": "block"` on the three guard hooks, and `permissions.blockWritesOutsideWorkingDirectories: true`. `e-hook-entrypoints.txt` shows how each hook ends. Documentation claims about both must match the primary sources in `f-reference-excerpts.md`.
3. **Model currency.** Facts about Claude Sonnet 5.5, Haiku 5.5, Haiku 4.5 and fast mode in `.claude/references/model-versions.md` and elsewhere must match `f-reference-excerpts.md`.
4. **Ecosystem and docs.** Credits to third-party projects and people, a "Day 1" box, a contributing policy (pull requests are now collaborators-only), a pinned MCP config template, and the version bump to 2.7.0.

## What to attack
- `origin_repo()` in `b-file-issue.py`: every remote-URL form git accepts (https and ssh with userinfo, ports, trailing slashes, `.git`, scp-like, ssh-config aliases, GitHub Enterprise, `file://`, local and Windows paths, UNC paths, IPv6 hosts, whitespace and CR/LF in git output, non-UTF-8 output, names containing dots, uppercase). Does any form either (a) leave gh to choose a repository when origin is really a fork, or (b) wrongly refuse or mis-pin a normal clone? Is the `HOST/OWNER/NAME` form correct for `gh --repo`? Is the "no dot in host means an ssh alias for github.com" heuristic wrong for real setups? Could a credential still reach stderr? Is 3.9 compatibility intact?
- The battery cases: is each assertion strong enough to fail on a regression, portable (BSD/GNU grep, Git Bash), and isolated from the user's repository? Could any pass for the wrong reason?
- Every documentation sentence about `onFailure` and `blockWritesOutsideWorkingDirectories`: does it overclaim or underclaim against the schema text and changelog? Is the stated consequence for users right, e.g. that Claude can no longer edit settings files, or what happens without `python3`?
- Every model fact and version number in the diff, checked against `f-reference-excerpts.md`. Flag anything stated that those sources do not support.
- Internal consistency across files: versions, dates, case counts, file references, and claims that contradict each other or the code.

## Output contract
For each finding give: **location** (file + a short verbatim quote), **one-sentence defect**, **a concrete failing case** (the input, URL, command or reading that breaks it), class (bug · security · overclaim · inconsistency · portability · exposition), and severity (major · minor). Order by severity.
- Compute what can be computed: trace the regexes by hand on your adversarial URLs and show the match groups.
- If something cannot be concluded from the attached files, say exactly what is missing. Never write "this is standard".
- "No confirmed defect" is a valid answer for any area. Do not invent marginal findings to look productive.

## Answer

**The fork-safety fix is incomplete.** Some genuine remote origins still reach `gh` without a repository pin, and other origins are pinned to the wrong host. The battery can also miss a broken `--repo` argument. I would address those before pushing this as a completed safety fix.

I traced the regexes and exercised the supplied Python with mocked Git/`gh` subprocesses. The Windows finding below is derived from documented process-launch behavior; its full-battery consequences depend on the omitted prologue.

References below use the repository filenames. **`b`**, **`c`**, and **`f`** mean the supplied full Python file, battery excerpt, and primary-source excerpts.

## Major findings

### 1. Genuine remote origins still fall through to unpinned `gh`

**Location:** `scripts/file-issue.py`, `b:58,85–88`:

> `(?P<path>[^/].*)`

> `if not m or len(m.group("host")) == 1:`

**Defect:** The code treats an unrecognized SCP spelling, or any one-character matched host, as a local path and returns `None` for genuine remote origins.

**Concrete failing cases and match groups:**

| Git output, after removal of the final line ending | Selected regex and groups | Result |
|---|---|---|
| `git@github.com:/alice/fork.git` | Neither matches: `_SCP_FORM` forbids `/` as the first path character | `None` |
| `ssh://git@g/alice/fork.git` | `_URL_FORM`: `host='g'`, `path='alice/fork.git'` | `None`, before `_SLUG` |
| `git@g:alice/fork.git` | `_SCP_FORM`: `host='g'`, `path='alice/fork.git'` | `None`, before `_SLUG` |
| `git@[::1]:alice/fork.git` | `_SCP_FORM`: `host='['`, `path=':1]:alice/fork.git'` | `None`, before `_SLUG` |
| `git@github.com:alice/fork.git\nSECOND` | Neither matches: `.*` does not span the interior newline | `None` |

Git explicitly accepts the SCP absolute-path form `host:/path`; a leading slash after the colon does not make it local. A one-character SSH host can also be an SSH configuration alias. [git-clone Documentation](https://git-scm.com/docs/git-clone?utm_source=chatgpt.com)

For the first two inputs, running the complete `main()` with successful fake searches produced **exit 0 and a fake create, with no `--repo` on any `gh` invocation**.

Malformed byte output can reach the same branch:

```text
stdout = b"ssh://git@\xff/alice/fork.git\n"
decoded host = "\ufffd"
len(host) = 1
origin_repo() = None
```

The required distinction is between a positively identified local path and a remote that cannot be resolved. “Neither regex matched” does not establish the former.

**Class:** security. **Severity:** major.

---

### 2. The SSH-alias heuristic can redirect Enterprise issues to GitHub.com

**Location:** `scripts/file-issue.py`, `b:96–98`:

> `host.startswith("github.com-") or "." not in host`

**Defect:** Host spelling does not establish an SSH alias’s destination, and the heuristic discards genuine Enterprise host identity.

**Concrete failing case:**

```sshconfig
Host github-work
    HostName github.corp.example
    User git
```

With:

```text
origin = git@github-work:alice/private-paper.git
```

the trace is:

```text
_SCP_FORM:
    host = "github-work"
    path = "alice/private-paper.git"

_SLUG:
    owner = "alice"
    name = "private-paper"

origin_repo() = "alice/private-paper"
```

With GitHub.com as `gh`’s default host, the searches and create target `github.com/alice/private-paper`, although the origin belongs to `github.corp.example`.

The same problem does not even require SSH:

```text
https://ghe/alice/private-paper.git
```

matches `_URL_FORM` with `host='ghe'`, then loses that host because it contains no dot. Likewise, a real hostname such as `github.com-enterprise.example.org` matches the `startswith` branch and loses its host.

The reverse error also exists: a dotted SSH alias pointing to GitHub.com is passed literally as an API hostname.

Case **i12** supplies only the text `git@github-work:...`; it supplies no SSH configuration establishing where that alias points. Its expected result therefore tests the assumption rather than its correctness.

**Class:** security. **Severity:** major.

---

### 3. Even an ordinary GitHub.com origin does not fully pin the destination

**Location:** `scripts/file-issue.py`, `b:97–98`:

> `if host == "github.com" ...:`

> `return slug`

Also `.claude/skills/commit/SKILL.md`, the new PR command:

> `gh pr create --repo <origin_owner>/<origin_repo>`

**Defect:** Returning only `OWNER/NAME` leaves the host to `gh`’s configuration, despite having already identified the origin’s host.

**Concrete failing case:**

```text
origin = https://github.com/alice/fork.git
GH_HOST = ghe.example.edu
```

Trace:

```text
_URL_FORM: host="github.com", path="alice/fork.git"
_SLUG: owner="alice", name="fork"
returned value: "alice/fork"
```

The resulting command is:

```bash
gh issue create --repo alice/fork ...
```

A two-component repository identifier uses `gh`’s default host; its default-host implementation checks `GH_HOST` first. Thus this command can select `ghe.example.edu/alice/fork`, not the origin. A sole authenticated Enterprise host can also supply the default without `GH_HOST`. [GitHub](https://github.com/cli/cli/blob/trunk/internal/ghrepo/repo.go?utm_source=chatgpt.com)

**`HOST/OWNER/NAME` is valid `gh --repo` syntax.** The corrective pin for this input is `github.com/alice/fork`. The PR skill’s owner/name-only instruction has the same host omission. [Take GitHub to the command line](https://cli.github.com/manual/gh_issue_create?utm_source=chatgpt.com)

**Class:** security. **Severity:** major.

---

### 4. The template exemption compares the slug but ignores the host

**Location:** `scripts/file-issue.py`, `b:94–95`:

> `if slug.lower() == UPSTREAM_TEMPLATE:`

**Defect:** An Enterprise repository with the template’s owner/name is incorrectly exempted as though it were the public template.

**Concrete failing case:**

```text
https://ghe.example.com/pedrohcgs/claude-code-my-workflow.git
```

Trace:

```text
_URL_FORM:
    host = "ghe.example.com"
    path = "pedrohcgs/claude-code-my-workflow.git"

_SLUG:
    owner = "pedrohcgs"
    name = "claude-code-my-workflow"

origin_repo() = None
```

That repository is distinct from `github.com/pedrohcgs/claude-code-my-workflow`. Nevertheless, the complete script makes its searches and create without a pin. A default public `upstream`, or an explicit `GH_REPO` pointing to the public template, can then select the public destination.

The exemption must compare the resolved host as well as the case-insensitive owner/name.

**Class:** security. **Severity:** major.

---

### 5. Preflight and duplicate-handling instructions still select repositories independently

**Locations:**

`.claude/skills/issues/SKILL.md`, new preflight:

> `gh repo view --json visibility,nameWithOwner`

`scripts/file-issue.py`, `b:230–231`:

> `Read each one (gh issue view N).`

> `gh issue comment N --body-file <file>`

**Defect:** The new pin applies to the helper’s searches and create, but visibility checks and recommended follow-up commands still operate on `gh`’s inferred repository.

**Concrete failing cases:**

- **Wrong visibility check:** Set origin to `https://github.com/alice/public-paper.git` and `GH_REPO` to an accessible `github.com/alice/private-scratch`. The unqualified preflight checks the private repository. Its special mismatch check does not fire because the result is not the template. The helper subsequently pins the public origin, so the workflow can omit the explicit public-repository approval its own instructions require.
- **Wrong duplicate comment:** Let the default repository be the template while origin is `alice/fork`. A pinned search finds issue `alice/fork#31`. The script prints `gh issue comment N --body-file <file>` without the pin; substituting `31` can post the follow-up to template issue 31.

`GH_REPO` is explicitly a repository override for commands that would otherwise operate on the local repository. [Take GitHub to the command line](https://cli.github.com/manual/gh_help_environment?utm_source=chatgpt.com)

I reproduced the second mismatch with the fake subprocess: all searches carried `--repo alice/fork`, but the printed view, comment, and reopen instructions carried no repository.

This instruction text predates the change, but automatic origin pinning makes the inconsistency consequential. The resolved repository needs to follow the issue through preflight, search, review, comment, reopen, and create.

**Class:** security. **Severity:** major.

---

### 6. The shown fake `gh` does not isolate native Windows Python

**Location:** `scripts/hook-battery.sh`, `c:1–3,47–48`:

> `cat > "$FGH/gh" <<'FAKEGH'`

> `#!/usr/bin/env bash`

> `PATH="$FGH:$PATH" ... python3 "$FI" "$@"`

**Defect:** An extensionless Bash stand-in does not intercept `subprocess.run(["gh", ...])` from native Windows CPython, so the tests can launch a real installed `gh.exe`.

**Concrete failing environment:** Run the battery from Git Bash with native CPython 3.9 and an installed `gh.exe` later on `PATH`, while the fixture contains only the shown extensionless `gh`.

Native CPython launches the subprocess through Windows `CreateProcess`, not through the Bash instance that started Python. For the bare executable name `gh`, Windows searches for `gh.exe`; Python 3.9’s `shutil.which` also consults `PATHEXT`. Consequently, the real executable can satisfy the presence check and receive the issue commands. [Python 3.9.25 documentation](https://docs.python.org/3.9/library/subprocess.html?utm_source=chatgpt.com)

An empty fake log would cause assertions to fail **after** those real invocations. Actual creation additionally requires authentication, permission, and searches that permit creation; i15 deliberately names the public template.

**Scope limitation:** This is a confirmed defect in the **shown interception mechanism**, which is pre-existing infrastructure used by the new cases. The full battery prologue is missing. I cannot exclude an unseen native shim, a different Python runtime, a platform skip, or credential/network isolation. I did not execute this on Windows or create a real issue.

**Class:** portability. **Severity:** major.

## Minor findings

### 7. `file://localhost` origins are mis-pinned or incorrectly refused

**Location:** `scripts/file-issue.py`, `b:84–90`:

> `if not m and "://" in url and not url.lower().startswith("file:"):`

**Defect:** The file-scheme exemption applies only after both regexes fail, so a file URL with an authority is processed as a network repository.

**Concrete traces:**

| Input | `_URL_FORM` groups | `_SLUG` groups | Result |
|---|---|---|---|
| `file://localhost/tmp/paper.git` | `host='localhost'`, `path='tmp/paper.git'` | `owner='tmp'`, `name='paper'` | `'tmp/paper'` |
| `file://localhost/home/alice/paper.git` | `host='localhost'`, `path='home/alice/paper.git'` | No match | `ValueError`, exit 2 |

Both violate the stated local-origin exception.

I created a temporary local bare repository under `/tmp`, confirmed that `git ls-remote file://localhost/...` succeeded, and confirmed that `origin_repo()` converted that local URL into a GitHub owner/name identifier.

**Class:** bug. **Severity:** minor.

---

### 8. Rejected origins can still expose credentials on stderr

**Location:** `scripts/file-issue.py`, `b:83,86,92`:

> `shown = re.sub(r"(://)[^@/]*@", r"\1***@", url)`

> `raise ValueError(f"origin is {shown!r}, ...")`

**Defect:** The error prints the remaining URL after redacting only one userinfo pattern, leaving credentials in other URL components or malformed userinfo exposed.

**Concrete failing input:**

```text
https://github.com/alice/fork.git?access_token=TEST_ONLY_CANARY
```

Trace:

```text
_URL_FORM:
    host = "github.com"
    path = "alice/fork.git?access_token=TEST_ONLY_CANARY"

_SLUG: no match
shown: unchanged
```

The complete script exits 2 without invoking `gh`, but stderr contains:

```text
origin is 'https://github.com/alice/fork.git?access_token=TEST_ONLY_CANARY'
```

A malformed input such as `https://user:pa/ss@github.com/alice/fork.git` also retains the password material because `/` prevents the redaction match.

This does **not** establish that GitHub accepts query-string tokens for clone authentication. It establishes that a configured origin containing a credential can disclose it when rejected. Normal `https://USER:SECRET@host/...` userinfo was redacted in the tested rejection case.

**Class:** security. **Severity:** minor.

---

### 9. The pin assertions accept malformed arguments and incorrect Enterprise hosts

**Location:** `scripts/hook-battery.sh`, `c:5,100`:

> `echo "ARGS $*"`

> `grep -E -c -- "--repo $2( |\$)"`

**Defect:** Flattened argument logging loses option boundaries, and interpolating the expected host into an unescaped regex permits incorrect hosts to match.

**Concrete failing regressions:**

First, change:

```python
cmd += ["--repo", repo]
```

to:

```python
cmd += [f"--repo {repo}"]
```

and make the corresponding change for `a.repo`.

The latter passes **one argument**, `"--repo alice/fork"`, rather than a flag followed by its value. The fake CLI accepts it and emits identical `$*` text. Testing this mutant produced every new case’s expected summary:

```text
i11 exit=0 created=1 pinned=5 of=5
i12 exit=0 created=1 pinned=5 of=5
i13 exit=0 created=1 pinned=5 of=5
i14 exit=2 gh-calls=0
i15 exit=0 created=1 pinned=0
```

Second, i13’s expected pattern also matches:

```text
--repo gheXexampleYcom/alice/fork
```

because the two dots in `ghe.example.com` are regex wildcards.

The assertion needs an unambiguous argv representation and exact equality for the value following `--repo`.

**Class:** bug. **Severity:** minor.

---

### 10. The changelog claims settings are immutable through every channel

**Location:** `CHANGELOG.md:16`:

> “Claude can no longer change `.claude/settings*.json` at all”

Related wording in `TROUBLESHOOTING.md:43`:

> “the `root-of-trust-guard` hook already refuses shell writes there”

**Defect:** A file-tool restriction combined with a mutable, fail-open shell-text guard does not establish an all-channel prohibition on changing settings.

**Concrete failing reading:** The same diff’s guide explicitly permits a clean branch switch or merge to replace protected files and says the guard cannot inspect `python3 -c` or `perl -e`. Thus, under the guide’s stated behavior:

```bash
git switch settings-update
```

can change `.claude/settings.json` when the other branch contains different settings.

Source **`f`, §A** also explicitly excludes shell commands, MCP tools, hook programs, and memory tools from the new setting’s scope. The full guard body is absent, so I cannot execute its interpreter cases, but the documentation already contradicts the absolute claim.

The supported consequence is that the named file tools cannot edit settings under this restriction. Recommending manual edits is consistent with that narrower claim.

**Class:** overclaim. **Severity:** minor.

---

### 11. “Every write outside the repository” describes the wrong boundary

**Locations:** `README.md:42`:

> “Claude’s file tools refuse to write outside the repository”

`TROUBLESHOOTING.md:43`:

> “refuse every write outside the repository”

**Defect:** The setting uses working directories and explicit session-file exceptions, not an absolute repository-root boundary.

**Concrete failing cases:** Under **`f`, §A**, a session plan or normal project auto-memory file outside the repository remains writable. A second configured working directory outside the repository is also within the permitted directory set. The schema additionally says cloud sessions may not apply the setting.

`CHANGELOG.md` already uses “working directories” and names some exceptions, so the README and troubleshooting wording is also inconsistent with that description.

**Class:** overclaim. **Severity:** minor.

---

### 12. Two explanations incorrectly limit `onFailure` to startup and timeout failures

**Locations:** `README.md:82`:

> “`"onFailure": "block"` catches only a guard that cannot start or times out”

`guide/workflow-guide.qmd:1459`:

> “`"onFailure": "block"` closes only the case where the hook cannot start or times out”

**Defect:** “Only” excludes unexpected exit codes and invalid or schema-invalid JSON, which the supplied schema explicitly covers.

**Concrete failing case:** A hook starts successfully and executes `sys.exit(1)`. Under **`f`, §A**, `onFailure: "block"` blocks the action. A hook that emits JSON failing hook-output validation is another counterexample.

The changelog itself includes “exits with an unexpected code,” contradicting these narrower sentences.

The entrypoint’s `except Exception: sys.exit(0)` remains a separate matter: converting a caught exception into success prevents `onFailure` from seeing that exception as a hook failure.

**Class:** exposition. **Severity:** minor.

---

### 13. Historical qualification totals are rewritten to include the new tests

**Location:** `quality_reports/qualification/LEDGER.md:143`, the changed reproduction paragraph:

> “restoring the helper in the same copy returns the run to ALL PASS at 317 cases, exit 0. Both directions measured 2026-08-23.”

**Defect:** The patch changes the denominator of a dated August measurement to the November battery total without separating historical results from a current rerun.

**Concrete failing reading:** The patch adds i11–i15 on November 6 and changes the current total from 312 to 317. The quoted sentence nevertheless describes the 317-case result as measured on August 23. Equivalent 312→317 substitutions occur alongside the dated r15/r16/r17 measurements.

The arithmetic **312 + 5 = 317** is consistent for the current battery. It does not justify rewriting an earlier measurement. Preserve the historical result or provide a separately dated rerun.

**Class:** inconsistency. **Severity:** minor.

---

### 14. The MCP template does not pin the R server version

**Location:** `templates/mcp.example.json:2`:

> “Versions are pinned (checked 2026-11-06); bump them deliberately.”

Compared with:

> `"args": ["-e", "mcptools::mcp_server()"]`

**Defect:** The R entry loads the installed `mcptools` package and contains no package-version pin.

**Concrete failing case:** Two machines with different installed `mcptools` versions launch different server versions from the identical JSON. Updating the installed R package changes the server without changing any template pin.

An external R environment lock could constrain this, but none is supplied for this entry. The claim should identify the PyPI and npm entries as pinned and describe the R entry’s environment requirement.

The older explicit pins, `stata-mcp@1.25.2` and `@upstash/context7-mcp@4.4.4`, are not defective merely because **`f`, §D** lists newer releases.

**Class:** overclaim. **Severity:** minor.

## Model facts: what the supplied sources establish

I found **no confirmed contradiction** in the following numerical or behavioral claims against **`f`, §C**:

| Claim | Result against the supplied excerpts |
|---|---|
| Sonnet 5.5 input/output price of $2/$10 per MTok | Supported |
| Sonnet cache reads fall from $0.20 to $0.10 | Supported; the reduction is exactly **50%** |
| Haiku 5.5 prompt-length pricing tiers and $0.01/$0.05 cache reads | Supported; cache reads are **10%** of the respective input prices |
| Haiku 5.5 release on October 7, 2026, 1M context, 128K output, medium default effort | Supported |
| Sonnet 5.5 and Haiku 5.5 effort levels `low/medium/high/xhigh/max`, with high/medium defaults | Supported by the supplied API-skill paraphrase |
| Haiku 5.5 accepts forced tool choice and omits thinking in that response | Supported |
| Fable 5.1, Opus 5.5, and Sonnet 5.5 reject forced `any`/`tool` | Supported by the supplied API-skill paraphrase |
| Haiku 4.5 remains active, with a retirement floor of October 15, 2026 | Supported; passing that floor is not retirement |
| At least 60 days’ retirement notice for publicly released models | Supported |
| Opus 5.5 fast-mode pricing of $8/$40; prior-generation $10/$50 pricing | Supported |
| Opus 4.8 fast mode is deprecated and removed November 30, 2026 | Supported; this is a fast-mode removal statement |
| Verification expiry from November 6, 2026 to January 5, 2027 | Exactly **60 days** |

### Model claims whose verification the bundle cannot establish

The following statements need additional source passages. I cannot certify them from `f`; I am not assigning them factual falsity without those passages.

| Location and short quote | Exact missing evidence |
|---|---|
| `model-versions.md:18`: **“GA 2026-09-28”**, repeated in CHANGELOG | A Sonnet 5.5 release/GA statement. A retirement floor of September 28, **2027** does not establish the release date by subtraction. |
| Same row: **“native 1M context, 128K max output; adaptive thinking”** | A Sonnet 5.5 capability specification. The supplied excerpts establish prices, effort, and forced-tool behavior. |
| Haiku row: **“adaptive thinking”** | An explicit adaptive-thinking specification; a thinking block and an effort setting do not independently establish that mode. |
| Haiku row: **“the first Haiku with `effort`”**, **“up from 200K”**, **“up from 64K”** | Historical Haiku capability evidence. The superseded document’s own assertions are not independent verification. |
| `model-versions.md:23`: **“on the Anthropic API … `haiku`→Haiku 5.5”**, and the provider-alias discussion | The referenced Claude Code `model-config` passages showing shorthand resolution by provider. |
| `model-routing.md`: **“low / medium / high / xhigh / max on all four”** | Fable and Opus effort-level specifications; `f` supplies the list for Sonnet and Haiku. |
| Fable/Opus table rows and repeated guidance | Sources for the release dates, base prices, capacities, default effort, plan/provider defaults, minimum CLI versions **2.1.257/2.1.280**, and comparative evaluation claims. Most are unchanged context, but their verification stamp is advanced. |
| `model-versions.md`: **“research preview, Claude API only”** for fast mode | Preview-status and provider-availability passages. The supplied fast-mode excerpts establish pricing and removal timing. |
| The attributed **“Fable vs Opus, in Anthropic’s words”** quotation | The quoted models-overview passage, absent from `f`. Its exact quotation fidelity cannot be checked. |
| README/routing/guide statements applying model effort defaults to Claude Code | Claude Code’s effort-default and override semantics. The supplied model defaults are API evidence. |
| TROUBLESHOOTING/guide: **“Sonnet 4 and the original Opus 4 retired on 2026-06-15”** | Those models’ retirement entries; `f` does not contain them. |
| Advisor-tool statements, the **“28/28”** historical failure account, and associated model-version requirements | The advisor documentation and the recorded historical evaluation. Neither is supplied. |

There is also an API/CLI terminology issue to avoid introducing during repair: **`haiku` as a Claude Code tier shorthand is different from a separate API model-ID alias.** The migration excerpt saying `claude-haiku-5-5` has no separate alias does not, by itself, disprove the CLI shorthand. The text should identify which meaning it intends.

## Other computed outcomes and limits

### URL and Python checks with no additional confirmed defect

These traces are relevant controls; they do not resolve the failures above.

| Input or feature | Computed outcome |
|---|---|
| `https://GitHub.com/Alice/paper.v2.git/` | URL groups `host='GitHub.com'`, `path='Alice/paper.v2.git/'`; slug groups `owner='Alice'`, `name='paper.v2'`; returns `Alice/paper.v2`, subject to finding 3’s host omission |
| `https://user:SECRET@github.com/alice/fork.git` | Userinfo is excluded from the host; slug is `alice/fork` |
| `ssh://git@github.com:22/alice/fork.git/` | URL groups `host='github.com'`, `path='alice/fork.git/'`; slug is `alice/fork` |
| `git@github.com:alice/fork.name.git.git/` | Slug name is `fork.name.git`; exactly one transport `.git` suffix is removed |
| Ordinary absolute/relative local paths, `C:/...`, `C:\...`, and ordinary UNC paths | Return `None`, as the requested local-path policy permits |
| A final CRLF | Removed by `.strip()` |
| Non-UTF-8 bytes within owner/name | Replacement character fails `_SLUG`; tested case raises `ValueError` |
| `ssh://git@[2001:db8::1]/alice/fork.git` | Neither regex matches; raises `ValueError`, not an unpinned create |
| Python 3.9 syntax | Parses under the 3.9 grammar; `from __future__ import annotations` prevents evaluating the `str \| None` annotations |

I found **no confirmed Python 3.9 incompatibility** in the supplied file. The execution probes used Python 3.12; this was not a complete runtime test on Python 3.9.

Two remaining URL qualifications matter:

- `ssh://git@ssh.github.com:443/alice/fork.git` returns `ssh.github.com/alice/fork`. That spelling alone does not establish a defect: current go-gh includes normalization of `*.github.com` hosts. The supported `gh` version is unspecified, so I would not claim this normal clone form is broken without checking that version’s complete resolution path. [GitHub](https://github.com/cli/go-gh/blob/trunk/pkg/auth/auth.go?utm_source=chatgpt.com)
- A nondefault **HTTPS** port is discarded by `_URL_FORM`. Establishing the consequence for a supported Enterprise deployment requires its API endpoint/port contract and the supported `gh` version. An **SSH** transport port should not simply be copied into an HTTPS API address.

### Settings and version claims

- **No confirmed defect in the four `onFailure` registrations for three scripts.** `issue-guard.py` intentionally has separate `gh` and `gh.exe` entries.
- **The missing-`python3` consequence is supported for a local CLI honoring `onFailure`.** The `git-guardrails` matcher covers Bash, Write, Edit, and MultiEdit. The docs’ Bash/Edit/Write statement is not an invented consequence.
- **Caught ordinary exceptions still fail open**, as shown by the supplied entrypoints. That does not cover syntax/import failures before the handler, or every possible process termination.
- The claim **“older Claude Code versions ignore the key”** is broader than the evidence. `f` contains one observation on **2.1.283**. It does not establish behavior for every older version.
- The statement that the VS Code extension **“never read”** the workspace bypass keys needs the extension’s configuration source or version-scoped observations; `f` provides neither.
- **2.7.0 / 2026-11-06** agree across CHANGELOG, CITATION, and guide metadata. The November 4 versus November 6 verification dates are not intrinsically contradictory because the source list explicitly describes different read dates.

### Battery isolation, counts, and ecosystem evidence

- **No confirmed BSD/GNU grep defect** in `grep -E -c --` or `( |$)`. The shell’s `\$` becomes the regex end anchor correctly.
- **The full Git-environment isolation cannot be certified.** The fixture-mutating `git -C "$IFX" ...` commands do not individually apply `UNSET_GIT_ENV`, but the excerpt explicitly refers to an earlier strip covering all children. The missing prologue and selftest path are required to determine whether inherited `GIT_DIR` can reach those commands. I am not asserting user-repository contamination from the excerpt alone.
- The five added expectations establish the **+5** count change. Recounting **317 total battery cases**, **233 portability cases**, and the inventory of skills/agents/rules requires the complete files or tree.
- The collaborators-only policy, Alessandro Spina and Lu Han credits, Blindspot rename, and clo-author release tag/date have support in **`f`, §D**. That excerpt does not establish all newly stated project capabilities, clo-author’s **25-agent/18-skill** inventory, or the repository adoption counts; the corresponding upstream snapshots are missing.
- The changelog’s claimed fixes to `check-links.py`, `.githooks/pre-commit`, and `_winsim.py` cannot be audited here: their implementation changes are absent from this diff. They could exist in earlier release commits; the required base-to-release changes are not supplied.
