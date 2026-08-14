# PreCommitCheck.ps1 - Enforce mem entries before committing code changes
# This checks if code files changed but no /mem/ entry exists for today
# Run this as a pre-commit hook to prevent committing without documentation

param(
    [string]$MemDir = "./mem",
    [switch]$Enforce = $false
)

# Get today's date
$Today = Get-Date -Format "yyyyMMdd"

# Check if we're in a git repo
$GitRoot = git rev-parse --show-toplevel 2>$null
if (-not $GitRoot) {
    Write-Host "⚠️  Not in a git repository. Skipping pre-commit check." -ForegroundColor Yellow
    exit 0
}

# Get list of changed files (staged only)
$ChangedFiles = git diff --cached --name-only 2>$null | Where-Object {
    $_ -notmatch '^mem/' -and $_ -notmatch '\.md$' -and $_ -notmatch '\.gitignore$'
}

if (-not $ChangedFiles -or $ChangedFiles.Count -eq 0) {
    # Only docs or mem files changed, OK to commit
    exit 0
}

Write-Host "📝 Code files detected in this commit." -ForegroundColor Cyan

# Check if a /mem/ entry exists for today
$MemExists = Test-Path (Join-Path $MemDir "${Today}-*.md") -PathType Leaf

if (-not $MemExists) {
    Write-Host ""
    Write-Host "⚠️  No /mem/ entry found for today ($Today)." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Before committing code changes, document your work:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1. Create: mem/${Today}-task-name.md" -ForegroundColor Cyan
    Write-Host "  2. Include: The Ask, Changes Made, Decisions, Architecture" -ForegroundColor Cyan
    Write-Host "  3. Then commit again" -ForegroundColor Cyan
    Write-Host ""

    if ($Enforce) {
        Write-Host "Commit blocked. Add a /mem/ entry first." -ForegroundColor Red
        exit 1
    } else {
        Write-Host "⏭️  Bypassing check (enforcement disabled). Consider enabling with --enforce." -ForegroundColor Yellow
        exit 0
    }
} else {
    Write-Host "✓ /mem/ entry found for today" -ForegroundColor Green
    exit 0
}
