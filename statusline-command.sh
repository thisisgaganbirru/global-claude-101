#!/bin/bash
input=$(cat)

# Debug: save JSON to file to inspect structure
echo "$input" > /tmp/statusline-debug.json

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
MODEL=$(echo "$input" | grep -o '"display_name":"[^"]*"' | head -1 | sed 's/"display_name":"//;s/"$//')

# Extract session name (absent on unnamed sessions — line 3 is skipped then)
SESSION_NAME=$(echo "$input" | grep -o '"session_name":"[^"]*"' | head -1 | sed 's/"session_name":"//;s/"$//')

# Pick model color
case "$MODEL" in
  *Haiku*) MODEL_COLOR="$BLUE" ;;
  *Sonnet*) MODEL_COLOR="$CYAN" ;;
  *Opus*) MODEL_COLOR="$MAGENTA" ;;
  *) MODEL_COLOR="$GREEN" ;;
esac
# Extract context percentage (first used_percentage in the JSON)
PCT=$(echo "$input" | grep -o '"used_percentage":[0-9]*' | head -1 | sed 's/"used_percentage"://')
PCT=${PCT:-0}

# Extract 5-hour rate limit
FIVE_H=$(echo "$input" | grep -o '"rate_limits":[^}]*"five_hour":[^}]*"used_percentage":[0-9.]*' | sed 's/.*"used_percentage"://' | cut -d. -f1)
FIVE_H=${FIVE_H:-0}

# Extract 5h reset time
FIVE_H_RESET=$(echo "$input" | grep -o '"five_hour":[^}]*"resets_at":[0-9]*' | grep -o '[0-9]*$')
FIVE_H_RESET_TS=${FIVE_H_RESET:-0}
CURRENT_TS=$(date +%s)
FIVE_H_LEFT=$((FIVE_H_RESET_TS - CURRENT_TS))
if [ "$FIVE_H_LEFT" -lt 0 ]; then FIVE_H_LEFT=0; fi

# Extract 7-day (weekly) rate limit
SEVEN_D=$(echo "$input" | grep -o '"seven_day":[^}]*"used_percentage":[0-9.]*' | sed 's/.*"used_percentage"://' | cut -d. -f1)
SEVEN_D=${SEVEN_D:-0}

# Extract 7d reset time
SEVEN_D_RESET=$(echo "$input" | grep -o '"seven_day":[^}]*"resets_at":[0-9]*' | grep -o '[0-9]*$')
SEVEN_D_RESET_TS=${SEVEN_D_RESET:-0}
SEVEN_D_LEFT=$((SEVEN_D_RESET_TS - CURRENT_TS))
if [ "$SEVEN_D_LEFT" -lt 0 ]; then SEVEN_D_LEFT=0; fi

# Extract tokens
INPUT_TOKENS=$(echo "$input" | grep -o '"total_input_tokens":[0-9]*' | sed 's/"total_input_tokens"://')
OUTPUT_TOKENS=$(echo "$input" | grep -o '"total_output_tokens":[0-9]*' | sed 's/"total_output_tokens"://')

# Extract cache stats
# cache_read_input_tokens: tokens served from cache (system prompts, tools, previous context)
# cache_creation_input_tokens: new tokens being added to cache
# input_tokens: fresh tokens (not cached)
# Cache hit rate = cached tokens / (cached + new + fresh) × 100
# Higher % = more efficient, faster, cheaper (cached tokens cost ~90% less)
CACHE_READ=$(echo "$input" | grep -o '"cache_read_input_tokens":[0-9]*' | sed 's/"cache_read_input_tokens"://')
CACHE_CREATE=$(echo "$input" | grep -o '"cache_creation_input_tokens":[0-9]*' | sed 's/"cache_creation_input_tokens"://')
CURRENT_INPUT=$(echo "$input" | grep -o '"input_tokens":[0-9]*' | sed 's/"input_tokens"://')

# Extract cost and duration
COST=$(echo "$input" | grep -o '"total_cost_usd":[0-9.]*' | sed 's/"total_cost_usd"://')
DURATION_MS=$(echo "$input" | grep -o '"total_duration_ms":[0-9]*' | sed 's/"total_duration_ms"://')
API_DURATION=$(echo "$input" | grep -o '"total_api_duration_ms":[0-9]*' | sed 's/"total_api_duration_ms"://')

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
  FIVE_H_TIME="$(printf "%02d:%02d:%02d" $FIVE_H_HOURS $FIVE_H_MINS $FIVE_H_SECS)"
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

# Format output with color and health indicator
OUTPUT="${HEALTH_COLOR}$HEALTH_DOT${RESET} [${MODEL_COLOR}$MODEL${RESET}] ${CTX_COLOR}$CTX_BAR${RESET} $PCT% | 5h: ${FIVE_H_COLOR}$FIVE_H_BAR${RESET} $FIVE_H% (${FIVE_H_TIME}) | 7d: ${SEVEN_D_COLOR}$SEVEN_D_BAR${RESET} $SEVEN_D% (${SEVEN_D_TIME})"

# Add tokens if available
if [ -n "$INPUT_TOKENS" ] && [ "$INPUT_TOKENS" != "null" ] && [ -n "$OUTPUT_TOKENS" ] && [ "$OUTPUT_TOKENS" != "null" ]; then
  INPUT_K=$(awk "BEGIN {printf \"%.1f\", $INPUT_TOKENS/1000}")
  OUTPUT_K=$(awk "BEGIN {printf \"%.1f\", $OUTPUT_TOKENS/1000}")
  OUTPUT="$OUTPUT | ↑${INPUT_K}k ↓${OUTPUT_K}k"

  # Add cache hit rate if available
  if [ -n "$CACHE_READ" ] && [ -n "$CACHE_CREATE" ] && [ -n "$CURRENT_INPUT" ]; then
    TOTAL_INPUT=$((CACHE_READ + CACHE_CREATE + CURRENT_INPUT))
    if [ "$TOTAL_INPUT" -gt 0 ]; then
      CACHE_PCT=$(awk "BEGIN {printf \"%.0f\", $CACHE_READ * 100 / $TOTAL_INPUT}")
      OUTPUT="$OUTPUT | cache: ${CACHE_PCT}%"
    fi
  fi
fi

# ── Second line: session totals (cost, elapsed, API density) ──
# Everything past the cache segment wraps to its own line to keep line 1 readable.
LINE2=""

# Add cost if available. Labelled "probable cost" because this is Claude Code's
# own estimate from token counts, not a billed figure.
if [ -n "$COST" ] && [ "$COST" != "null" ]; then
  COST_FMT=$(printf 'probable cost $%.2f' "$COST")
  LINE2="$COST_FMT"
fi

# Add duration if available
if [ -n "$DURATION_MS" ] && [ "$DURATION_MS" != "null" ] && [ "$DURATION_MS" -gt 0 ]; then
  DURATION_SEC=$((DURATION_MS / 1000))
  HOURS=$((DURATION_SEC / 3600))
  MINS=$(((DURATION_SEC % 3600) / 60))
  SECS=$((DURATION_SEC % 60))
  if [ "$HOURS" -ge 1 ]; then
    DURATION_FMT="$(printf "%02d:%02d:%02d" $HOURS $MINS $SECS)"
  else
    DURATION_FMT="$(printf "%02d:%02d" $MINS $SECS)"
  fi
  if [ -n "$LINE2" ]; then LINE2="$LINE2 | "; fi
  LINE2="${LINE2}session Active: $DURATION_FMT"
fi

# Add activity indicator — share of total session wall-clock spent inside API
# calls. Cumulative for the whole session, NOT a live/recent-activity light:
# it decays on its own while the session sits idle.
# DURATION_MS is guarded here too, since it is the divisor.
if [ -n "$API_DURATION" ] && [ "$API_DURATION" -gt 0 ] && [ -n "$DURATION_MS" ] && [ "$DURATION_MS" -gt 0 ]; then
  API_RATIO=$((API_DURATION * 100 / DURATION_MS))
  if [ "$API_RATIO" -gt 50 ]; then
    ACTIVITY="⚡" # API-dense session
  else
    ACTIVITY="·" # Mostly idle/human time
  fi
  LINE2="$LINE2 $ACTIVITY"
fi

# Append session name inline, right after the activity indicator. Dim with a ▸
# marker so it reads as context rather than status. Absent on unnamed sessions.
if [ -n "$SESSION_NAME" ]; then
  if [ -n "$LINE2" ]; then LINE2="$LINE2 "; fi
  LINE2="${LINE2}${DIM}▸ ${SESSION_NAME}${RESET}"
fi

echo -e "$OUTPUT"
if [ -n "$LINE2" ]; then
  echo -e "$LINE2"
fi
