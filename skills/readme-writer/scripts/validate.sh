#!/usr/bin/env bash
# readme-writer/scripts/validate.sh
#
# Runs all README validation checks against a given file.
# Usage: ./validate.sh [path/to/README.md] [--fix]
#
# Checks:
#   1. markdownlint   — style/structure rules
#   2. markdown-link-check — broken link detection
#   3. Custom grep checks — banned words, missing sections, bad patterns
#
# Exit codes:
#   0 = all checks passed
#   1 = warnings only (non-blocking issues found)
#   2 = errors found (blocking issues)
#
# Dependencies (auto-installed if missing via npx):
#   - markdownlint-cli  (npm)
#   - markdown-link-check (npm)

set -euo pipefail

# ─── Args ────────────────────────────────────────────────────────────────────

README="${1:-README.md}"
FIX_MODE="${2:-}"
ERRORS=0
WARNINGS=0

# Colour helpers (disabled if no TTY)
if [ -t 1 ]; then
  RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
  CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
else
  RED=''; YELLOW=''; GREEN=''; CYAN=''; BOLD=''; RESET=''
fi

err()  { echo -e "${RED}[ERROR]${RESET} $*"; ((ERRORS++)); }
warn() { echo -e "${YELLOW}[WARN]${RESET}  $*"; ((WARNINGS++)); }
ok()   { echo -e "${GREEN}[OK]${RESET}    $*"; }
info() { echo -e "${CYAN}[INFO]${RESET}   $*"; }

echo -e "${BOLD}README Validator — ${README}${RESET}"
echo "──────────────────────────────────────────"

# ─── Preflight ───────────────────────────────────────────────────────────────

if [ ! -f "$README" ]; then
  err "File not found: $README"
  exit 2
fi

LINES=$(wc -l < "$README")
info "File: $README ($LINES lines)"
echo ""

# ─── Check 1: markdownlint ───────────────────────────────────────────────────

echo -e "${BOLD}1. Markdown Lint${RESET}"

# Write a .markdownlint.json config inline (project-appropriate rules)
MLCONFIG=$(mktemp /tmp/mlconfig.XXXXXX.json)
cat > "$MLCONFIG" <<'EOF'
{
  "default": true,
  "MD013": false,
  "MD033": {
    "allowed_elements": ["picture", "source", "img", "details", "summary",
                         "br", "div", "blockquote", "sup", "sub", "kbd",
                         "p", "a", "table", "thead", "tbody", "tr", "th", "td"]
  },
  "MD041": false,
  "MD024": { "siblings_only": true },
  "MD007": { "indent": 2 },
  "MD030": false
}
EOF

if npx --yes markdownlint-cli "$README" --config "$MLCONFIG" 2>&1; then
  ok "markdownlint passed"
else
  if [ "$FIX_MODE" = "--fix" ]; then
    info "Running markdownlint --fix..."
    npx markdownlint-cli "$README" --config "$MLCONFIG" --fix 2>&1 || true
    warn "markdownlint: auto-fixed where possible — review changes"
  else
    err "markdownlint: issues found (run with --fix to auto-correct style issues)"
  fi
fi
rm -f "$MLCONFIG"
echo ""

# ─── Check 2: Link checker ───────────────────────────────────────────────────

echo -e "${BOLD}2. Link Check${RESET}"

LINKCONFIG=$(mktemp /tmp/linkcheck.XXXXXX.json)
cat > "$LINKCONFIG" <<'EOF'
{
  "ignorePatterns": [
    { "pattern": "^https://img.shields.io" },
    { "pattern": "^https://codecov.io" },
    { "pattern": "^https://coveralls.io" },
    { "pattern": "^https://localhost" },
    { "pattern": "^http://localhost" },
    { "pattern": "^https://pkg.go.dev" },
    { "pattern": "^mailto:" }
  ],
  "retryOn429": true,
  "retryCount": 2,
  "fallbackRetryDelay": "30s",
  "aliveStatusCodes": [200, 206, 999]
}
EOF

LINK_OUTPUT=$(npx --yes markdown-link-check "$README" --config "$LINKCONFIG" 2>&1 || true)
DEAD_COUNT=$(echo "$LINK_OUTPUT" | grep -c "✖" || true)
ALIVE_COUNT=$(echo "$LINK_OUTPUT" | grep -c "✓" || true)

if [ "$DEAD_COUNT" -gt 0 ]; then
  warn "Link check: $DEAD_COUNT dead link(s) found, $ALIVE_COUNT alive"
  echo "$LINK_OUTPUT" | grep "✖" | sed 's/^/    /'
else
  ok "Link check: all $ALIVE_COUNT links alive"
fi
rm -f "$LINKCONFIG"
echo ""

# ─── Check 3: Custom content checks ──────────────────────────────────────────

echo -e "${BOLD}3. Content Quality Checks${RESET}"

# 3a. H1 exists
if grep -qE "^# " "$README"; then
  ok "H1 heading present"
else
  err "Missing H1 heading — project name must be an H1 at the top"
fi

# 3b. License section
if grep -qiE "^#{1,3} licen(s|c)e" "$README"; then
  ok "License section present"
else
  err "Missing License section — required in every README"
fi

# 3c. Installation section
if grep -qiE "^#{1,3} (install|getting started|quick start|setup)" "$README"; then
  ok "Installation/Getting Started section present"
else
  warn "No Installation or Getting Started section found"
fi

# 3d. Code blocks have language hints
FENCED_TOTAL=$(grep -c '^\s*```' "$README" 2>/dev/null || true)
FENCED_NAKED=$(grep -cE '^\s*```\s*$' "$README" 2>/dev/null || true)
if [ "$FENCED_NAKED" -gt 0 ]; then
  warn "$FENCED_NAKED code block(s) missing language hints (use \`\`\`bash, \`\`\`python, etc.)"
else
  ok "All $((FENCED_TOTAL / 2)) code blocks have language hints"
fi

# 3e. Banned marketing words
BANNED=("blazing fast" "blazing-fast" "enterprise-grade" "enterprise grade" \
        "cutting-edge" "cutting edge" "world-class" "world class" \
        "seamless" "intuitive" "powerful" "next-gen" "next gen" \
        "game-changer" "game changer" "revolutionary")

BANNED_FOUND=()
for word in "${BANNED[@]}"; do
  if grep -qi "$word" "$README"; then
    BANNED_FOUND+=("$word")
  fi
done

if [ ${#BANNED_FOUND[@]} -gt 0 ]; then
  warn "Marketing language detected: ${BANNED_FOUND[*]}"
  warn "Replace with specific, evidence-backed claims"
else
  ok "No marketing language detected"
fi

# 3f. 'easy/simple/obviously/just' smell words
SMELL_WORDS=()
for w in "easy" "simple" "simply" "obviously" "trivial"; do
  if grep -qwi "$w" "$README"; then
    SMELL_WORDS+=("$w")
  fi
done
if [ ${#SMELL_WORDS[@]} -gt 0 ]; then
  warn "Condescending words found: ${SMELL_WORDS[*]}"
  warn "These alienate users who struggle. Remove them."
else
  ok "No condescending language detected"
fi

# 3g. Mermaid theme directives
if grep -qE '%%\{.*"theme"' "$README"; then
  err "Mermaid 'theme' directive found — this breaks GitHub dark mode. Remove it."
else
  ok "No Mermaid theme directives"
fi

# 3h. Deprecated 'graph' keyword in Mermaid
if grep -qE '^\s*graph (TD|LR|BT|RL)' "$README"; then
  warn "Deprecated Mermaid 'graph' keyword found — use 'flowchart TD/LR' instead"
else
  ok "No deprecated Mermaid graph syntax"
fi

# 3i. Architecture-beta diagrams (won't render on GitHub)
if grep -q 'architecture-beta' "$README"; then
  err "'architecture-beta' Mermaid diagram found — does NOT render on GitHub. Use flowchart instead."
else
  ok "No architecture-beta diagrams"
fi

# 3j. Relative vs absolute GitHub links (check for hardcoded github.com links to own repo files)
ABS_LINKS=$(grep -oE 'https://github\.com/[^/]+/[^/]+/blob/[^)]+' "$README" | wc -l || true)
if [ "$ABS_LINKS" -gt 2 ]; then
  warn "$ABS_LINKS absolute GitHub blob links found — prefer relative paths (./docs/file.md)"
  warn "Absolute links break on forks and mirrors"
else
  ok "Link style looks good (relative paths preferred)"
fi

# 3k. Badge count
BADGE_COUNT=$(grep -oE '!\[.*?\]\(https://img\.shields\.io[^)]+\)' "$README" | wc -l || true)
if [ "$BADGE_COUNT" -gt 10 ]; then
  warn "Badge count: $BADGE_COUNT — consider reducing to 5–8 for cleaner first impression"
elif [ "$BADGE_COUNT" -eq 0 ]; then
  info "No shields.io badges found (fine for internal/minimal projects)"
else
  ok "Badge count: $BADGE_COUNT (within recommended 5–8)"
fi

echo ""

# ─── Summary ─────────────────────────────────────────────────────────────────

echo "──────────────────────────────────────────"
echo -e "${BOLD}Summary${RESET}"

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  echo -e "${GREEN}✓ All checks passed. README is clean.${RESET}"
  exit 0
elif [ "$ERRORS" -eq 0 ]; then
  echo -e "${YELLOW}⚠ $WARNINGS warning(s), 0 errors. Review warnings above.${RESET}"
  exit 1
else
  echo -e "${RED}✗ $ERRORS error(s), $WARNINGS warning(s). Fix errors before publishing.${RESET}"
  exit 2
fi
