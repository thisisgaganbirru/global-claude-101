#!/bin/bash
# Terminal width, read before anything else runs. Claude Code exports COLUMNS to
# the statusline process (verified live at 159) — the payload carries no width
# field and there is no TTY, so this env var is the only honest source. `tput
# cols` is not a fallback: it echoes COLUMNS back when set, and reports a
# hardcoded 80 when it is not. STATUSLINE_WIDTH is the manual-test override —
# running this script by hand has no COLUMNS, so without it every layout test
# would silently render against the wrong width.
WIDTH=${STATUSLINE_WIDTH:-${COLUMNS:-100}}

# Columns held clear on the right: Claude Code renders system notifications (MCP
# errors, auto-update notices, the verbose-mode token counter) on the right of
# the status row, and without a reserve they overwrite our tail.
RESERVE=12
BUDGET=$((WIDTH - RESERVE))
if [ "$BUDGET" -lt 24 ]; then BUDGET=24; fi

INDENT="  "

# Slurp stdin with the `read` builtin rather than `input=$(cat)`. The latter is
# both a `cat` process and a command-substitution subshell — the last two forks
# in the file. `-d ''` reads to EOF (the payload contains no NUL); read returns
# non-zero at EOF even on success, hence the `|| :`.
IFS= read -r -d '' input || :

# Payload capture for offline iteration. Gated: the statusLine refreshInterval
# re-runs this script every couple of seconds, and an ungated write would hit
# disk that often for the life of every session.
#   STATUSLINE_DEBUG=1 bash ~/.claude/statusline-command.sh < old-payload.json
if [ -n "$STATUSLINE_DEBUG" ]; then
  echo "$input" > /tmp/statusline-debug.json
fi

# ── Payload accessors (no subprocesses) ───────────────────────────────────────
# Every field below used to be pulled with `$(echo "$input" | grep -o ... | sed
# ...)`. That is 3+ processes per field and ~50 for the file. Process creation
# under Git Bash on Windows costs tens of ms even idle, which made a run take
# ~2s — and Claude Code CANCELS an in-flight status line command when the next
# update triggers, so a slow script renders nothing at all.
#
# jq is the parser the Claude Code docs use, but it is not installed here, so
# these use bash's own regex engine instead. `[[ =~ ]]` and BASH_REMATCH are
# builtins: matching against a ~1.3KB payload spawns nothing and costs
# microseconds. The regexes are the same ones the old greps used, so extraction
# behaviour is unchanged.
#
# All three return empty on no-match, which every caller already handles with
# `${VAR:-0}` or a `-n` guard.

# Each accessor leaves its result in REPLY and is called as `jstr key; VAR=$REPLY`
# rather than `jstr key; VAR=$REPLY`. That is deliberate: every $(...) is a command
# substitution, and a command substitution forks a subshell. Under Git Bash on
# Windows a fork is emulated and costs tens of ms, so 16 accessor calls in $(...)
# form would put back a third of the cost this rewrite removes. In REPLY form the
# whole extraction block spawns nothing at all.
#
# All four set REPLY to the empty string on no-match, which every caller already
# handles with `${VAR:-0}` or an `-n` guard.

# First "key":"string" in the payload.
jstr() { if [[ $input =~ \"$1\":\"([^\"]*)\" ]]; then REPLY=${BASH_REMATCH[1]}; else REPLY=; fi; }

# First "key":<integer>. Stops at a decimal point, which is what the old
# `cut -d. -f1` did. Matches nothing when the value is null, absent, or a string.
# Safe for keys that occur once, or where the caller only wants the first.
jint() { if [[ $input =~ \"$1\":([0-9]+) ]]; then REPLY=${BASH_REMATCH[1]}; else REPLY=; fi; }

# Like jint but binds to the FIRST occurrence of the key even when its value is
# null. Needed for "used_percentage", which appears three times (context_window,
# then each rate-limit window): with `[0-9]+` a null context percentage fails to
# match at the first key, and the leftmost-match rule silently hands back
# five_hour's number instead. `[0-9]*` matches zero digits there, so REPLY comes
# back empty and the caller's `${PCT:-0}` applies — the old grep's behaviour.
jint1() { if [[ $input =~ \"$1\":([0-9]*) ]]; then REPLY=${BASH_REMATCH[1]}; else REPLY=; fi; }

# First "key":<number>, decimals kept — for total_cost_usd, which needs %.2f.
jnum() { if [[ $input =~ \"$1\":([0-9.]+) ]]; then REPLY=${BASH_REMATCH[1]}; else REPLY=; fi; }

# "key":<integer> scoped to inside "object":{...}. `[^}]*` cannot cross the
# closing brace, so this cannot leak a value from a sibling rate-limit window.
jobj() { if [[ $input =~ \"$1\":\{[^}]*\"$2\":([0-9]+) ]]; then REPLY=${BASH_REMATCH[1]}; else REPLY=; fi; }

# Color codes
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
BLUE='\033[34m'
CYAN='\033[36m'
MAGENTA='\033[35m'
DIM='\033[2m'
RESET='\033[0m'

# Extract model and context
jstr display_name; MODEL=$REPLY

# Extract session name (absent on unnamed sessions — the segment is skipped then)
jstr session_name; SESSION_NAME=$REPLY

# Pick model color
case "$MODEL" in
  *Haiku*) MODEL_COLOR="$BLUE" ;;
  *Sonnet*) MODEL_COLOR="$CYAN" ;;
  *Opus*) MODEL_COLOR="$MAGENTA" ;;
  *) MODEL_COLOR="$GREEN" ;;
esac
# Extract context percentage (first used_percentage in the JSON)
jint1 used_percentage; PCT=$REPLY
PCT=${PCT:-0}

# Extract 5-hour rate limit
jobj five_hour used_percentage; FIVE_H=$REPLY
FIVE_H=${FIVE_H:-0}

# Extract 5h reset time
jobj five_hour resets_at; FIVE_H_RESET=$REPLY
FIVE_H_RESET_TS=${FIVE_H_RESET:-0}
# `%(...)T` is a bash 4.2+ printf format; Git Bash ships 5.2. It replaces a
# `date +%s` fork, which is worth it since this runs on every status line update.
# If a much older bash ever ends up on PATH the format is emitted literally rather
# than erroring, so validate before trusting it and fall back to the fork.
printf -v CURRENT_TS '%(%s)T' -1 2>/dev/null
[[ $CURRENT_TS =~ ^[0-9]+$ ]] || CURRENT_TS=$(date +%s)
FIVE_H_LEFT=$((FIVE_H_RESET_TS - CURRENT_TS))
if [ "$FIVE_H_LEFT" -lt 0 ]; then FIVE_H_LEFT=0; fi

# Extract 7-day (weekly) rate limit
jobj seven_day used_percentage; SEVEN_D=$REPLY
SEVEN_D=${SEVEN_D:-0}

# Extract 7d reset time
jobj seven_day resets_at; SEVEN_D_RESET=$REPLY
SEVEN_D_RESET_TS=${SEVEN_D_RESET:-0}
SEVEN_D_LEFT=$((SEVEN_D_RESET_TS - CURRENT_TS))
if [ "$SEVEN_D_LEFT" -lt 0 ]; then SEVEN_D_LEFT=0; fi

# Extract tokens
jint total_input_tokens; INPUT_TOKENS=$REPLY
jint total_output_tokens; OUTPUT_TOKENS=$REPLY

# Extract cache stats
# cache_read_input_tokens: tokens served from cache (system prompts, tools, previous context)
# cache_creation_input_tokens: new tokens being added to cache
# input_tokens: fresh tokens (not cached)
# Cache hit rate = cached tokens / (cached + new + fresh) × 100
# Higher % = more efficient, faster, cheaper (cached tokens cost ~90% less)
jint cache_read_input_tokens; CACHE_READ=$REPLY
jint cache_creation_input_tokens; CACHE_CREATE=$REPLY
jint input_tokens; CURRENT_INPUT=$REPLY

# Extract cost and duration
jnum total_cost_usd; COST=$REPLY
jint total_duration_ms; DURATION_MS=$REPLY
jint total_api_duration_ms; API_DURATION=$REPLY

# Pick bar color based on context usage
if [ "$PCT" -ge 90 ]; then CTX_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then CTX_COLOR="$YELLOW"
else CTX_COLOR="$GREEN"; fi

# Pick bar color based on 5h usage
if [ "$FIVE_H" -ge 90 ]; then FIVE_H_COLOR="$RED"
elif [ "$FIVE_H" -ge 70 ]; then FIVE_H_COLOR="$YELLOW"
else FIVE_H_COLOR="$GREEN"; fi

# Pick bar color based on 7d usage
if [ "$SEVEN_D" -ge 90 ]; then SEVEN_D_COLOR="$RED"
elif [ "$SEVEN_D" -ge 70 ]; then SEVEN_D_COLOR="$YELLOW"
else SEVEN_D_COLOR="$GREEN"; fi

# Build context progress bar
FILLED=$((PCT / 10))
EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"
printf -v PAD "%${EMPTY}s"
CTX_BAR="${FILL// /█}${PAD// /░}"

# Build 5h progress bar
FILLED=$((FIVE_H / 10))
EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"
printf -v PAD "%${EMPTY}s"
FIVE_H_BAR="${FILL// /▓}${PAD// /░}"

# Build 7d progress bar (distinct glyph so the three bars stay tellable apart)
FILLED=$((SEVEN_D / 10))
EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"
printf -v PAD "%${EMPTY}s"
SEVEN_D_BAR="${FILL// /▒}${PAD// /░}"

# Determine overall health status (worst of context, 5h, or 7d)
if [ "$PCT" -ge 90 ] || [ "$FIVE_H" -ge 90 ] || [ "$SEVEN_D" -ge 90 ]; then
  HEALTH_COLOR="$RED"; HEALTH_DOT="●"
elif [ "$PCT" -ge 70 ] || [ "$FIVE_H" -ge 70 ] || [ "$SEVEN_D" -ge 70 ]; then
  HEALTH_COLOR="$YELLOW"; HEALTH_DOT="●"
else
  HEALTH_COLOR="$GREEN"; HEALTH_DOT="●"
fi

# Format 5h time remaining
if [ "$FIVE_H_LEFT" -gt 0 ]; then
  FIVE_H_HOURS=$((FIVE_H_LEFT / 3600))
  FIVE_H_MINS=$(((FIVE_H_LEFT % 3600) / 60))
  FIVE_H_SECS=$((FIVE_H_LEFT % 60))
  printf -v FIVE_H_TIME "%02d:%02d:%02d" "$FIVE_H_HOURS" "$FIVE_H_MINS" "$FIVE_H_SECS"
else
  FIVE_H_TIME="reset"
fi

# Format 7d time remaining (spans days, so HH:MM:SS would be unreadable)
if [ "$SEVEN_D_LEFT" -gt 0 ]; then
  SEVEN_D_DAYS=$((SEVEN_D_LEFT / 86400))
  SEVEN_D_HOURS=$(((SEVEN_D_LEFT % 86400) / 3600))
  SEVEN_D_MINS=$(((SEVEN_D_LEFT % 3600) / 60))
  if [ "$SEVEN_D_DAYS" -gt 0 ]; then
    SEVEN_D_TIME="${SEVEN_D_DAYS}d ${SEVEN_D_HOURS}h"
  else
    SEVEN_D_TIME="${SEVEN_D_HOURS}h ${SEVEN_D_MINS}m"
  fi
else
  SEVEN_D_TIME="reset"
fi

# ── Segment model ─────────────────────────────────────────────────────────────
# Output is assembled from segments rather than one pre-joined string, so the
# packer below can decide where to break. Claude Code clips a status row that
# overruns the terminal — it never soft-wraps, and a resize does not re-run this
# script — so any wrapping has to happen here.
#
# Each segment is stored twice: the colored form that gets printed, and a plain
# form that gets measured. They cannot be the same string, because ${#} counts
# the literal escape bytes (\033[31m is 8 characters, not 0) and measuring the
# colored form would overstate group 1 by roughly 75 columns.
#
# Group 1 is live budget state, group 2 is session totals. Each group starts its
# own row, which preserves the two-line split; segments wrap onto indented
# continuation rows within a group.
SEG_GROUP=(); SEG_SEP=(); SEG_COLOR=(); SEG_PLAIN=()
seg() {
  SEG_GROUP+=("$1"); SEG_SEP+=("$2"); SEG_COLOR+=("$3"); SEG_PLAIN+=("$4")
}

# ── Group 1: budget remaining ──
seg 1 ""    "${HEALTH_COLOR}${HEALTH_DOT}${RESET} [${MODEL_COLOR}${MODEL}${RESET}]" "${HEALTH_DOT} [${MODEL}]"
seg 1 " "   "${CTX_COLOR}${CTX_BAR}${RESET} ${PCT}%" "${CTX_BAR} ${PCT}%"
seg 1 " | " "5h: ${FIVE_H_COLOR}${FIVE_H_BAR}${RESET} ${FIVE_H}% (${FIVE_H_TIME})" "5h: ${FIVE_H_BAR} ${FIVE_H}% (${FIVE_H_TIME})"
seg 1 " | " "7d: ${SEVEN_D_COLOR}${SEVEN_D_BAR}${RESET} ${SEVEN_D}% (${SEVEN_D_TIME})" "7d: ${SEVEN_D_BAR} ${SEVEN_D}% (${SEVEN_D_TIME})"

# Add tokens if available
if [ -n "$INPUT_TOKENS" ] && [ "$INPUT_TOKENS" != "null" ] && [ -n "$OUTPUT_TOKENS" ] && [ "$OUTPUT_TOKENS" != "null" ]; then
  # Rounded tenths-of-k without awk: (n + 50) / 100 rounds half-up, then the
  # last digit is split off as the decimal. Reproduces awk's %.1f exactly.
  IN_T=$(( (INPUT_TOKENS + 50) / 100 ));  printf -v INPUT_K  '%d.%d' "$((IN_T / 10))"  "$((IN_T % 10))"
  OUT_T=$(( (OUTPUT_TOKENS + 50) / 100 )); printf -v OUTPUT_K '%d.%d' "$((OUT_T / 10))" "$((OUT_T % 10))"
  seg 1 " | " "↑${INPUT_K}k ↓${OUTPUT_K}k" "↑${INPUT_K}k ↓${OUTPUT_K}k"

  # Add cache hit rate if available
  if [ -n "$CACHE_READ" ] && [ -n "$CACHE_CREATE" ] && [ -n "$CURRENT_INPUT" ]; then
    TOTAL_INPUT=$((CACHE_READ + CACHE_CREATE + CURRENT_INPUT))
    if [ "$TOTAL_INPUT" -gt 0 ]; then
      # Adding half the divisor before dividing rounds half-up, as awk's %.0f does.
      CACHE_PCT=$(( (CACHE_READ * 100 + TOTAL_INPUT / 2) / TOTAL_INPUT ))
      seg 1 " | " "cache: ${CACHE_PCT}%" "cache: ${CACHE_PCT}%"
    fi
  fi
fi

# ── Group 2: session totals (cost, elapsed, API density) ──

# Add cost if available. Labelled "probable cost" because this is Claude Code's
# own estimate from token counts, not a billed figure.
if [ -n "$COST" ] && [ "$COST" != "null" ]; then
  printf -v COST_FMT 'probable cost $%.2f' "$COST"
  seg 2 "" "$COST_FMT" "$COST_FMT"
fi

# Activity indicator — share of total session wall-clock spent inside API calls.
# Cumulative for the whole session, NOT a live/recent-activity light: it decays
# on its own while the session sits idle.
# DURATION_MS is guarded here too, since it is the divisor.
#
# Computed ahead of the duration segment so it can be fused into it below. Its
# guard is a strict subset of the duration guard, so it can never be orphaned by
# a missing duration — and fusing keeps a lone "⚡" from being wrapped onto a
# continuation row of its own.
ACTIVITY=""
if [ -n "$API_DURATION" ] && [ "$API_DURATION" -gt 0 ] && [ -n "$DURATION_MS" ] && [ "$DURATION_MS" -gt 0 ]; then
  API_RATIO=$((API_DURATION * 100 / DURATION_MS))
  if [ "$API_RATIO" -gt 50 ]; then
    ACTIVITY=" ⚡" # API-dense session
  else
    ACTIVITY=" ·" # Mostly idle/human time
  fi
fi

# Add duration if available
if [ -n "$DURATION_MS" ] && [ "$DURATION_MS" != "null" ] && [ "$DURATION_MS" -gt 0 ]; then
  DURATION_SEC=$((DURATION_MS / 1000))
  HOURS=$((DURATION_SEC / 3600))
  MINS=$(((DURATION_SEC % 3600) / 60))
  SECS=$((DURATION_SEC % 60))
  if [ "$HOURS" -ge 1 ]; then
    printf -v DURATION_FMT "%02d:%02d:%02d" "$HOURS" "$MINS" "$SECS"
  else
    printf -v DURATION_FMT "%02d:%02d" "$MINS" "$SECS"
  fi
  seg 2 " | " "session Active: ${DURATION_FMT}${ACTIVITY}" "session Active: ${DURATION_FMT}${ACTIVITY}"
fi

# Session name, dim with a ▸ marker so it reads as context rather than status.
# Absent on unnamed sessions. The ▸ is its own visual separator, hence a plain
# space rather than the usual pipe.
#
# Truncated to the row budget: it is the only unbounded field in the payload, so
# it is the one segment that could still overrun a row on its own after wrapping.
if [ -n "$SESSION_NAME" ]; then
  NAME_MAX=$((BUDGET - ${#INDENT} - 2))
  if [ "$NAME_MAX" -lt 8 ]; then NAME_MAX=8; fi
  if [ ${#SESSION_NAME} -gt "$NAME_MAX" ]; then
    SESSION_NAME="${SESSION_NAME:0:$((NAME_MAX - 1))}…"
  fi
  seg 2 " " "${DIM}▸ ${SESSION_NAME}${RESET}" "▸ ${SESSION_NAME}"
fi

# ── Packer ────────────────────────────────────────────────────────────────────
# WIDTH / RESERVE / BUDGET / INDENT are set at the top of the script, because the
# session-name segment needs BUDGET to size its truncation.
#
# Emit one group, breaking to an indented continuation row whenever the next
# segment would overrun BUDGET. A segment wider than BUDGET on its own is placed
# anyway rather than dropped — better one clipped row than a lost segment.
pack_group() {
  local group="$1"
  local row="" width=0 i sep need
  for i in "${!SEG_GROUP[@]}"; do
    [ "${SEG_GROUP[$i]}" = "$group" ] || continue
    if [ -z "$row" ]; then sep=""; else sep="${SEG_SEP[$i]}"; fi
    need=$(( ${#sep} + ${#SEG_PLAIN[$i]} ))
    if [ -n "$row" ] && [ $((width + need)) -gt "$BUDGET" ]; then
      printf '%b\n' "$row"
      row="$INDENT"; width=${#INDENT}
      sep=""; need=${#SEG_PLAIN[$i]}
    fi
    row="${row}${sep}${SEG_COLOR[$i]}"
    width=$((width + need))
  done
  # Nothing emitted when the group is entirely absent — no stray blank row.
  if [ -n "$row" ]; then printf '%b\n' "$row"; fi
}

pack_group 1
pack_group 2
