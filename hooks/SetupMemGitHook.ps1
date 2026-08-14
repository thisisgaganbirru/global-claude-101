# SetupMemGitHook.ps1 - Install the mem-first pre-commit backstop
# Run once per project. Cross-tool: fires for commits from Claude Code, Codex,
# Gemini CLI, or a human typing `git commit` directly — git itself doesn't
# care which tool staged the change.
#
# Supersedes SetupGitHook.ps1's pre-commit.bat approach: confirmed by direct
# test that Git for Windows never executes a hook literally named
# "pre-commit.bat" — only the extensionless "pre-commit" file. That script's
# check has therefore never actually fired on this machine. This script
# writes the extensionless form instead, using the same guarded-splice
# pattern as SetupDocsGitHook.ps1, and is safe to run alongside it — both
# append to the same pre-commit file rather than overwriting it.
#
# Warn-only: never blocks a commit.
# Usage: pwsh SetupMemGitHook.ps1

param(
    [string]$ProjectRoot = "."
)

$GitHooksDir = Join-Path $ProjectRoot ".git" "hooks"

if (-not (Test-Path $GitHooksDir)) {
    Write-Host "Not in a git repository or .git/hooks does not exist" -ForegroundColor Red
    Write-Host "  Run this from your project root" -ForegroundColor Yellow
    exit 1
}

$PreCommitPath = Join-Path $GitHooksDir "pre-commit"
$InvocationLine = 'python "$HOME/.claude/hooks/mem_workflow.py" precommit'
$MarkerComment = "# mem-first backstop (SetupMemGitHook.ps1)"
# Guarded so a clone on a machine that never set up this global hook doesn't
# print a Python traceback on every commit — it just silently skips instead.
$GuardedInvocation = @(
    'if [ -f "$HOME/.claude/hooks/mem_workflow.py" ]; then'
    "    $InvocationLine"
    'fi'
)

if (Test-Path $PreCommitPath) {
    $Existing = Get-Content $PreCommitPath -Raw
    if ($Existing -match [regex]::Escape($InvocationLine)) {
        Write-Host "Mem-first pre-commit check is already installed." -ForegroundColor Green
        exit 0
    }
    $Lines = @(Get-Content $PreCommitPath)
    $LastNonBlankIndex = -1
    for ($i = $Lines.Count - 1; $i -ge 0; $i--) {
        if ($Lines[$i].Trim() -ne "") { $LastNonBlankIndex = $i; break }
    }
    $TrailingExitPattern = '^\s*exit(\s+/b)?\s+\d+\s*$'
    if ($LastNonBlankIndex -ge 0 -and $Lines[$LastNonBlankIndex] -match $TrailingExitPattern) {
        $Before = if ($LastNonBlankIndex -gt 0) { $Lines[0..($LastNonBlankIndex - 1)] } else { @() }
        $ExitLine = $Lines[$LastNonBlankIndex]
        $After = if ($LastNonBlankIndex -lt $Lines.Count - 1) { $Lines[($LastNonBlankIndex + 1)..($Lines.Count - 1)] } else { @() }
        $NewLines = $Before + @("", $MarkerComment) + $GuardedInvocation + @("") + @($ExitLine) + $After
        Set-Content -Path $PreCommitPath -Value $NewLines -Encoding utf8
        Write-Host "Inserted mem-first check before the existing hook's exit statement (appending after it would have been dead code)." -ForegroundColor Green
    } else {
        Add-Content -Path $PreCommitPath -Value (@("", $MarkerComment) + $GuardedInvocation + @("")) -Encoding utf8
        Write-Host "Appended mem-first check to existing pre-commit hook." -ForegroundColor Green
    }
} else {
    $Content = (@("#!/bin/sh", $MarkerComment) + $GuardedInvocation + @("exit 0", "")) -join "`n"
    Set-Content -Path $PreCommitPath -Value $Content -Encoding utf8 -NoNewline
    Write-Host "Created pre-commit hook with the mem-first check." -ForegroundColor Green
}

Write-Host ""
Write-Host "Hook behavior:" -ForegroundColor Yellow
Write-Host "  - Fires on every commit, regardless of which tool (or human) made it" -ForegroundColor Gray
Write-Host "  - Warns to stderr if source changed but no mem/ file is staged" -ForegroundColor Gray
Write-Host "  - Never blocks the commit — no --no-verify needed" -ForegroundColor Gray
Write-Host "  - Skips entirely if the project has a .nomemhook file at its root" -ForegroundColor Gray
Write-Host ""
