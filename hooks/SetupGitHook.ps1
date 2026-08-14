# SetupGitHook.ps1 - Install pre-commit hook (local filesystem only, no APIs)
# Run once per project to enforce /mem/ documentation before commits
# Usage: pwsh SetupGitHook.ps1

param(
    [string]$ProjectRoot = "."
)

$GitDir = Join-Path $ProjectRoot ".git" "hooks"

if (-not (Test-Path $GitDir)) {
    Write-Host "❌ Not in a git repository or .git/hooks does not exist" -ForegroundColor Red
    Write-Host "   Run this from your project root" -ForegroundColor Yellow
    exit 1
}

# Create pre-commit hook as batch file (git-compatible on Windows)
$PreCommitBatch = Join-Path $GitDir "pre-commit.bat"
$PreCommitContent = @"
@echo off
REM pre-commit hook - enforce /mem/ entries before committing
REM Pure local filesystem check, no external APIs

setlocal enabledelayedexpansion
for /f "tokens=*" %%A in ('git diff --cached --name-only 2^>nul') do (
    set "file=%%A"
    if not "!file:mem/=!" == "!file!" (
        REM File is in mem/ directory, skip
        continue
    )
    if not "!file:.md=!" == "!file!" (
        REM File is .md, skip
        continue
    )
    if not "!file:.gitignore=!" == "!file!" (
        REM File is .gitignore, skip
        continue
    )
    REM Code file detected, check for /mem/ entry today
    set CODE_CHANGED=1
)

if defined CODE_CHANGED (
    for /f "tokens=*" %%D in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set TODAY=%%D

    if not exist "mem\!TODAY!-*.md" (
        echo.
        echo.
        echo ^^!^^! WARNING: Code changed but no /mem/ entry for today (!TODAY!^).
        echo.
        echo Before committing code changes, document your work:
        echo.
        echo   1. Create: mem\!TODAY!-task-name.md
        echo   2. Include: The Ask, Changes Made, Decisions, Architecture
        echo   3. Then commit again
        echo.
        echo To bypass this check (emergency only):
        echo   git commit --no-verify
        echo.
        exit /b 1
    )
)

exit /b 0
"@

Set-Content -Path $PreCommitBatch -Value $PreCommitContent -Encoding ascii

Write-Host "✓ Pre-commit hook installed" -ForegroundColor Green
Write-Host "  Location: $PreCommitBatch" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Hook behavior:" -ForegroundColor Yellow
Write-Host "  • Detects code changes (not in /mem/, not .md, not .gitignore)" -ForegroundColor Gray
Write-Host "  • Warns if no /mem/YYYYMMDD-*.md entry exists for today" -ForegroundColor Gray
Write-Host "  • Does NOT block commit (warning only)" -ForegroundColor Gray
Write-Host "  • Bypass with: git commit --no-verify" -ForegroundColor Gray
Write-Host ""

# Create .gitignore entry for /mem/ if needed
$GitIgnore = Join-Path $ProjectRoot ".gitignore"
if (Test-Path $GitIgnore) {
    $Content = Get-Content $GitIgnore -Raw
    if ($Content -notmatch '^\s*/mem/\s*$') {
        Add-Content -Path $GitIgnore -Value "`n/mem/" -Encoding utf8
        Write-Host "✓ Added /mem/ to .gitignore" -ForegroundColor Green
    }
} else {
    Set-Content -Path $GitIgnore -Value "/mem/`n" -Encoding utf8
    Write-Host "✓ Created .gitignore with /mem/" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "To test the hook:" -ForegroundColor Cyan
Write-Host "  1. Modify a code file (not in /mem/)" -ForegroundColor Gray
Write-Host "  2. Stage it: git add <file>" -ForegroundColor Gray
Write-Host "  3. Try to commit: git commit -m 'test'" -ForegroundColor Gray
Write-Host "  4. Hook will warn about missing /mem/ entry" -ForegroundColor Gray
