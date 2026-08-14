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
RESET='\033[0m'

# Extract model and context
MODEL=$(echo "$input" | grep -o '"display_name":"[^"]*"' | head -1 | sed 's/"display_name":"//;s/"$//')

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

# Determine overall health status (worst of context or 5h)
if [ "$PCT" -ge 90 ] || [ "$FIVE_H" -ge 90 ]; then
  HEALTH_COLOR="$RED"; HEALTH_DOT="●"
elif [ "$PCT" -ge 70 ] || [ "$FIVE_H" -ge 70 ]; then
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

# Format output with color and health indicator
OUTPUT="${HEALTH_COLOR}$HEALTH_DOT${RESET} [${MODEL_COLOR}$MODEL${RESET}] ${CTX_COLOR}$CTX_BAR${RESET} $PCT% | 5h: ${FIVE_H_COLOR}$FIVE_H_BAR${RESET} $FIVE_H% (${FIVE_H_TIME})"

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

# Add cost if available
if [ -n "$COST" ] && [ "$COST" != "null" ]; then
  COST_FMT=$(printf '$%.2f' "$COST")
  OUTPUT="$OUTPUT | $COST_FMT"
fi

# Add duration if available
if [ -n "$DURATION_MS" ] && [ "$DURATION_MS" != "null" ] && [ "$DURATION_MS" -gt 0 ]; then
  DURATION_SEC=$((DURATION_MS / 1000))
  HOURS=$((DURATION_SEC / 3600))
  MINS=$(((DURATION_SEC % 3600) / 60))
  SECS=$((DURATION_SEC % 60))
  if [ "$HOURS" -ge 1 ]; then
    OUTPUT="$OUTPUT | session Active: $(printf "%02d:%02d:%02d" $HOURS $MINS $SECS)"
  else
    OUTPUT="$OUTPUT | session Active: $(printf "%02d:%02d" $MINS $SECS)"
  fi
fi

# Add activity indicator (show if API is/was recently active)
if [ -n "$API_DURATION" ] && [ "$API_DURATION" -gt 0 ]; then
  API_RATIO=$((API_DURATION * 100 / DURATION_MS))
  if [ "$API_RATIO" -gt 50 ]; then
    ACTIVITY="⚡" # Active/busy
  else
    ACTIVITY="·" # Idle
  fi
  OUTPUT="$OUTPUT $ACTIVITY"
fi

echo -e "$OUTPUT"
