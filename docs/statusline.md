# Statusline

Custom Claude Code status line: model, context usage, rate-limit windows, tokens, cache hit rate, cost, session duration.

## Files

- `statusline-command.sh` — the whole implementation. Reads the statusline JSON payload on stdin, prints one ANSI-colored line.
- `settings.json` → `statusLine` — points at `.kickbacks/vibe-ads-statusline.mjs`, **not** at this script directly.
- `~/.kickbacks/cli-prev-statusline.json` — holds `{"statusLine":{"command":"bash ~/.claude/statusline-command.sh"}}`.

### Why the indirection matters

The vibe-ads statusline is a *wrapper*. It reads `cli-prev-statusline.json` and spawns whatever command it finds there, appending its own output. So `statusline-command.sh` is still the file to edit — despite `settings.json` naming a different script. Don't "fix" `settings.json` to point back at the shell script; that would drop the wrapper.

## Current segments

Output is **two lines** — live budget state on line 1, session totals on line 2:

```
● [Model] ██░░░░░░░░ 6% | 5h: ▓░░░░░░░░░ 6% (04:42:53) | 7d: ▒░░░░░░░░░ 1% (6d 23h) | ↑63.9k ↓0.5k | cache: 98%
probable cost $0.97 | session Active: 05:44 · ▸ Add weekly limit to status line display
```

**Line 1 — what's left:**

- **Health dot** — worst of context / 5h / 7d. Red ≥90, yellow ≥70.
- **Context bar** — glyph `█`, from `context_window.used_percentage`.
- **5h bar** — glyph `▓`, from `rate_limits.five_hour`, countdown as `HH:MM:SS`.
- **7d bar** — glyph `▒`, from `rate_limits.seven_day`, countdown as `Xd Yh` (or `Xh Ym` under a day).
- Three distinct glyphs so the bars stay tellable apart at a glance.
- Tokens (`↑in ↓out`) and cache hit rate.

**Line 2 — what's been spent:**

- Cost, session elapsed time, activity indicator.
- Built in `LINE2`, which starts empty; each segment adds its own `|` separator only when
  something precedes it, so partial payloads don't produce a leading pipe.
- If every line-2 segment is absent, `LINE2` stays empty and the second `echo` is skipped —
  no trailing blank line.

- Cost is labelled **"probable cost"** — it's Claude Code's own estimate derived from token
  counts, not a billed figure.

**Session name (inline, last on line 2):**

- `session_name` from the payload, dim with a `▸` marker — context, not status, so it shouldn't
  compete with the bars.
- Sits immediately after the activity indicator, separated by a plain space (the `▸` is itself
  the visual separator, so no `|`).
- The field is absent on unnamed sessions (not empty-string), in which case nothing is emitted
  — including the separating space.

### Note on right-alignment (tried, reverted)

An earlier version padded the session name to the terminal's right edge. It worked — Claude Code
exports `COLUMNS` when invoking the statusline (`COLUMNS=[159] tput=[159] TERM=[xterm-256color]
tty=no`), so width is detectable despite there being no TTY — but a large gap mid-statusline
read worse than simply appending. Reverted to inline.

Worth knowing if it's ever revisited: padding was computed from `${#LINE2}`, a character count
that is only a valid visible-width proxy because line 2 carries no ANSI escapes on its left
side. Adding color to the cost or duration segments would have silently broken it. Also, running
the script by hand reports width `80` (no `COLUMNS`, no TTY outside a real render), so manual
tests of any alignment work will mislead unless `COLUMNS` is set explicitly.

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

Line 5 of the script writes every payload to `/tmp/statusline-debug.json`, so you can iterate offline:

```bash
bash ~/.claude/statusline-command.sh < /tmp/statusline-debug.json
```

To exercise color/time branches, copy that file and `sed` the `used_percentage` / `resets_at` values — live values are usually too low to trigger yellow or red.

## Known issues / gotchas

- **Parsing is grep-based, not a JSON parser.** The `five_hour` / `seven_day` extractors rely on `[^}]*` not crossing an object boundary. If the payload ever nests another `{}` inside a rate-limit object, these silently return empty and fall back to `0`.
- `PCT` uses `grep ... | head -1` on `used_percentage`, which works only because `context_window` appears before `rate_limits` in the payload. Field reordering upstream would break it.
- Percentages are truncated with `cut -d. -f1`, so `9.9%` renders as `9%`.
- Bars are 10 chars at 10%-per-block, so any value under 10% shows a fully empty bar.
- The activity indicator's meaning is widely misread — see the section above before trusting it.
