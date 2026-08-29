# Statusline

Custom Claude Code status line: model, context usage, rate-limit windows, tokens, cache hit rate, cost, session duration.

## Files

- `statusline-command.sh` — the whole implementation. Reads the statusline JSON payload on stdin, prints ANSI-colored rows.
- `settings.json` → `statusLine` — points directly at `bash ~/.claude/statusline-command.sh`, with `refreshInterval: 5`.

### The vibe-ads wrapper is gone (was documented here, no longer true)

`settings.json` used to point at `.kickbacks/vibe-ads-statusline.mjs`, a wrapper that read
`~/.kickbacks/cli-prev-statusline.json` and spawned the real script from there. As of
2026-08-23 neither `~/.kickbacks/` nor that JSON file exists, and `settings.json` names the
shell script directly. Nothing to preserve — edit `statusline-command.sh` and point
`settings.json` wherever you like.

### The script spawns no subprocesses, and that is load-bearing

Claude Code **cancels an in-flight status line command when the next update triggers**, and a
script that produces no output leaves the status line blank. Both are documented behaviour:
["If a new update triggers while your script is still running, Claude Code cancels the in-flight
script"](https://code.claude.com/docs/en/statusline#how-status-lines-work) and ["Scripts that
exit with non-zero codes or produce no output cause the status line to go
blank"](https://code.claude.com/docs/en/statusline#troubleshooting). So runtime is not a
nice-to-have here — a script slower than the gap between updates renders *nothing at all*.

This bit hard on 2026-08-29. The script used to extract each field with
`$(echo "$input" | grep -o ... | sed ...)` — 3+ processes per field, ~50 for the file. Process
creation under Git Bash on Windows costs tens of ms even idle, so one run took ~2s. With
`refreshInterval: 2` re-running it every 2s **per session** and four Claude Code sessions open,
process creation saturated at ~400ms per spawn and a single run stretched to 12–20s. Every
invocation was cancelled long before it printed. Self-reinforcing: more overlap → slower spawns
→ longer runs → more overlap.

The fix was to remove the forks, not the timer. Measured on the same machine and payload:

| | subprocess cost (20 pipelines) | one statusline run |
|---|---|---|
| old script, `refreshInterval: 2`, 4 sessions | 8111 ms | 12003–19869 ms |
| old script, no `refreshInterval` | 1476 ms | 1886–2229 ms |
| **new script, `refreshInterval: 5`, 4 sessions** | **1141 ms** | **72–84 ms** |

So `refreshInterval` is back — it is what keeps the layout correct after a terminal resize (a
resize is *not* one of Claude Code's update triggers, so without the timer the row stays laid
out for the old width until the next assistant message).

It is set to **5**, not 2. At ~72 ms a run that is a ~69× margin rather than ~24×, and the
standing cost across four open sessions drops from 2.0 to 0.8 process spawns per second. The
cost of the slower timer is that a resize takes up to 5s to reflow instead of 2s, which is the
right trade: the timer is a safety net for an event Claude Code does not report, not something
you watch. Do not raise it much further — the countdown timers in the 5h/7d segments visibly
tick, and beyond ~10s they read as frozen.

**Rules for editing this script.** Its whole cost is now the `bash` interpreter starting up —
the body benchmarks within noise of `bash -c ':'`. Keep it that way:

- **No `$(...)` in the hot path.** Command substitution forks a subshell, which on Windows is
  the expensive part. The payload accessors are called as `jstr key; VAR=$REPLY`, never
  `VAR=$(jstr key)`, for exactly this reason.
- **No external binaries.** `grep`, `sed`, `awk`, `cut`, `date`, `cat` are all gone. Their
  replacements are `[[ =~ ]]` + `BASH_REMATCH`, `$(( ))`, `printf -v`, `printf '%(%s)T'`, and
  `read -r -d ''`. `$(( ))` is arithmetic expansion, not a subshell — it is free.
- **jq is the parser [the docs use](https://code.claude.com/docs/en/statusline#example-scripts),
  and it is not installed here.** If you install it, one `jq` call is still one fork; the
  bash-regex accessors are cheaper. Only reach for jq if the extraction gets too gnarly for
  regex.
- **If you must add something expensive** (`git status` is the classic), cache it to a temp file
  and refresh on an interval, as the [caching
  example](https://code.claude.com/docs/en/statusline#cache-expensive-operations) shows. Do not
  put it inline.

### Payload accessors

Four helpers near the top of the script, each leaving its result in `REPLY`:

| helper | matches | used for |
|---|---|---|
| `jstr k` | first `"k":"string"` | `display_name`, `session_name` |
| `jint k` | first `"k":<int>` | tokens, durations, cost fields |
| `jafter o k` | `"k":<int>` in the payload **after** `"o"` appears; binds even when null | `used_percentage` (context) |
| `jobj o k` | `"k":<int>` inside `"o":{...}` | rate-limit windows |

`jafter` exists for one specific trap, and it is worth understanding before touching it.
`used_percentage` appears **three times** in the payload — `context_window`, then each
rate-limit window — and an unanchored regex picks between them purely by position in the
string. Two ways that lied:

| payload | unanchored result | truth |
|---|---|---|
| `rate_limits` ordered before `context_window` | 11% | 13% |
| no `context_window` at all | 66% | 0% |

Both showed a **rate-limit number labelled as context usage** — confidently wrong, not blank,
which is the worst failure a status line can have. `jafter` discards everything up to the
container name with `${input#*...}` before matching, so a window before `context_window` is cut
away and one after it is never reached. Prefix removal is a parameter expansion, so anchoring
costs no fork; it is done by trimming the subject because bash ERE has no non-greedy
quantifier.

The `[0-9]*` inside it (zero-or-more, not one-or-more) is also deliberate: on
`"used_percentage":null` it matches zero digits and returns empty so `${PCT:-0}` applies, where
`+` would fail at that key and fall through to the next window's number.
`context_window.used_percentage` [can be null early in a
session](https://code.claude.com/docs/en/statusline#session-data), so this is live, not
hypothetical.

`jobj`'s `[^}]*` cannot cross a closing brace, so it can never leak a value from a sibling
rate-limit window.

## Layout: two groups, reflowed to terminal width

Output is **two segment groups** — live budget state first, session totals second. On a wide
terminal each group is one row, which is the historical two-line look:

```
● [Model] ██░░░░░░░░ 6% | 5h: ▓░░░░░░░░░ 6% (04:42:53) | 7d: ▒░░░░░░░░░ 1% (6d 23h) | ↑63.9k ↓0.5k | cache: 98%
probable cost $0.97 | session Active: 05:44 · ▸ Add weekly limit to status line display
```

Narrower than that, each group wraps onto indented continuation rows rather than being clipped:

```
● [Model] ██░░░░░░░░ 6% | 5h: ▓░░░░░░░░░ 6% (04:42:53)
  7d: ▒░░░░░░░░░ 1% (6d 23h) | ↑63.9k ↓0.5k | cache: 98%
probable cost $0.97 | session Active: 05:44 ·
  ▸ Add weekly limit to status line display
```

Groups always start their own row, so the "what's left / what's been spent" split survives at
every width. The two-space indent is what distinguishes a wrapped continuation from a new group.

### How the reflow works

**Claude Code clips a status row that overruns the terminal — it never soft-wraps.** Multi-row
status lines exist, but rows come from separate `echo`/`printf` calls; there is no way to hand
Claude Code a long string and have it fold. So the wrapping is done here.

- `WIDTH` resolves as `STATUSLINE_WIDTH` → `COLUMNS` → `100`, read as the very first statement
  in the script, before any external command can disturb it.
- `RESERVE=12` columns are held clear on the right, because Claude Code renders system
  notifications (MCP errors, auto-update notices, the verbose-mode token counter) on the right
  of the status row and they overwrite anything already there.
- `BUDGET = WIDTH - RESERVE`, floored at 24.
- Segments are registered with `seg <group> <separator> <colored> <plain>` and packed greedily
  by `pack_group`, breaking to an indented row when the next segment would overrun `BUDGET`.

**Every segment is stored twice — colored and plain — and only the plain form is measured.**
This is not redundancy. `${#}` counts the literal escape bytes (`\033[31m` is 8 characters, not
0), so measuring the colored form overstates group 1 by roughly 75 columns and every layout
decision comes out wrong. Any new segment must supply both forms.

A segment wider than `BUDGET` on its own is emitted anyway rather than dropped — one clipped
row beats a silently missing metric. Below roughly width 45 this starts happening to the 5h
segment.

**Group 1 — what's left:**

- **Health dot** — worst of context / 5h / 7d. Red ≥90, yellow ≥70.
- **Context bar** — glyph `█`, from `context_window.used_percentage`.
- **5h bar** — glyph `▓`, from `rate_limits.five_hour`, countdown as `HH:MM:SS`.
- **7d bar** — glyph `▒`, from `rate_limits.seven_day`, countdown as `Xd Yh` (or `Xh Ym` under a day).
- Three distinct glyphs so the bars stay tellable apart at a glance.
- Tokens (`↑in ↓out`) and cache hit rate.

**Group 2 — what's been spent:**

- Cost, session elapsed time, activity indicator.
- Each segment carries its own separator, applied only when something precedes it on the row —
  so partial payloads never produce a leading pipe, and a segment that starts a continuation
  row drops its separator.
- If every group-2 segment is absent, `pack_group 2` emits nothing at all — no blank row.
- Cost is labelled **"probable cost"** — it's Claude Code's own estimate derived from token
  counts, not a billed figure.
- The activity indicator is **fused into the duration segment**, not registered separately, so
  a lone `⚡` can never be wrapped onto a continuation row by itself. Its guard is a strict
  subset of the duration guard, so fusing cannot orphan it.

**Session name (last segment of group 2):**

- `session_name` from the payload, dim with a `▸` marker — context, not status, so it shouldn't
  compete with the bars.
- Separated by a plain space rather than a `|`, since the `▸` is itself the visual separator.
- The field is absent on unnamed sessions (not empty-string), in which case nothing is emitted
  — including the separating space.
- **Truncated to `BUDGET - indent - 2` with an `…`.** It is the only unbounded field in the
  payload, so it is the one segment that could still overrun a row after wrapping.

### Terminal width detection

Claude Code exports `COLUMNS` (and `LINES`) to the statusline process, set to the live terminal
dimensions — this is the documented mechanism and requires Claude Code v2.1.153 or later. It is
the only honest source: the payload carries no width field, and stdout is a pipe rather than a
TTY.

`tput cols` is **not** a usable fallback. It merely echoes `COLUMNS` back when that is set, and
reports a hardcoded terminfo `80` when it isn't — which looks like a real answer and is not.
That false `80` is the trap here: **running the script by hand has no `COLUMNS`**, so manual
tests render against the wrong width unless you pass `STATUSLINE_WIDTH` explicitly.

### Note on right-alignment (tried, reverted)

An earlier version padded the session name to the terminal's right edge. It worked, but a large
gap mid-statusline read worse than simply appending. Reverted to inline. The width-detection
findings from that attempt are folded into the section above.

### Activity indicator (`⚡` / `·`)

`total_api_duration_ms / total_duration_ms` — the share of session wall-clock spent inside API
calls. Over 50% → `⚡`, else `·`.

**It is not a live activity light**, despite appearances. Both figures are cumulative session
totals, so: it can never mean "Claude is working right now" (the statusline only re-renders
between turns); it *decays on its own* while the session sits idle, since the denominator keeps
growing; and long sessions trend toward `·` structurally because human reading/typing time
dominates wall clock. Read it as "has this session been API-dense overall". Showing true
per-turn activity isn't possible from this payload — it carries no per-turn durations, so it
would need the previous render's `total_api_duration_ms` cached to disk and diffed.

## Payload shape

Rate limits arrive in stdin already — no API call needed:

```json
"rate_limits": {
  "five_hour": {"used_percentage": 5, "resets_at": 1786828800},
  "seven_day": {"used_percentage": 0, "resets_at": 1787414400}
}
```

`resets_at` is a Unix timestamp. Both windows have identical shape, so a new window is a copy-paste of the extraction block plus its own time formatting.

## Testing

Payload capture is **gated behind `STATUSLINE_DEBUG`** — with `refreshInterval: 5` an ungated
write would hit disk every two seconds for the life of every session. Capture a fresh payload
once, then iterate against the file:

```bash
STATUSLINE_DEBUG=1 bash ~/.claude/statusline-command.sh < /tmp/statusline-debug.json
```

**Always pass `STATUSLINE_WIDTH` when testing layout** — a bare run has no `COLUMNS` and silently
falls back to 100, so wrapping will not match what you see live:

```bash
for W in 159 120 90 70; do
  echo "── $W ──"
  STATUSLINE_WIDTH=$W bash ~/.claude/statusline-command.sh < /tmp/statusline-debug.json
done
```

To check that no row overruns its budget, strip the ANSI and measure:

```bash
STATUSLINE_WIDTH=90 bash ~/.claude/statusline-command.sh < payload.json \
  | sed 's/\x1b\[[0-9;]*m//g' | awk '{printf "%3d| %s\n", length($0), $0}'
```

`/tmp/statusline-debug.json` is volatile — every concurrent Claude session overwrites it with
its own payload. Copy it aside before a test run that needs stable values.

To exercise color/time branches, copy that file and `sed` the `used_percentage` / `resets_at` values — live values are usually too low to trigger yellow or red.

### Regression-testing a rewrite

The 2026-08-29 fork removal was verified by diffing old against new over **25 payloads x 7
widths = 175 comparisons, 0 differences**. Worth repeating for any change that touches
extraction or layout:

1. Build fixtures from a captured payload with `json.dumps(obj, separators=(',', ':'))` —
   **compact**. Pretty-printed JSON puts a space after every colon, the accessors match nothing,
   and old and new then agree on garbage.
2. Cover the absent/null cases the docs call out: no `rate_limits`, no `seven_day`, no
   `session_name`, no `cost`, `current_usage: null`, `used_percentage: null`. Plus float
   percentages, zero/huge tokens, a 180-char session name, empty stdin, and non-JSON stdin.
3. Diff both scripts per fixture per width, **masking the countdowns** — they come from the wall
   clock, so a slow old script samples a different second and every future-reset case shows a
   spurious diff.

```bash
mask() { sed -E 's/\([0-9]+:[0-9]{2}:[0-9]{2}\)|\([0-9]+d [0-9]+h\)|\([0-9]+h [0-9]+m\)/(TIME)/g'; }
for f in cases/*.json; do for W in 200 159 120 100 80 60 40; do
  A=$(STATUSLINE_WIDTH=$W bash old.sh < "$f" 2>&1 | mask)
  B=$(STATUSLINE_WIDTH=$W bash new.sh < "$f" 2>&1 | mask)
  [ "$A" = "$B" ] || echo "MISMATCH $(basename "$f") W=$W"
done; done
```

Then confirm runtime separately — the point of the rewrite is speed, and a correct-but-slow
script still renders blank:

```bash
T=0; for i in $(seq 1 10); do S=$(date +%s%N)
  bash ~/.claude/statusline-command.sh < payload.json >/dev/null
  E=$(date +%s%N); T=$((T+(E-S)/1000000)); done; echo "mean: $((T/10)) ms"
```

It should land within noise of `bash -c ':'` on the same machine. Anything approaching
`refreshInterval` x 1000 ms means the status line will start going blank.

## Known issues / gotchas

- **Parsing is regex-based, not a JSON parser.** `jobj` relies on `[^}]*` not crossing an object
  boundary. If the payload ever nests another `{}` inside a rate-limit object, it silently
  returns empty and falls back to `0`.
- ~~Context percentage depends on key order~~ — **fixed 2026-08-29** by `jafter`, which anchors
  the lookup to `context_window`. Reordering the payload, or dropping `context_window`, now
  yields `0%` instead of a rate-limit number.
- The accessors match on `"key":value` with **no space after the colon**, which is what Claude
  Code emits. A pretty-printed payload matches nothing and every field falls back to its default.
  Generate test fixtures with compact separators or they prove nothing.
- Percentages capture `[0-9]+` and stop at the decimal point, so `9.9%` renders as `9%`.
- A `session_name` containing an escaped quote is cut at that quote — `[^"]*` stops there. Same
  behaviour as the grep it replaced.
- Bars are 10 chars at 10%-per-block, so any value under 10% shows a fully empty bar.
- The activity indicator's meaning is widely misread — see the section above before trusting it.
- **New segments must supply a plain form to `seg`.** Passing the colored string for both
  arguments does not error — it just makes every width calculation wrong by ~8 columns per
  escape, and the symptom is mysterious over-wrapping.
- Width measurement uses `${#var}`, a character count. Correct under `en_US.UTF-8` (verified:
  `${#}` on a 10-glyph bar returns 10, not its 30 bytes). Under a non-UTF-8 locale it would
  count bytes and over-wrap every row containing a bar.
- Bars are fixed at 10 chars and do not shrink on narrow terminals — three bars cost 30 columns
  regardless. Reflow was chosen over responsive bar-shrinking so no information is lost; if
  vertical space ever matters more than completeness, shrinking `FILLED`/`EMPTY` by tier is the
  alternative that was considered and rejected.
